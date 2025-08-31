# Kiem tra va yeu cau chay voi quyen Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# URL download file
$url = "https://github.com/ghostminhtoan/private/releases/download/MMT/MMT.Tool.exe"
$outputFile = "$env:TEMP\MMT.Tool.exe"

Write-Host "Dang tai file MMT.Tool.exe..." -ForegroundColor Yellow

try {
    # Tai file tu GitHub
    Invoke-WebRequest -Uri $url -OutFile $outputFile -UseBasicParsing
    
    Write-Host "Tai thanh cong! Dang chay file..." -ForegroundColor Green
    
    # Chay file voi quyen Administrator
    Start-Process -FilePath $outputFile -Verb RunAs -Wait
    
    Write-Host "Hoan thanh!" -ForegroundColor Green
}
catch {
    Write-Host "Loi khi tai file: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Nhan Enter de thoat"
}
