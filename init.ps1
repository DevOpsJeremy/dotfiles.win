param (
    $Owner = "DevOpsJeremy",
    $Repo = "dotfiles.win"
    $Branch = "init",
    $ScriptPath = "init.ps1",
    $ChocoInstallUri = "https://community.chocolatey.org/install.ps1"
)
$scriptUri = "https://raw.githubusercontent.com/{0}/{1}/refs/heads/{2}/{3}" -f $Owner, $Repo, $Branch, $ScriptPath

# Check if admin
$winId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$winPrincipal = [System.Security.Principal.WindowsPrincipal]::new($winId)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$isAdmin = $winPrincipal.IsInRole($adminRole)

$ps = (Get-Command powershell).Source
if (-not $isAdmin) {
    Start-Process $ps -ArgumentList "-Command", "Invoke-RestMethod '$scriptUri' | Invoke-Expression"
}

# Install Chocolatey if not already
try {
    Get-Command choco -ErrorAction Stop | Out-Null
} catch {
    Invoke-RestMethod $ChocoInstallUri | Invoke-Expression
}

