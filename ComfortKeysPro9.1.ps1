# PowerShell script để tải và cài đặt Comfort Clipboard Pro
# Tạo shortcut trên Desktop công cộng, Start Menu và Startup

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

# Hàm mô phỏng phím Windows + Insert
function Invoke-WindowsInsert {
    try {
        Write-ColorOutput "Đang mở Clipboard bằng Windows + Insert..." "Yellow"
        
        # Sử dụng SendKeys để mô phỏng tổ hợp phím
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.SendKeys]::SendWait('^{INSERT}')
        
        Write-ColorOutput "Đã gửi tổ hợp phím Windows + Insert" "Green"
    }
    catch {
        Write-ColorOutput "Lỗi khi gửi tổ hợp phím: $($_.Exception.Message)" "Red"
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
    
    # Tạo shortcut trong Startup để chạy cùng Windows
    $startupPath = [Environment]::GetFolderPath("CommonStartup")
    $startupShortcutPath = Join-Path $startupPath "Comfort Clipboard Pro.lnk"
    Create-Shortcut -SourceExe $exePath -ShortcutPath $startupShortcutPath -Description "Comfort Clipboard Pro Application - Run at Startup"
    
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
        
        # Đợi 5 giây trước khi mở trình duyệt
        Write-ColorOutput "Đang đợi 5 giây trước khi mở trang donate..." "Yellow"
        
        # Hiển thị đồng hồ đếm ngược
        for ($i = 5; $i -gt 0; $i--) {
            Write-Host "Mở trình duyệt sau $i giây..." -ForegroundColor Gray
            Start-Sleep -Seconds 1
        }
        
        # Mở trình duyệt với trang donate
        Open-Browser -Url $donateUrl
        
        # Đợi thêm 2 giây trước khi mô phỏng phím
        Start-Sleep -Seconds 2
        
        # Mô phỏng tổ hợp phím Windows + Insert để mở clipboard
        Invoke-WindowsInsert
        
        Write-Host ""
        Write-ColorOutput "Cài đặt hoàn tất! Cảm ơn bạn đã sử dụng!" "Green"
        Write-ColorOutput "Chương trình sẽ tự động khởi chạy cùng Windows." "Green"
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
