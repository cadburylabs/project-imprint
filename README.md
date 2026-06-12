# project-imprint

Live demo: [trycadbury.com/project-imprint](https://trycadbury.com/project-imprint)

Blog: [trycadbury.com/project-imprint](https://trycadbury.com/project-imprint)


A navigable, static clone of a NetSuite instance — built so people can explore NetSuite before buying it.

Every page is a real NetSuite page, captured and served as static HTML. A chat widget powered by [Cadbury](https://trycadbury.com) sits in the corner and can answer questions about whatever page you're on.

---

## What's in this repo

This repo is the static site content — the captured NetSuite HTML, assets, and images. Pages use `.nl` extensions (NetSuite's native URL format).

```
index.html     — Home page / nav shell
app/           — Inner pages (.nl files)
assets/        — JS, CSS, fonts
images/        — Image assets
```

---

## How the clone was captured

Pages were captured from a live NetSuite sandbox using a session cookie and a headless browser. The capture is a point-in-time snapshot — NetSuite's JS runs in the browser, so pages are interactive but API calls (session checks, data fetches) will 404 or 403 as expected on a static clone.

The HTML reflects Cadbury Technology, Inc.'s demo account and is intentionally included so contributors have something to work with immediately — no NetSuite account needed.

---

## Contributing

There's a lot more work to do. Check the [issues page](https://github.com/cadburylabs/project-imprint/issues) for open tasks.
