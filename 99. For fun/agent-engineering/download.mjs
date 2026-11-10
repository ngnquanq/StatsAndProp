import { chromium } from 'playwright';
import { createHash } from 'node:crypto';
import { readFile, writeFile, mkdir, stat } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = dirname(fileURLToPath(import.meta.url));
const snapshot = JSON.parse(await readFile(join(root, 'course.json'), 'utf8'));
const manifestPath = join(root, 'archive.json');
const indexPath = join(root, 'ARCHIVE.md');
const slug = value => value.toLowerCase().normalize('NFKD').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').slice(0, 65) || 'reading';
const digest = value => createHash('sha256').update(value).digest('hex').slice(0, 10);
const localFile = item => item.kind === 'slide'
  ? `slides/${new URL(item.url).pathname.split('/').at(-1)}`
  : `readings/${slug(item.text)}-${digest(item.url)}.pdf`;

function sourcePdf(url) {
  const parsed = new URL(url);
  // The course's OpenReview link currently challenges automated clients;
  // the paper authors also publish the same AutoLibra paper on arXiv.
  if (url === 'https://openreview.net/forum?id=4BjGVZ7Bxn') return 'https://arxiv.org/pdf/2505.02820';
  if (parsed.hostname === 'arxiv.org' && parsed.pathname.startsWith('/abs/')) {
    return `https://arxiv.org/pdf/${parsed.pathname.slice(5)}`;
  }
  if (parsed.hostname === 'aclanthology.org') return `${url.replace(/\/$/, '')}.pdf`;
  if (parsed.hostname === 'openreview.net' && parsed.pathname === '/forum') {
    return `https://openreview.net/pdf${parsed.search}`;
  }
  if (parsed.pathname.toLowerCase().endsWith('.pdf')) return url;
  return null;
}

async function validPdf(path) {
  try {
    const { size } = await stat(path);
    if (size < 5000) return false;
    const file = await readFile(path);
    return file.subarray(0, 5).toString() === '%PDF-';
  } catch (error) { if (error.code === 'ENOENT') return false; throw error; }
}

async function getPdf(url) {
  const headers = { 'User-Agent': 'CS329Z-course-watch/1.0 (personal study archive)' };
  if (new URL(url).hostname === 'web.stanford.edu') {
    const head = await fetch(url, { method: 'HEAD', headers, signal: AbortSignal.timeout(30000) });
    const size = Number(head.headers.get('content-length'));
    if (head.ok && head.headers.get('accept-ranges') === 'bytes' && size > 1_000_000) {
      const pieces = 6;
      const chunk = Math.ceil(size / pieces);
      const parts = await Promise.all(Array.from({ length: pieces }, async (_, i) => {
        const start = i * chunk;
        const end = Math.min(size - 1, start + chunk - 1);
        if (start > end) return Buffer.alloc(0);
        const response = await fetch(url, { headers: { ...headers, Range: `bytes=${start}-${end}` }, signal: AbortSignal.timeout(300000) });
        if (response.status !== 206) throw new Error(`Range request returned HTTP ${response.status} at ${url}`);
        const data = Buffer.from(await response.arrayBuffer());
        if (data.length !== end - start + 1) throw new Error(`Incomplete range at ${url}`);
        return data;
      }));
      return Buffer.concat(parts);
    }
  }
  const response = await fetch(url, { headers, signal: AbortSignal.timeout(300000) });
  if (!response.ok) throw new Error(`HTTP ${response.status} at ${url}`);
  const data = Buffer.from(await response.arrayBuffer());
  if (data.subarray(0, 5).toString() !== '%PDF-') throw new Error(`Not a PDF at ${url} (${response.headers.get('content-type')})`);
  return data;
}

async function printPage(browser, url) {
  const page = await browser.newPage();
  try {
    const response = await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 45000 });
    if (!response?.ok()) throw new Error(`HTTP ${response?.status() ?? 'unknown'} at ${url}`);
    await page.locator('body').waitFor();
    await page.waitForTimeout(800);
    const text = await page.locator('body').innerText();
    if (text.trim().length < 200) throw new Error(`Page has too little text: ${url}`);
    return await page.pdf({ format: 'A4', printBackground: true, margin: { top: '16mm', bottom: '16mm', left: '14mm', right: '14mm' } });
  } finally { await page.close(); }
}

