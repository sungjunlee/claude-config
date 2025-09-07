---
description: Build and bundle optimization for JavaScript projects
---

# Build and Optimize

Build and optimize for: $ARGUMENTS

## Build Tool Detection

Detect build configuration:
1. Next.js (next build)
2. Vite (vite build)
3. Webpack (webpack.config.*)
4. Rollup (rollup.config.*)
5. esbuild configuration
6. Generic npm build script

## Optimization Strategies

### Bundle Analysis
```bash
# For webpack
npx webpack-bundle-analyzer

# For Next.js  
npx @next/bundle-analyzer

# For Vite
npx vite-bundle-visualizer
```

### Common Optimizations

1. **Code Splitting**
   - Dynamic imports for large components
   - Route-based splitting

2. **Tree Shaking**
   - Remove unused exports
   - Optimize imports from large libraries

3. **Asset Optimization**
   - Image optimization
   - Font subsetting
   - Compression (gzip/brotli)

## Build Commands

```bash
# Development build
npm run build:dev

# Production build
npm run build

# Build with analysis
ANALYZE=true npm run build
```

Execute appropriate build process with optimizations.