# Host root of serzhyale.github.io

These files are the source of the repository `SerZhyAle/SerZhyAle.github.io`, the GitHub user site whose address
`https://serzhyale.github.io/` is the root of every project page `https://serzhyale.github.io/<repo>/`.
This folder is the record: a file that exists only in the user-site repository is drift.

## What to publish

Copy every file of this folder, unmodified, to the root of `SerZhyAle/SerZhyAle.github.io`:

- `index.html` - redirects the root to the hub (see Target)
- `robots.txt` - the only `robots.txt` crawlers read for every project page; allow-all plus `Sitemap:` lines
- `ads.txt` - the AdSense seller line; covers every page under the host (kept by the owner's decision of 2026-10-09)
- `.nojekyll` - keeps Pages serving the files verbatim
- `google4e1402891e346207.html` - the Search Console HTML-file verification token for https://serzhyale.github.io/ (never removed)
- `README.md` - this file; the user-site repository tracks it too, so the two stay identical

## Target

- `https://sza.od.ua/`

## Copy procedure

1. Edit the file here, never in the user-site repository.
2. Deploy the hub, then copy the files over, commit and push `main` of `SerZhyAle/SerZhyAle.github.io`.
3. Check: `curl -s https://serzhyale.github.io/robots.txt` answers 200 and equals `robots.txt` here byte for byte.
4. Before every push, `diff -r` this folder against a fresh checkout of the user-site repository: nothing may
   differ except `.git` and the repository-only `.vscode/`. Compare blobs (`git cat-file -p HEAD:<file>`), not a
   Windows checkout: with `core.autocrlf=true` a checkout carries CRLF and every file looks different.

## Hazards

- **No `Disallow` in `robots.txt`.** It is read for every project page; one wrong line de-indexes every product at once.
  A `Sitemap:` line is added only for a project sitemap that answers 200 now and whose every `<loc>` lies under its
  own project path on this host.
- **Never a `CNAME` in the user-site repository.** It would move every project page onto that domain and break every
  product canonical, sitemap and verified property.

## Notes

- The repository `sza.od.ua` cannot by itself control the root GitHub Pages address `serzhyale.github.io`.
- The root stays a redirect to the hub; it never becomes a second portfolio home.
