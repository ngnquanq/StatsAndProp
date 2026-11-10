# CS329Z course watch

This folder tracks the [Stanford CS329Z: Engineering AI Agents](https://cs329z.stanford.edu/) course page. The crawler uses Playwright to capture the lecture schedule, links to slides, videos, code and readings, and course deadlines.

- [COURSE.md](COURSE.md) is the readable index.
- [course.json](course.json) is the structured snapshot.
- [CHANGES.md](CHANGES.md) lists changes seen on each crawl.
- `ARCHIVE.md` is generated locally and links to the saved slides and readings. Videos are excluded.

## Run locally

```bash
cd '99. For fun/agent-engineering'
npm ci
npx playwright install chromium
npm run crawl
npm run download
```

The [GitHub Actions workflow](../../.github/workflows/cs329z-course-watch.yml) checks the site every other Tuesday, starting **24 November 2026 at 02:17 UTC** (09:17 in Vietnam), two weeks after the first snapshot. It can also be run on demand from the Actions tab. GitHub's scheduled jobs may start late, and scheduled workflows only run after this workflow is committed to the repository's default branch. The workflow updates the course index and change log. Run `npm run download` locally after a crawl to save new materials.

The downloader keeps source PDFs when available and prints web readings to local PDFs. It skips files already saved and retries failed downloads on the next run. The local archive is excluded from Git because it is about 302 MiB. The OpenAI prompt-injection reading currently returns HTTP 403 to the downloader and is marked unavailable in the archive index. A missing or unexpectedly short schedule fails the crawl so it cannot overwrite a good snapshot with an empty one.
