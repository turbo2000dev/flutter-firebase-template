# Astro Landing Page Development Guidelines

## Overview

The landing page uses [Astro](https://astro.build/) for building an SEO-optimized, fast-loading marketing page that introduces the {{PROJECT_DESCRIPTION}} application. This page serves as the entry point for users discovering the app via search engines.

## Why Astro?

| Factor | Flutter Web | Astro |
|--------|-------------|-------|
| **SEO** | Canvas rendering = invisible to crawlers | Pure semantic HTML |
| **Initial Load** | 2-2.5 MB minimum | ~50-100 KB |
| **Time to FCP** | 4-8+ seconds | <1 second |
| **Meta Tags** | Manual DOM hacks | Native HTML support |

**Key Benefit:** Astro ships zero JavaScript by default, producing pure static HTML that search engines index perfectly.

## Project Structure

```
landing-page/
├── src/
│   ├── components/       # Reusable UI components
│   │   ├── Header.astro
│   │   ├── Footer.astro
│   │   ├── LanguageSelector.astro
│   │   ├── FeatureCard.astro
│   │   └── CTAButton.astro
│   │
│   ├── layouts/          # Page layouts
│   │   └── BaseLayout.astro
│   │
│   ├── pages/            # Route pages
│   │   ├── index.astro          # English homepage
│   │   └── fr/
│   │       └── index.astro      # French homepage
│   │
│   ├── styles/           # Global styles
│   │   └── global.css
│   │
│   └── i18n/             # Internationalization
│       ├── en.json
│       └── fr.json
│
├── public/               # Static assets
│   ├── images/
│   ├── fonts/
│   └── favicon.ico
│
├── astro.config.mjs      # Astro configuration
├── package.json
└── tsconfig.json
```

## Development Commands

```bash
# Navigate to landing page directory
cd landing-page

# Install dependencies
npm install

# Start development server
npm run dev
# Opens at http://localhost:4321

# Build for production
npm run build
# Output: dist/

# Preview production build
npm run preview

# Check for issues
npm run astro check
```

## Key Concepts

### 1. Astro Components (.astro files)

Astro components combine HTML, CSS, and JavaScript in a single file:

```astro
---
// Component Script (runs at build time)
interface Props {
  title: string;
  description: string;
}

const { title, description } = Astro.props;
const currentLang = Astro.url.pathname.startsWith('/fr') ? 'fr' : 'en';
---

<!-- Component Template -->
<section class="feature">
  <h2>{title}</h2>
  <p>{description}</p>
</section>

<style>
  /* Scoped CSS - only affects this component */
  .feature {
    padding: 2rem;
    border-radius: 8px;
    background: var(--surface);
  }
</style>
```

### 2. Layouts

Base layout wraps all pages:

```astro
---
// src/layouts/BaseLayout.astro
interface Props {
  title: string;
  description: string;
  lang?: string;
}

const { title, description, lang = 'en' } = Astro.props;
---

<!DOCTYPE html>
<html lang={lang}>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content={description}>

  <!-- Open Graph -->
  <meta property="og:title" content={title}>
  <meta property="og:description" content={description}>
  <meta property="og:type" content="website">

  <title>{title}</title>
  <link rel="stylesheet" href="/styles/global.css">
</head>
<body>
  <slot />
</body>
</html>
```

### 3. Pages and Routing

File-based routing:
- `src/pages/index.astro` → `/`
- `src/pages/fr/index.astro` → `/fr/`
- `src/pages/about.astro` → `/about`

```astro
---
// src/pages/index.astro
import BaseLayout from '../layouts/BaseLayout.astro';
import Header from '../components/Header.astro';
import Hero from '../components/Hero.astro';
import Features from '../components/Features.astro';
import CTA from '../components/CTA.astro';
import Footer from '../components/Footer.astro';

import en from '../i18n/en.json';
const t = en;
---

<BaseLayout
  title={t.meta.title}
  description={t.meta.description}
  lang="en"
>
  <Header lang="en" />
  <main>
    <Hero
      title={t.hero.title}
      subtitle={t.hero.subtitle}
      ctaText={t.hero.cta}
      ctaLink="/app?lang=en"
    />
    <Features features={t.features} />
    <CTA
      title={t.cta.title}
      buttonText={t.cta.button}
      buttonLink="/app?lang=en"
    />
  </main>
  <Footer lang="en" />
</BaseLayout>
```

## Language Integration with Flutter

### Passing Language to Flutter App

The landing page passes the selected language via URL parameters:

```astro
---
// src/components/CTAButton.astro
interface Props {
  text: string;
  lang: string;
}

const { text, lang } = Astro.props;
---

<a href={`/app?lang=${lang}`} class="cta-button">
  {text}
</a>

<script>
  // Also store in localStorage for persistence
  document.querySelectorAll('a[href^="/app"]').forEach(link => {
    link.addEventListener('click', () => {
      const url = new URL(link.href, window.location.origin);
      const lang = url.searchParams.get('lang');
      if (lang) {
        // Use flutter. prefix so SharedPreferences can read it
        localStorage.setItem('flutter.userLanguage', lang);
      }
    });
  });
</script>
```

### Flutter Reading the Language

```dart
// In Flutter app's main.dart
Future<Locale> determineLocale() async {
  // Priority 1: URL parameter (from landing page)
  final urlLang = Uri.base.queryParameters['lang'];
  if (urlLang != null && _isSupported(urlLang)) {
    await _persistLanguage(urlLang);
    return Locale(urlLang);
  }

  // Priority 2: Saved preference
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('userLanguage');
  if (savedLang != null && _isSupported(savedLang)) {
    return Locale(savedLang);
  }

  // Priority 3: Default
  return const Locale('en');
}
```

## SEO Best Practices

### 1. Meta Tags

Every page should have:
```astro
<head>
  <title>{{PROJECT_DISPLAY_NAME}} | Plan Your Financial Future</title>
  <meta name="description" content="Free {{PROJECT_DESCRIPTION}} tool for {{TARGET_REGION}} residents...">

  <!-- Open Graph -->
  <meta property="og:title" content="...">
  <meta property="og:description" content="...">
  <meta property="og:image" content="/images/og-image.png">
  <meta property="og:url" content="https://example.com">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">

  <!-- Canonical URL -->
  <link rel="canonical" href="https://example.com">

  <!-- Language alternates -->
  <link rel="alternate" hreflang="en" href="https://example.com">
  <link rel="alternate" hreflang="fr" href="https://example.com/fr">
</head>
```

### 2. Semantic HTML

Use proper HTML5 semantic elements:
```astro
<header>
  <nav>...</nav>
</header>

<main>
  <section aria-labelledby="features-heading">
    <h2 id="features-heading">Features</h2>
    ...
  </section>
</main>

<footer>
  ...
</footer>
```

### 3. Structured Data

Add JSON-LD for rich search results:
```astro
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "{{PROJECT_DISPLAY_NAME}}",
  "applicationCategory": "FinanceApplication",
  "operatingSystem": "Web",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "CAD"
  }
}
</script>
```

## Styling

### Global Styles

```css
/* src/styles/global.css */
:root {
  /* Match Flutter app colors */
  --primary: #1976D2;
  --primary-dark: #1565C0;
  --surface: #FFFFFF;
  --background: #F5F5F5;
  --text: #212121;
  --text-secondary: #757575;

  /* Typography */
  --font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: var(--font-family);
  color: var(--text);
  background: var(--background);
  line-height: 1.6;
}
```

### Component Styles

Use scoped `<style>` in components for isolation:
```astro
<style>
  /* Only affects this component */
  .hero {
    min-height: 80vh;
    display: flex;
    align-items: center;
    justify-content: center;
  }
</style>
```

## Build and Deployment

### Build Configuration

```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://{{FIREBASE_PROJECT_ID}}.web.app',
  output: 'static',  // Generate static HTML
  build: {
    assets: 'assets',  // Asset directory name
  },
  // Ensure trailing slashes for consistency
  trailingSlash: 'ignore',
});
```

### Integration with Main Build

The main `build-all.sh` script handles combining Astro and Flutter:

```bash
# 1. Build Astro landing page
cd landing-page
npm run build
cp -r dist/* ../public/

# 2. Build Flutter with subdirectory base-href
cd ../
flutter build web --release --base-href /app/
mkdir -p public/app
cp -r build/web/* public/app/

# 3. Deploy combined public/ folder
firebase deploy --only hosting
```

## Testing

### Visual Testing

```bash
# Start dev server and manually test
npm run dev

# Check different viewports
# Test language switching
# Verify links to /app work correctly
```

### Lighthouse Audit

Run Lighthouse in Chrome DevTools:
- Performance: Target > 90
- Accessibility: Target > 90
- Best Practices: Target > 90
- SEO: Target > 90

### Link Checking

Verify all links work, especially:
- Language switcher links
- CTA buttons pointing to `/app?lang=XX`
- Social media links
- Legal/privacy links

## Common Patterns

### Language Selector

```astro
---
// src/components/LanguageSelector.astro
interface Props {
  currentLang: string;
}

const { currentLang } = Astro.props;
const languages = [
  { code: 'en', label: 'English', path: '/' },
  { code: 'fr', label: 'Français', path: '/fr/' },
];
---

<nav class="lang-selector" aria-label="Language">
  {languages.map(lang => (
    <a
      href={lang.path}
      class:list={['lang-link', { active: currentLang === lang.code }]}
      hreflang={lang.code}
    >
      {lang.label}
    </a>
  ))}
</nav>
```

### Responsive Images

```astro
<picture>
  <source
    srcset="/images/hero-mobile.webp"
    media="(max-width: 768px)"
    type="image/webp"
  >
  <source
    srcset="/images/hero-desktop.webp"
    type="image/webp"
  >
  <img
    src="/images/hero-desktop.png"
    alt="Retirement planning dashboard"
    loading="lazy"
    width="1200"
    height="800"
  >
</picture>
```

## Troubleshooting

### "Page not found after build"

Check that `astro.config.mjs` has correct settings and pages are in `src/pages/`.

### "Styles not applying"

Ensure global styles are imported in the layout and component styles use `<style>` tags.

### "Links to /app not working locally"

The `/app` path only works when deployed with Firebase Hosting. For local testing, the Flutter app runs on its own port.

### "French page not indexed"

Add `<link rel="alternate" hreflang="fr" href="...">` tags to both pages.

---

**Version:** 1.0
**Last Updated:** December 2024
**Related:** `deployment.md`, `environments.md`
