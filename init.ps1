param (
    $ScriptPath = "https://raw.githubusercontent.com/DevOpsJeremy/dotfiles.win/refs/heads/init/init.ps1"
)

# Check if admin
$winId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$winPrincipal = [System.Security.Principal.WindowsPrincipal]::new($winId)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $winPrincipal.IsInRole($adminRole)) {
    $ps = (Get-Command powershell).Source
    Start-Process $ps -ArgumentList "-NoExit", "-Command", "Invoke-RestMethod '$ScriptPath' | Invoke-Expression" -Verb RunAs
}

# Install Chocolatey if not already
try {
    Get-Command choco -ErrorAction Stop | Out-Null
} catch {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

echo Done