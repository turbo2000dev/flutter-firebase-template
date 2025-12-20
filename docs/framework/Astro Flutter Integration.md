# Flutter Web landing page: Build external, not integrated

**The external landing page approach is definitively superior for your retirement planning app.** Flutter Web's fundamental architecture—rendering to canvas rather than semantic HTML—makes it structurally incompatible with SEO requirements. Google's own Flutter documentation explicitly recommends: *"You should consider separating your primary application experience—created in Flutter—from your landing page, marketing content, and help content—created using search-engine optimized HTML."* This isn't a workaround; it's the intended architecture.

The performance gap is equally decisive: Flutter Web's initial download ranges from **2-2.5 MB** (minimal app with CanvasKit) versus **~50-100 KB** for a static HTML landing page—a 20-40x difference that directly impacts user acquisition when every second of load time costs conversions.

---

## Why Flutter Web fails for SEO-critical landing pages

Flutter Web renders all content to a `<canvas>` element rather than semantic HTML. Search engine crawlers see an empty DOM with script tags—no `<h1>`, `<p>`, or `<article>` elements containing your carefully crafted copy about retirement planning. While Googlebot can execute JavaScript and render canvas content, it cannot interpret canvas pixels as indexable text.

The situation worsened in 2024-2025. Flutter's HTML renderer (the only option that generated some DOM elements) was **deprecated in March 2024** with removal planned for Q1 2025. The remaining options—CanvasKit and the newer Skwasm (WASM)—both render exclusively to canvas with **zero SEO benefit**.

Critical missing features compound the problem:
- No server-side rendering capability
- No built-in meta tag management from Dart code
- No automatic sitemap generation
- No semantic HTML output regardless of renderer choice

Performance metrics confirm the architectural mismatch. Code With Andrea's benchmarks show Flutter Web CanvasKit running **14x heavier** and achieving First Contentful Paint **10-15x slower** than equivalent static sites. Typical Flutter Web load times reach 4-8+ seconds for FCP on moderate connections—disqualifying for landing page conversion optimization.

---

## The recommended architecture: Astro + Flutter Web on Firebase Hosting

**Astro** emerges as the optimal landing page technology for this stack. Unlike React or Next.js, Astro ships **zero JavaScript by default**, producing pure static HTML that crawlers index perfectly. Measured page loads run **40% faster** than typical React sites. Firebase Hosting natively detects and configures Astro projects automatically.

The architecture separates concerns cleanly:

```
example.com/           → Astro static landing page (SEO-optimized)
example.com/app/       → Flutter Web application (behind auth)
```

This subdirectory approach keeps both on the same origin (critical for localStorage sharing) while using a single Firebase Hosting site with straightforward configuration.

### Firebase Hosting configuration

**firebase.json:**
```json
{
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "cleanUrls": true,
    "headers": [
      {
        "source": "**/*.@(eot|otf|ttf|ttc|woff|woff2)",
        "headers": [{ "key": "Access-Control-Allow-Origin", "value": "*" }]
      }
    ],
    "rewrites": [
      { "source": "/app/**", "destination": "/app/index.html" },
      { "source": "**", "destination": "/index.html" }
    ]
  }
}
```

**Project structure:**
```
project/
├── firebase.json
├── landing-page/           # Astro project
│   ├── src/pages/
│   └── dist/               # Build output
├── flutter-app/            # Flutter project  
│   └── build/web/          # Build output
└── public/                 # Combined deploy folder
    ├── index.html          # Landing (from Astro dist)
    ├── css/
    └── app/                # Flutter (from build/web)
        ├── index.html
        ├── main.dart.js
        └── flutter.js
```

**Build and deploy script:**
```bash
#!/bin/bash
set -e

# Build Astro landing page
cd landing-page
npm run build
cp -r dist/* ../public/

# Build Flutter with subdirectory base href
cd ../flutter-app
flutter build web --release --base-href /app/
mkdir -p ../public/app
cp -r build/web/* ../public/app/

# Deploy
cd ..
firebase deploy --only hosting
```

The `--base-href /app/` flag is **essential**—Flutter Web won't load assets correctly without it when hosted in a subdirectory.

