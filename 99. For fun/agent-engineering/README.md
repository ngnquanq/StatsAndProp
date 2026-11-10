# CS329Z course watch

This folder tracks the [Stanford CS329Z: Engineering AI Agents](https://cs329z.stanford.edu/) course page. The crawler uses Playwright to capture the lecture schedule, links to slides, videos, code and readings, and course deadlines.

- [COURSE.md](COURSE.md) is the readable index.
- [course.json](course.json) is the structured snapshot.
- [CHANGES.md](CHANGES.md) lists changes seen on each crawl.

## Run locally

```bash
cd '99. For fun/agent-engineering'
npm ci
npx playwright install chromium
npm run crawl
```

The [GitHub Actions workflow](../../.github/workflows/cs329z-course-watch.yml) checks the site every other Tuesday, starting **24 November 2026 at 02:17 UTC** (09:17 in Vietnam), two weeks after the first snapshot. It can also be run on demand from the Actions tab. GitHub's scheduled jobs may start late, and scheduled workflows only run after this workflow is committed to the repository's default branch. The workflow commits the refreshed snapshot and change log back to the repository.

This is a page monitor, not a downloader: materials stay linked to their original sources. A missing or unexpectedly short schedule fails the crawl so it cannot overwrite a good snapshot with an empty one.
