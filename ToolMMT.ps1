# Kiểm tra và yêu cầu chạy với quyền Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# URL download file
$url = "https://github.com/ghostminhtoan/private/releases/download/MMT/MMT.Tool.exe"
$outputFile = "$env:TEMP\MMT.Tool.exe"

Write-Host "Đang tải file MMT.Tool.exe..." -ForegroundColor Yellow

try {
    # Tải file từ GitHub
    Invoke-WebRequest -Uri $url -OutFile $outputFile -UseBasicParsing
    
    Write-Host "Tải thành công! Đang chạy file..." -ForegroundColor Green
    
    # Chạy file với quyền Administrator
    Start-Process -FilePath $outputFile -Verb RunAs -Wait
    
    Write-Host "Hoàn thành!" -ForegroundColor Green
}
catch {
    Write-Host "Lỗi khi tải file: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Nhấn Enter để thoát"
}