---

## Language preference: URL parameters with localStorage backup

URL parameters provide the cleanest, most debuggable solution for passing language selection from landing page to Flutter app. The landing page links directly to `/app?lang=es`, and Flutter reads this on startup.

**Astro landing page implementation:**
```astro
---
const currentLang = Astro.url.searchParams.get('lang') || 'en';
const languages = [
  { code: 'en', label: 'English' },
  { code: 'es', label: 'Español' }
];
---
<nav>
  {languages.map(lang => (
    <a href={`?lang=${lang.code}`} 
       class:list={[{ active: currentLang === lang.code }]}>
      {lang.label}
    </a>
  ))}
</nav>

<a href={`/app?lang=${currentLang}`} class="cta-button">
  Open App
</a>

<script>
  // Backup: also store in localStorage for persistence
  document.querySelectorAll('a[href^="/app"]').forEach(link => {
    link.addEventListener('click', () => {
      const url = new URL(link.href, window.location.origin);
      const lang = url.searchParams.get('lang');
      if (lang) localStorage.setItem('flutter.userLanguage', lang);
    });
  });
</script>
```

**Flutter Web language initialization:**
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final locale = await determineLocale();
  runApp(RetirementApp(initialLocale: locale));
}

Future<Locale> determineLocale() async {
  // Priority 1: URL parameter (from landing page click)
  final urlLang = Uri.base.queryParameters['lang'];
  if (urlLang != null && _isSupported(urlLang)) {
    await _persistLanguage(urlLang);
    return Locale(urlLang);
  }
  
  // Priority 2: Previously saved preference
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('userLanguage');
  if (savedLang != null && _isSupported(savedLang)) {
    return Locale(savedLang);
  }
  
  // Priority 3: Browser language
  final browserLang = Uri.base.toString().contains('lang=') 
      ? null 
      : _getBrowserLanguage();
  if (browserLang != null && _isSupported(browserLang)) {
    return Locale(browserLang);
  }
  
  return const Locale('en');
}

bool _isSupported(String code) => ['en', 'es'].contains(code);

Future<void> _persistLanguage(String code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userLanguage', code);
}

String? _getBrowserLanguage() {
  // Web-only: reads navigator.language
  return null; // Implement with dart:html on web
}
```

The `flutter.userLanguage` localStorage key uses the `flutter.` prefix intentionally—SharedPreferences on web prefixes all keys this way, enabling the landing page's JavaScript to write values that Flutter reads natively.

---

## Architectural comparison summary

| Factor | Flutter-Integrated | External (Astro) |
|--------|-------------------|------------------|
| **SEO crawlability** | ❌ Canvas = invisible to crawlers | ✅ Pure semantic HTML |
| **Initial load** | 2-2.5 MB minimum | ~50-100 KB |
| **Time to FCP** | 4-8+ seconds | <1 second |
| **Meta tags/OG** | Manual DOM hacks required | Native HTML support |
| **Maintenance** | Single codebase | Two codebases |
| **Language sharing** | Trivial (same app) | URL params + localStorage |
| **Official recommendation** | ❌ Explicitly discouraged | ✅ Explicitly recommended |

**The maintenance overhead of two codebases is real but manageable.** Your landing page likely changes infrequently compared to the app itself. The SEO and performance benefits far outweigh the minor complexity of maintaining an Astro project alongside Flutter.

---

## Implementation checklist

1. **Initialize Astro project** in `landing-page/` directory
2. **Configure firebase.json** with subdirectory rewrites (configuration above)
3. **Build Flutter** with `--base-href /app/` flag
4. **Implement language selector** on landing page storing to localStorage
5. **Read language in Flutter** via `Uri.base.queryParameters` + SharedPreferences fallback
6. **Enable path URL strategy** in Flutter: add `usePathUrlStrategy()` to main()
7. **Create deploy script** combining both builds into `public/` folder

For your retirement planning app targeting organic web traffic, the external landing page isn't just recommended—it's the only architecture that can actually achieve your SEO goals. Flutter Web excels at application experiences; let Astro handle the content marketing that brings users to your door.