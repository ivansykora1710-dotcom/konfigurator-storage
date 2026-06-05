# Regálové boxy configurator workflow

This project keeps two versions of the regálové boxy configurator:

- `shoptet-vlozenie-regalove-boxy.html` is the readable source file.
- `assets-loader-rb-v3.js` is the production loader used by Shoptet.

## Edit workflow

1. Edit `shoptet-vlozenie-regalove-boxy.html`.
2. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\verify-regalove-boxy.ps1
powershell -ExecutionPolicy Bypass -File .\tools\build-regalove-boxy-loader.ps1
```

3. Upload or commit the updated `assets-loader-rb-v3.js` to GitHub.
4. In Shoptet, keep the same snippet and only increase the cache version:

```html
<div data-storage-regalove-boxy-config></div>
<script src="https://cdn.jsdelivr.net/gh/ivansykora1710-dotcom/konfigurator-storage@main/assets-loader-rb-v3.js?v=YYYYMMDD-1"></script>
```

5. If jsDelivr keeps an old file, purge:

```text
https://purge.jsdelivr.net/gh/ivansykora1710-dotcom/konfigurator-storage@main/assets-loader-rb-v3.js
```

## Security note

Client-side code can never be fully hidden. The current setup makes casual copying harder because Shoptet only contains a loader and the public code is encoded/minified-like. For stronger protection, keep the GitHub repository private and only grant access to trusted users.

## Critical audit

Before publishing any new product, always run `verify-regalove-boxy.ps1`. It checks that front and inner divider widths match the selected crate width, so a `15,6 cm` box cannot accidentally send `23,4 cm` dividers to the cart.
