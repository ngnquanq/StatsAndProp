import { chromium } from 'playwright';
import { readFile, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = dirname(fileURLToPath(import.meta.url));
const source = 'https://cs329z.stanford.edu/';
const snapshotPath = join(root, 'course.json');
const indexPath = join(root, 'COURSE.md');
const changesPath = join(root, 'CHANGES.md');

async function loadPrevious() {
  try { return JSON.parse(await readFile(snapshotPath, 'utf8')); }
  catch (error) { if (error.code === 'ENOENT') return null; throw error; }
}

function renderLink(link) {
  return `[${link.text.replaceAll('[', '\\[').replaceAll(']', '\\]')}](${link.url})`;
}

function renderIndex(data) {
  const lines = [
    '# Stanford CS329Z: Engineering AI Agents',
    '',
    `Source: ${data.source}`,
    `Last checked: ${data.checked_at}`,
    '',
    'The Stanford schedule is tentative. Dates and times below are copied from the course site; deadlines use Pacific time.',
    '',
    '## Lectures',
    ''
  ];
  for (const row of data.lectures) {
    lines.push(`### Week ${row.week} · ${row.date} · ${row.title}`);
    lines.push('');
    if (row.theme) lines.push(`Theme: ${row.theme}`, '');
    if (row.description) lines.push(row.description, '');
    if (row.resources.length) lines.push(`Materials: ${row.resources.map(renderLink).join(' · ')}`, '');
    if (row.readings.length) lines.push('Readings:', '', ...row.readings.map(link => `- ${renderLink(link)}`), '');
  }
  lines.push('## Deadlines', '', '| Week | Item | Date | Time (Pacific) |', '| --- | --- | --- | --- |');
  for (const row of data.deadlines) {
    const item = row.url ? renderLink({ text: row.item, url: row.url }) : row.item;
    lines.push(`| ${row.week} | ${item} | ${row.date} | ${row.time} |`);
  }
  lines.push('', '## Course pages', '', ...data.pages.map(page => `- [${page.title}](${page.url})`), '');
  return lines.join('\n');
}

function diffRows(before, after, label) {
  const old = before ?? [];
  const changes = [];
  for (let index = 0; index < Math.max(old.length, after.length); index++) {
    const prior = old[index];
    const current = after[index];
    const id = `${label} ${index + 1}`;
    if (!prior) { changes.push(`Added ${id}: ${current.title ?? current.item}`); continue; }
    if (!current) { changes.push(`Removed ${id}: ${prior.title ?? prior.item}`); continue; }
    for (const field of Object.keys(current)) {
      const a = prior[field];
      const b = current[field];
      if (JSON.stringify(a) === JSON.stringify(b)) continue;
      if (Array.isArray(b)) {
        const oldLinks = new Map((a ?? []).map(link => [link.url, link]));
        const newLinks = new Map(b.map(link => [link.url, link]));
        for (const [url, link] of newLinks) if (!oldLinks.has(url)) changes.push(`${id} ${field}: added ${renderLink(link)}`);
        for (const [url, link] of oldLinks) if (!newLinks.has(url)) changes.push(`${id} ${field}: removed ${renderLink(link)}`);
        for (const [url, link] of newLinks) if (oldLinks.has(url) && oldLinks.get(url).text !== link.text) {
          changes.push(`${id} ${field}: renamed ${oldLinks.get(url).text} → ${link.text}`);
        }
      } else {
        changes.push(`${id} ${field}: ${a || '—'} → ${b || '—'}`);
      }
    }
  }
  return changes;
}

async function main() {
  const browser = await chromium.launch({
    headless: true,
    ...(process.env.CS329Z_CHROME_PATH ? { executablePath: process.env.CS329Z_CHROME_PATH } : {})
  });
  let data;
  try {
    const page = await browser.newPage({ userAgent: 'CS329Z-course-watch/1.0 (educational course schedule monitor)' });
    const response = await page.goto(source, { waitUntil: 'domcontentloaded', timeout: 45000 });
    if (!response?.ok()) throw new Error(`Course page returned HTTP ${response?.status() ?? 'unknown'}`);
    await page.locator('table').first().waitFor();
    data = await page.evaluate(() => {
      const tidy = value => value?.replace(/\s+/g, ' ').trim() ?? '';
      const links = element => [...element.querySelectorAll('a[href]')].map(a => ({ text: tidy(a.textContent), url: a.href }));
      const tables = [...document.querySelectorAll('main table')];
      if (tables.length < 2) throw new Error('Expected lecture and deadline tables');
      const lectures = [...tables[0].querySelectorAll('tbody tr')].map(tr => {
        const cells = [...tr.querySelectorAll(':scope > td')];
        if (cells.length !== 4) throw new Error('Unexpected lecture table columns');
        const lecture = cells[2];
        const title = tidy(lecture.querySelector('.lec-title')?.textContent) || tidy(lecture.textContent);
        const resources = links(lecture);
        return {
          week: tidy(cells[0].textContent), date: tidy(cells[1].textContent),
          theme: tidy(lecture.querySelector('.theme-tag')?.textContent), title,
          description: tidy(lecture.querySelector('.lec-desc')?.textContent),
          resources, readings: links(cells[3])
        };
      });
      const deadlines = [...tables[1].querySelectorAll('tbody tr')].map(tr => {
        const cells = [...tr.querySelectorAll(':scope > td')];
        if (cells.length !== 4) throw new Error('Unexpected deadline table columns');
        return {
          week: tidy(cells[0].textContent), item: tidy(cells[1].textContent),
          date: tidy(cells[2].textContent), time: tidy(cells[3].textContent),
          url: cells[1].querySelector('a[href]')?.href ?? null
        };
      });
      const pages = [...document.querySelectorAll('nav a[href]')]
        .filter(a => a.href.startsWith(location.origin) && !a.hash)
        .map(a => ({ title: tidy(a.textContent), url: a.href }));
      return { title: document.title, lectures, deadlines, pages };
    });
  } finally { await browser.close(); }
  if (data.lectures.length < 10 || data.deadlines.length < 5) {
    throw new Error(`Suspiciously short crawl: ${data.lectures.length} lectures, ${data.deadlines.length} deadlines`);
  }
  const previous = await loadPrevious();
  const checked_at = new Date().toISOString();
  const snapshot = { source, checked_at, ...data };
  const changes = previous ? [
    ...diffRows(previous.lectures, data.lectures, 'Lecture'),
    ...diffRows(previous.deadlines, data.deadlines, 'Deadline')
  ] : ['Initial snapshot'];
  let history = '# Course site changes\n\n';
  try { history = await readFile(changesPath, 'utf8'); }
  catch (error) { if (error.code !== 'ENOENT') throw error; }
  history = history.trimEnd() + `\n\n## ${checked_at}\n\n${changes.map(change => `- ${change}`).join('\n') || '- No schedule or deadline changes'}\n`;
  await writeFile(snapshotPath, JSON.stringify(snapshot, null, 2) + '\n');
  await writeFile(indexPath, renderIndex(snapshot));
  await writeFile(changesPath, history);
  console.log(`Captured ${data.lectures.length} lectures and ${data.deadlines.length} deadlines; ${changes.length} change(s).`);
}

main().catch(error => { console.error(error); process.exitCode = 1; });
