# esx_license

## Instalacja
- skopiuj plik esx_license.sql oraz wklej w swojej bazie danych `sql specjalnie zedytowany pod wyspe`

```
start esx_license
```

### Available triggers (server side)
- `'esx_license:addLicense', function(target, type, cb)`
- `'esx_license:removeLicense', function(target, type, cb)`
- `'esx_license:getLicense', function(source, cb, type)` (callback)
- `'esx_license:getLicenses', function(source, cb, target)` (callback)
- `'esx_license:checkLicense', function(source, cb, target, type)` (callback)
- `'esx_license:getLicensesList', function(source, cb)` (callback)
- `'esx_license:addTimedLicense', function(target, type, time, cb)`