function renderIndex(items, records) {
  const lines = [
    '# Local slides and readings', '',
    `Course page: ${snapshot.source}`, '',
    'PDF readings are downloaded from their source. Web readings are saved as printable PDFs. Videos are excluded.', ''
  ];
  for (const kind of ['slide', 'reading']) {
    lines.push(`## ${kind === 'slide' ? 'Slides' : 'Readings'}`, '');
    for (const item of items.filter(item => item.kind === kind)) {
      const record = records[item.url];
      const local = record?.status === 'saved' ? `[Local PDF](${record.file})` : `Unavailable locally: ${record?.error ?? 'not attempted'}`;
      const alternate = record?.method === 'alternate-pdf' ? ` · [PDF source](${record.download_url})` : '';
      lines.push(`- Week ${item.week}, ${item.date}: ${item.text.replaceAll('[', '\\[').replaceAll(']', '\\]')} — ${local} · [Course link](${item.url})${alternate}`);
    }
    lines.push('');
  }
  return lines.join('\n');
}

const items = [];
const seen = new Set();
for (const lecture of snapshot.lectures) {
  for (const link of lecture.resources.filter(link => /slides?/i.test(link.text))) {
    if (!seen.has(link.url)) { items.push({ kind: 'slide', ...link, week: lecture.week, date: lecture.date }); seen.add(link.url); }
  }
  for (const link of lecture.readings) {
    if (!seen.has(link.url)) { items.push({ kind: 'reading', ...link, week: lecture.week, date: lecture.date }); seen.add(link.url); }
  }
}

let records = {};
try { records = JSON.parse(await readFile(manifestPath, 'utf8')).items; }
catch (error) { if (error.code !== 'ENOENT') throw error; }
await mkdir(join(root, 'slides'), { recursive: true });
await mkdir(join(root, 'readings'), { recursive: true });
const browser = await chromium.launch({
  headless: true,
  ...(process.env.CS329Z_CHROME_PATH ? { executablePath: process.env.CS329Z_CHROME_PATH } : {})
});
let saved = 0, skipped = 0, failed = 0;
try {
  const queue = [...items];
  async function worker() {
    while (queue.length) {
    const item = queue.shift();
    const file = localFile(item);
    const path = join(root, file);
    if (await validPdf(path)) {
      records[item.url] = { ...records[item.url], kind: item.kind, title: item.text, file, status: 'saved', bytes: (await stat(path)).size };
      skipped++;
      continue;
    }
    try {
      const pdfUrl = sourcePdf(item.url);
      const data = pdfUrl ? await getPdf(pdfUrl) : await printPage(browser, item.url);
      if (data.length < 5000 || data.subarray(0, 5).toString() !== '%PDF-') throw new Error('Generated PDF is invalid or too small');
      await writeFile(path, data);
      records[item.url] = { kind: item.kind, title: item.text, file, status: 'saved', bytes: data.length, saved_at: new Date().toISOString(), method: pdfUrl ? (pdfUrl === item.url || pdfUrl.replace('/pdf/', '/abs/') === item.url ? 'source-pdf' : 'alternate-pdf') : 'printed-web-page', download_url: pdfUrl ?? item.url };
      saved++;
      console.log(`Saved ${file} (${Math.round(data.length / 1024)} KiB)`);
    } catch (error) {
      records[item.url] = { kind: item.kind, title: item.text, file, status: 'failed', error: error.message };
      failed++;
      console.error(`Failed ${item.url}: ${error.message}`);
    }
    }
  }
  await Promise.all([worker(), worker()]);
} finally { await browser.close(); }
await writeFile(manifestPath, JSON.stringify({ source: snapshot.source, checked_at: new Date().toISOString(), items: records }, null, 2) + '\n');
await writeFile(indexPath, renderIndex(items, records));
console.log(`Slides and readings: ${saved} saved, ${skipped} already present, ${failed} failed.`);
if (failed && saved + skipped === 0) process.exitCode = 1;
