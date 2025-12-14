import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  site: 'https://{{PROD_DOMAIN}}',
  output: 'static',
  build: {
    assets: 'assets'
  },
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'fr'],
    routing: {
      prefixDefaultLocale: false
    }
  }
});
