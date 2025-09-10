using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net.Http;
using System.Reflection;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
namespace MMT_AIO_tool
{
    public partial class MainWindow : Window
    {
        private static readonly HttpClient httpClient = new HttpClient();
        public MainWindow()
        {
            InitializeComponent();
        }
        private void BtnSelectAll_Click(object sender, RoutedEventArgs e)
        {
            foreach (var child in CheckBoxPanel.Children)
            {
                if (child is CheckBox chk) chk.IsChecked = true;
            }
        }
        private void BtnSelectNone_Click(object sender, RoutedEventArgs e)
        {
            foreach (var child in CheckBoxPanel.Children)
            {
                if (child is CheckBox chk) chk.IsChecked = false;
            }
        }
        private async void BtnInstall_Click(object sender, RoutedEventArgs e)
        {
            string tempPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Temp", "MMTPC");
            Directory.CreateDirectory(tempPath);
            // Disable the install button to prevent multiple clicks
            btnInstall.IsEnabled = false;
            btnInstall.Content = "Installing...";
            try
            {
                await InstallApplicationAsync(chkEdge, "MicrosoftEdgeSetup.exe", "");
                await InstallApplicationAsync(chkChrome, "ChromeSetup online installer.exe", "");
                await InstallApplicationAsync(chkComfortKeys, "Comfort Keys Pro 9.5 portable by MMT Windows Tech.exe", "");
                // Install Useful Tools from URL
                await InstallApplicationAsync(chkVcredist, "vcredist all in one by MMT Windows Tech.exe", "");
                await InstallApplicationAsync(chkDirectx, "DirectX_Redist_Repack_x86_x64.exe", "/y");
                await InstallApplicationAsync(chkFastStone, "FastStone Capture 11.0.exe", "/silent");
                await InstallApplicationAsync(chkFoxit, "FoxitPDFReader20233_enu_Setup_Prom.exe", "/silent");
                await InstallApplicationAsync(chkHoneyView, "HONEYVIEW-SETUP.exe", "/S");
                await InstallApplicationAsync(chkHibit, "HiBitUninstaller-setup-3.1.62.exe", "/silent");
                await InstallApplicationAsync(chkNotepad, "npp.8.5.6.Installer.x64.exe", "/S");
                await InstallApplicationAsync(chkPoweriso, "PowerISO 8.9.exe", "/silent");
                await InstallApplicationAsync(chkTeracopy, "TeraCopy.Pro.v3.17.0.0.exe", "/S");
                await InstallApplicationAsync(chkUnlocker, "Unlocker1.9.2.exe", "/S");
                await InstallApplicationAsync(chkActivator, "Microsoft - Windows Activation.exe", "");
                await InstallApplicationAsync(chkWinrar, "WinRAR.7.13.exe", "/VERYSILENT /I /EN");
                await InstallApplicationAsync(chkCodec, "ADVANCED_Codecs_v1650.exe", "/S /v/qn");
                await InstallApplicationAsync(chkIDM, "IDM.exe", "");
                // Install PotPlayer from URL
                await InstallPotPlayerAsync();
                // Install Useful Tools from URL
                await InstallUsefulToolsAsync();
                await InstallApplicationAsync(chk3DPNet, "3DP_Net_v2101.exe", "");
                await InstallApplicationAsync(chk3DPChip, "3DP_Chip_v2508.exe", "");
                await InstallApplicationAsync(chkFonts, "Gouenji Fansub Fonts V3.exe", "/passive /norestart");
                MessageBox.Show("Installation process completed!", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"An error occurred during installation: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            finally
            {
                // Re-enable the install button
                btnInstall.IsEnabled = true;
                btnInstall.Content = "Install";
            }
        }
        private async Task InstallApplicationAsync(CheckBox checkBox, string resourceName, string arguments)
        {
            if (checkBox.IsChecked != true) return;
            await Task.Run(() => {
                try
                {
                    string fullResourceName = $"MMT_AIO_tool.{resourceName}";
                    using (var resource = Assembly.GetExecutingAssembly().GetManifestResourceStream(fullResourceName))
                    {
                        if (resource == null)
                        {
                            // Debug: List all embedded resources
                            string[] resourceNames = Assembly.GetExecutingAssembly().GetManifestResourceNames();
                            string resourceList = string.Join("\n", resourceNames);
                            Dispatcher.Invoke(() => {
                                MessageBox.Show($"Resource {fullResourceName} not found!\nAvailable resources:\n{resourceList}",
                                    "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            });
                            return;
                        }
                        string tempPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Temp", "MMTPC", resourceName);
                        using (var file = new FileStream(tempPath, FileMode.Create, FileAccess.Write))
                        {
                            resource.CopyTo(file);
                        }
                        ProcessStartInfo psi = new ProcessStartInfo
                        {
                            FileName = tempPath,
                            Arguments = arguments,
                            UseShellExecute = true,
                            CreateNoWindow = arguments.Contains("/silent") || arguments.Contains("/S") || arguments.Contains("/VERYSILENT")
                        };
                        using (var process = Process.Start(psi))
                        {
                            process.WaitForExit();
                        }
                    }
                }
                catch (Exception ex)
                {
                    Dispatcher.Invoke(() => {
                        MessageBox.Show($"Error installing {resourceName}: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    });
                }
            });
        }
        
        private async Task InstallPotPlayerAsync()
        {
            if (chkPotplayer.IsChecked != true) return;
            try
            {
                string url = "https://t1.daumcdn.net/potplayer/PotPlayer/Version/Latest/PotPlayerSetup64.exe";
                string tempPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Temp", "MMTPC", "PotPlayerSetup64.exe");
                // Download the file
                using (var response = await httpClient.GetAsync(url))
                {
                    response.EnsureSuccessStatusCode();
                    using (var fileStream = new FileStream(tempPath, FileMode.Create, FileAccess.Write))
                    {
                        await response.Content.CopyToAsync(fileStream);
                    }
                }
                // Install the downloaded file
                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = tempPath,
                    Arguments = "/S",
                    UseShellExecute = true,
                    CreateNoWindow = true
                };
                using (var process = Process.Start(psi))
                {
                    await Task.Run(() => process.WaitForExit());
                }
            }
            catch (Exception ex)
            {
                Dispatcher.Invoke(() => {
                    MessageBox.Show($"Error downloading/installing PotPlayer: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                });
            }
        }
        private async Task InstallUsefulToolsAsync()
        {
            if (chkUsefulTools.IsChecked != true) return;
            try
            {
                string url = "https://github.com/ghostminhtoan/MMT/releases/download/v1.0/Useful.Tools.exe";
                string tempPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Temp", "MMTPC", "Useful.Tools.exe");
                // Download the file
                using (var response = await httpClient.GetAsync(url))
                {
                    response.EnsureSuccessStatusCode();
                    using (var fileStream = new FileStream(tempPath, FileMode.Create, FileAccess.Write))
                    {
                        await response.Content.CopyToAsync(fileStream);
                    }
                }
                // Install the downloaded file
                ProcessStartInfo psi = new ProcessStartInfo
                {
                    FileName = tempPath,
                    Arguments = "/passive",
                    UseShellExecute = true,
                    CreateNoWindow = true
                };
                using (var process = Process.Start(psi))
                {
                    await Task.Run(() => process.WaitForExit());
                }
            }
            catch (Exception ex)
            {
                Dispatcher.Invoke(() => {
                    MessageBox.Show($"Error downloading/installing Useful Tools: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                });
            }
        }
        private void BtnDonate_Click(object sender, RoutedEventArgs e)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "https://tinyurl.com/mmtdonate",
                UseShellExecute = true
            });
        }
        protected override void OnClosed(EventArgs e)
        {
            httpClient?.Dispose();
            base.OnClosed(e);
        }
    }
}