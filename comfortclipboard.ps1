# PowerShell script de tai va cai dat Comfort Clipboard Pro

# Ham hien thi thong bao mau sac
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Ham kiem tra o dia hop le
function Test-ValidDrive {
    param([string]$Drive)
    $availableDrives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} | Select-Object -ExpandProperty Name
    return $availableDrives -contains $Drive.Trim(':').ToUpper()
}

# Ham tai file
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath
    )
    try {
        Write-ColorOutput "Dang tai file tu $Url..." "Yellow"
        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath -UseBasicParsing
        Write-ColorOutput "Tai file thanh cong: $OutputPath" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Loi khi tai file: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Ham mo trinh duyet voi URL
function Open-Browser {
    param([string]$Url)
    try {
        Write-ColorOutput "Dang mo trinh duyet..." "Yellow"
        Start-Process $Url
        Write-ColorOutput "Da mo trinh duyet voi URL: $Url" "Green"
    }
    catch {
        Write-ColorOutput "Loi khi mo trinh duyet: $($_.Exception.Message)" "Red"
    }
}

# Main script
Clear-Host
Write-ColorOutput "==============================================" "Cyan"
Write-ColorOutput "COMFORT CLIPBOARD PRO INSTALLATION SCRIPT" "Cyan"
Write-ColorOutput "==============================================" "Cyan"
Write-Host ""

# Hien thi cac o dia co san
$availableDrives = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} | Select-Object -ExpandProperty Name
Write-ColorOutput "Cac o dia co san: $($availableDrives -join ', ')" "Yellow"

# Nhap o dia tu nguoi dung
do {
    $driveLetter = Read-Host "Nhap o dia de cai dat (vi du: C, D, E...)"
    $driveLetter = $driveLetter.Trim().ToUpper()
    
    if (-not (Test-ValidDrive $driveLetter)) {
        Write-ColorOutput "O dia '$driveLetter' khong hop le hoac khong ton tai!" "Red"
        Write-ColorOutput "Vui long nhap lai." "Red"
    }
} while (-not (Test-ValidDrive $driveLetter))

# Tao duong dan day du
$installPath = "${driveLetter}:\Comfort Clipboard Pro"
$exePath = Join-Path $installPath "Comfort.Clipboard.Pro.exe"
$downloadUrl = "https://github.com/ghostminhtoan/private/releases/download/MMT/Comfort.Clipboard.Pro.exe"
$donateUrl = "https://tinyurl.com/mmtdonate"

Write-Host ""
Write-ColorOutput "Duong dan cai dat: $installPath" "Green"

# Tao thu muc neu chua ton tai
if (-not (Test-Path $installPath)) {
    try {
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
        Write-ColorOutput "Da tao thu muc: $installPath" "Green"
    }
    catch {
        Write-ColorOutput "Loi khi tao thu muc: $($_.Exception.Message)" "Red"
        exit 1
    }
}

# Tai file
$downloadSuccess = Download-File -Url $downloadUrl -OutputPath $exePath

if ($downloadSuccess) {
    # Chay file
    try {
        Write-ColorOutput "Dang khoi chay chuong trinh..." "Yellow"
        Start-Process -FilePath $exePath
        Write-ColorOutput "Chuong trinh da duoc khoi chay thanh cong!" "Green"
        
        # Hien thi thong diep donate
        Write-Host ""
        Write-ColorOutput "==============================================" "Cyan"
        Write-ColorOutput "THONG DIEP QUAN TRONG" "Cyan"
        Write-ColorOutput "==============================================" "Cyan"
        Write-ColorOutput "Neu cam thay chuong trinh huu ich," "Yellow"
        Write-ColorOutput "xin hay donate goi snack hoac coc ca phe cho tac gia" "Yellow"
        Write-Host ""
        
        # Mo trinh duyet voi trang donate
        Write-ColorOutput "Dang mo trang donate..." "Yellow"
        Start-Sleep -Seconds 2
        Open-Browser -Url $donateUrl
        
        Write-Host ""
        Write-ColorOutput "Cai dat hoan tat! Cam on ban da su dung!" "Green"
    }
    catch {
        Write-ColorOutput "Loi khi khoi chay chuong trinh: $($_.Exception.Message)" "Red"
    }
}
else {
    Write-ColorOutput "Khong the hoan tat cai dat do loi tai file." "Red"
}

# Tam dung de nguoi dung co the doc thong bao
Write-Host ""
Write-ColorOutput "Nhan Enter de thoat..." "Gray" -NoNewline
Read-Host
