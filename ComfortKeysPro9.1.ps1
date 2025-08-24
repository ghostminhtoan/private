# PowerShell script để tải và cài đặt Comfort Clipboard Pro
# Tạo shortcut trên Desktop công cộng và Start Menu

# Hàm hiển thị thông báo màu sắc
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Hàm kiểm tra ổ đĩa hợp lệ
function Test-ValidDrive {
    param([string]$Drive)
    $availableDrives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} | Select-Object -ExpandProperty Name
    return $availableDrives -contains $Drive.Trim(':').ToUpper()
}

# Hàm tải file
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    try {
        Write-ColorOutput "Đang tải file từ $Url..." "Yellow"
        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-ColorOutput "Tải file thành công: $OutputPath" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Lỗi khi tải file: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Hàm tạo shortcut
function Create-Shortcut {
    param(
        [string]$SourceExe,
        [string]$ShortcutPath,
        [string]$Description
    )
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $SourceExe
        $Shortcut.WorkingDirectory = Split-Path $SourceExe
        $Shortcut.Description = $Description
        $Shortcut.Save()
        Write-ColorOutput "Đã tạo shortcut: $ShortcutPath" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Lỗi khi tạo shortcut: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Hàm mở trình duyệt với URL
function Open-Browser {
    param([string]$Url)
    try {
        Write-ColorOutput "Đang mở trình duyệt..." "Yellow"
        Start-Process $Url
        Write-ColorOutput "Đã mở trình duyệt với URL: $Url" "Green"
    }
    catch {
        Write-ColorOutput "Lỗi khi mở trình duyệt: $($_.Exception.Message)" "Red"
    }
}

# Main script
Clear-Host
Write-ColorOutput "==============================================" "Cyan"
Write-ColorOutput "COMFORT CLIPBOARD PRO INSTALLATION SCRIPT" "Cyan"
Write-ColorOutput "==============================================" "Cyan"
Write-Host ""

# Hiển thị các ổ đĩa có sẵn
$availableDrives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} | Select-Object -ExpandProperty Name
Write-ColorOutput "Các ổ đĩa có sẵn: $($availableDrives -join ', ')" "Yellow"

# Nhập ổ đĩa từ người dùng
do {
    $driveLetter = Read-Host "Nhập ổ đĩa để cài đặt (ví dụ: C, D, E...)"
    $driveLetter = $driveLetter.Trim().ToUpper()
    
    if (-not (Test-ValidDrive $driveLetter)) {
        Write-ColorOutput "Ổ đĩa '$driveLetter' không hợp lệ hoặc không tồn tại!" "Red"
        Write-ColorOutput "Vui lòng nhập lại." "Red"
    }
} while (-not (Test-ValidDrive $driveLetter))

# Tạo đường dẫn đầy đủ
$installPath = "${driveLetter}:\Comfort Clipboard Pro"
$exePath = Join-Path $installPath "Comfort.Clipboard.Pro.exe"
$downloadUrl = "https://github.com/ghostminhtoan/private/releases/download/MMT/Comfort.Clipboard.Pro.exe"
$donateUrl = "https://tinyurl.com/mmtdonate"

Write-Host ""
Write-ColorOutput "Đường dẫn cài đặt: $installPath" "Green"

# Tạo thư mục nếu chưa tồn tại
if (-not (Test-Path $installPath)) {
    try {
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
        Write-ColorOutput "Đã tạo thư mục: $installPath" "Green"
    }
    catch {
        Write-ColorOutput "Lỗi khi tạo thư mục: $($_.Exception.Message)" "Red"
        exit 1
    }
}

# Tải file
$downloadSuccess = Download-File -Url $downloadUrl -OutputPath $exePath

if ($downloadSuccess) {
    # Tạo shortcut trên Public Desktop
    $publicDesktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
    $desktopShortcutPath = Join-Path $publicDesktopPath "Comfort Clipboard Pro.lnk"
    Create-Shortcut -SourceExe $exePath -ShortcutPath $desktopShortcutPath -Description "Comfort Clipboard Pro Application"
    
    # Tạo shortcut trong Start Menu Programs
    $startMenuPath = [Environment]::GetFolderPath("CommonPrograms")
    $startMenuShortcutPath = Join-Path $startMenuPath "Comfort Clipboard Pro.lnk"
    Create-Shortcut -SourceExe $exePath -ShortcutPath $startMenuShortcutPath -Description "Comfort Clipboard Pro Application"
    
    # Chạy file
    try {
        Write-ColorOutput "Đang khởi chạy chương trình..." "Yellow"
        Start-Process -FilePath $exePath
        Write-ColorOutput "Chương trình đã được khởi chạy thành công!" "Green"
        
        # Hiển thị thông điệp donate
        Write-Host ""
        Write-ColorOutput "==============================================" "Cyan"
        Write-ColorOutput "THÔNG ĐIỆP QUAN TRỌNG" "Cyan"
        Write-ColorOutput "==============================================" "Cyan"
        Write-ColorOutput "Nếu cảm thấy chương trình hữu ích," "Yellow"
        Write-ColorOutput "xin hãy donate gói snack hoặc cốc cà phê cho tác giả" "Yellow"
        Write-Host ""
        
        # Mở trình duyệt với trang donate
        Write-ColorOutput "Đang mở trang donate..." "Yellow"
        Start-Sleep -Seconds 2
        Open-Browser -Url $donateUrl
        
        Write-Host ""
        Write-ColorOutput "Cài đặt hoàn tất! Cảm ơn bạn đã sử dụng!" "Green"
    }
    catch {
        Write-ColorOutput "Lỗi khi khởi chạy chương trình: $($_.Exception.Message)" "Red"
    }
}
else {
    Write-ColorOutput "Không thể hoàn tất cài đặt do lỗi tải file." "Red"
}

# Tạm dừng để người dùng có thể đọc thông báo
Write-Host ""
Write-ColorOutput "Nhấn Enter để thoát..." "Gray" -NoNewline
Read-Host
