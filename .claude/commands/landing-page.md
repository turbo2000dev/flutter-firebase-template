# Landing Page Command

Work on the Astro landing page for the application.

## Usage

```
/landing-page <action>
```

Where `<action>` is one of:
- `init` - Initialize a new Astro landing page project
- `dev` - Start development server
- `build` - Build for production
- `check` - Run Astro checks

## Actions

### Initialize (`init`)

Creates a new Astro project in `landing-page/` with:
- Basic project structure
- Bilingual support (EN/FR)
- SEO optimization setup
- Flutter integration (language handoff)
- Matching design system

### Development (`dev`)

```bash
cd landing-page
npm run dev
# Opens at http://localhost:4321
```

### Build (`build`)

```bash
cd landing-page
npm run build
# Output: landing-page/dist/
```

### Check (`check`)

```bash
cd landing-page
npm run astro check
```

## Project Structure

```
landing-page/
├── src/
│   ├── components/       # Header, Footer, CTA, etc.
│   ├── layouts/          # BaseLayout.astro
│   ├── pages/
│   │   ├── index.astro   # English homepage
│   │   └── fr/
│   │       └── index.astro  # French homepage
│   ├── styles/           # global.css
│   └── i18n/             # en.json, fr.json
├── public/               # Static assets
├── astro.config.mjs
└── package.json
```

## Key Requirements

1. **SEO**
   - Proper meta tags (title, description, OG, Twitter)
   - Semantic HTML structure
   - Language alternates (hreflang)
   - Structured data (JSON-LD)

2. **Performance**
   - Lighthouse scores > 90 in all categories
   - Minimal JavaScript
   - Optimized images

3. **Flutter Integration**
   - CTA links to `/app?lang=XX`
   - Store language in localStorage
   - Matching design with Flutter app

## Reference

See `guidelines/astro-development.md` for detailed guidelines.
