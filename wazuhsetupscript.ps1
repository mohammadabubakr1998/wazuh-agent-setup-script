

# PowerShell script to download, setup, and start Wazuh agent

# Define variables
$installer_url = "https://packages.wazuh.com/4.x/windows/wazuh-agent-4.8.2-1.msi" # Example URL, replace with actual installer URL
$Wazuh_msi = "$env:TEMP\wazuh-agent.msi"
$Wazuh_service = "WazuhSvc"
$Wazuh_manager_ip = "172.16.9.11" # Replace with your Wazuh manager IP
Display-Message "$Wazuh_manager_ip"

# Function to display messages
function Display-Message {
    param (
        [string]$message
    )
    Write-Host $message -ForegroundColor Green
}

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Display-Message "This script requires Administrator privileges. Please run as Administrator."
    exit
}

# Download Wazuh Agent installer
try {
    Display-Message "Downloading Wazuh Agent installer..."
    $downloader = New-Object System.Net.WebClient
    $downloader.DownloadFile($installer_url, $Wazuh_msi)
    Display-Message "Download completed successfully."
} catch {
    Display-Message "Error downloading the Wazuh Agent installer: $_"
    exit
}

# Install Wazuh Agent
try {
    Display-Message "Installing Wazuh Agent..."
    Start-Process msiexec.exe -ArgumentList "/i `"$Wazuh_msi`" /qn WAZUH_MANAGER=`"$Wazuh_manager_ip`"" -Wait -NoNewWindow
    Display-Message "Installation completed successfully."
} catch {
    Display-Message "Error installing the Wazuh Agent: $_"
    exit
}

# Start Wazuh Agent service
try {
    Display-Message "Starting Wazuh Agent service..."
    Start-Service -Name $Wazuh_service -ErrorAction Stop
    Display-Message "Wazuh Agent service started successfully."
} catch {
    Display-Message "Error starting the Wazuh Agent service: $_"
}


# Step 7: Launch Wazuh Agent GUI as Administrator
$wazuhGuiPath = "C:\Program Files (x86)\ossec-agent\win32ui.exe"  # Adjust the path if necessary
Write-Host "Launching Wazuh Agent GUI as Administrator..." -ForegroundColor Cyan
if (Test-Path $wazuhGuiPath) {
    try {
        # Start-Process -FilePath $wazuhGuiPath -Verb RunAsAdministrator -ErrorAction Stop
	Start-Process powershell -WorkingDirectory "C:\Program Files (x86)\ossec-agent" -ArgumentList 'Start-Process win32ui.exe -Verb Runas'
        Write-Host "Wazuh Agent GUI launched successfully." -ForegroundColor Green
    } catch {
        Write-Host "Failed to launch Wazuh Agent GUI: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Wazuh Agent GUI not found at $wazuhGuiPath. Please check the installation." -ForegroundColor Red
    exit 1
}
