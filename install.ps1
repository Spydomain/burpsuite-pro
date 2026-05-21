# ============================================================
#  Spydomain — Burp Suite Professional Installer
#  Platform: Windows (PowerShell)
#  Repository: https://github.com/Spydomain/burpsuite-pro
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║       Spydomain — Burp Suite Pro Installer       ║" -ForegroundColor Cyan
Write-Host "  ║                   Windows                        ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Suppress progress bar to avoid slow downloads
$ProgressPreference = 'SilentlyContinue'

$version = "latest"
$installDir = $PSScriptRoot

# ── 1. Check/Install JDK 21 ─────────────────────────────────
Write-Host "[1/5] Checking Java JDK-21..." -ForegroundColor Yellow

$jdk21 = Get-WmiObject -Class Win32_Product -Filter "Vendor='Oracle Corporation'" |
    Where-Object { $_.Caption -like "Java(TM) SE Development Kit 21*" }

if (!$jdk21) {
    Write-Host "  Downloading JDK-21..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://download.oracle.com/java/21/archive/jdk-21_windows-x64_bin.exe" -OutFile "$installDir\jdk-21.exe"
    Write-Host "  Installing JDK-21 (follow the installer)..."
    Start-Process -Wait "$installDir\jdk-21.exe"
    Remove-Item "$installDir\jdk-21.exe" -ErrorAction SilentlyContinue
    Write-Host "  [OK] JDK-21 installed" -ForegroundColor Green
} else {
    Write-Host "  [OK] JDK-21 is already installed" -ForegroundColor Green
}

# ── 2. Check/Install JRE 8 ──────────────────────────────────
Write-Host "`n[2/5] Checking Java JRE-8..." -ForegroundColor Yellow

$jre8 = Get-WmiObject -Class Win32_Product -Filter "Vendor='Oracle Corporation'" |
    Where-Object { $_.Caption -like "Java 8 Update *" }

if (!$jre8) {
    Write-Host "  Downloading JRE-8..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247947_0ae14417abb444ebb02b9815e2103550" -OutFile "$installDir\jre-8.exe"
    Write-Host "  Installing JRE-8 (follow the installer)..."
    Start-Process -Wait "$installDir\jre-8.exe"
    Remove-Item "$installDir\jre-8.exe" -ErrorAction SilentlyContinue
    Write-Host "  [OK] JRE-8 installed" -ForegroundColor Green
} else {
    Write-Host "  [OK] JRE-8 is already installed" -ForegroundColor Green
}

# ── 3. Download Burp Suite Professional ──────────────────────
Write-Host "`n[3/5] Downloading Burp Suite Professional (latest)..." -ForegroundColor Yellow

$jarFile = "$installDir\burpsuite_pro_v$version.jar"

if (Test-Path $jarFile) {
    $size = (Get-Item $jarFile).Length / 1MB
    Write-Host "  JAR already exists ($([math]::Round($size))MB)" -ForegroundColor Green
    $redownload = Read-Host "  Re-download? [y/N]"
    if ($redownload -eq 'y') {
        Remove-Item $jarFile
        Invoke-WebRequest -Uri "https://portswigger-cdn.net/burp/releases/download?product=pro&type=Jar" -OutFile $jarFile
    }
} else {
    Invoke-WebRequest -Uri "https://portswigger-cdn.net/burp/releases/download?product=pro&type=Jar" -OutFile $jarFile
}
Write-Host "  [OK] Burp Suite Professional downloaded" -ForegroundColor Green

# ── 4. Download loader if missing ────────────────────────────
Write-Host "`n[4/5] Checking loader.jar..." -ForegroundColor Yellow

if (!(Test-Path "$installDir\loader.jar")) {
    Write-Host "  Downloading loader.jar..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://github.com/povzayd/Burpsuite-Professional/raw/refs/heads/main/loader.jar" -OutFile "$installDir\loader.jar"
    Write-Host "  [OK] Loader downloaded" -ForegroundColor Green
} else {
    Write-Host "  [OK] Loader already exists" -ForegroundColor Green
}

# ── 5. Create launcher files ────────────────────────────────
Write-Host "`n[5/5] Creating launcher files..." -ForegroundColor Yellow

# Create Burp.bat
$batContent = "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:`"$installDir\loader.jar`" -noverify -jar `"$installDir\burpsuite_pro_v$version.jar`""
$batContent | Set-Content -Path "$installDir\Burp.bat" -Force
Write-Host "  [OK] Burp.bat created" -ForegroundColor Green

# Create VBS launcher (runs without console window)
$vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "$installDir\Burp.bat" & Chr(34), 0
Set WshShell = Nothing
"@
$vbsContent | Set-Content -Path "$installDir\Burp-Suite-Pro.vbs" -Force
Write-Host "  [OK] Burp-Suite-Pro.vbs created" -ForegroundColor Green

# ── Reload PATH and Launch ───────────────────────────────────
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║       Spydomain — Installation Complete!         ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  TIP: Change the icon of Burp-Suite-Pro.vbs to burp_suite.ico" -ForegroundColor Yellow
Write-Host "  TIP: Create a desktop shortcut to Burp-Suite-Pro.vbs" -ForegroundColor Yellow
Write-Host ""

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "Starting Keygen Loader..." -ForegroundColor Cyan
Start-Process java.exe -ArgumentList "-jar `"$installDir\loader.jar`""

Write-Host "Starting Burp Suite Professional..." -ForegroundColor Cyan
java --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:"$installDir\loader.jar" -noverify -jar "$installDir\burpsuite_pro_v$version.jar"
