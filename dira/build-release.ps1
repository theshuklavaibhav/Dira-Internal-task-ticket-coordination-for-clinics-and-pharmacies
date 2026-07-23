Write-Host "Building Release APK with EmailJS Dart Defines..." -ForegroundColor Cyan

flutter build apk --release `
  --dart-define=EMAILJS_SERVICE_ID=service_r5pvm0r `
  --dart-define=EMAILJS_TEMPLATE_ID=template_ezxs9ez `
  --dart-define=EMAILJS_PUBLIC_KEY=_fJu2GVUvb8Ix-LgU

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nRelease APK successfully built!" -ForegroundColor Green
    Write-Host "File location: build\app\outputs\flutter-apk\app-release.apk`n" -ForegroundColor Yellow
} else {
    Write-Host "`nBuild failed! Check logs above." -ForegroundColor Red
}