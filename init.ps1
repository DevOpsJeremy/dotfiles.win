param (
    $ScriptPath = "https://raw.githubusercontent.com/DevOpsJeremy/dotfiles.win/refs/heads/init/init.ps1",
    $ChocoInstall = "https://community.chocolatey.org/install.ps1"
)

# Check if admin
$winId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$winPrincipal = [System.Security.Principal.WindowsPrincipal]::new($winId)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$isAdmin = $winPrincipal.IsInRole($adminRole)

if (-not ) {
    $ps = (Get-Command powershell).Source
    Start-Process $ps -ArgumentList "-NoExit", "-Command", "Invoke-RestMethod '$ScriptPath' | Invoke-Expression" -Verb RunAs
}

# Install Chocolatey if not already
try {
    Get-Command choco -ErrorAction Stop | Out-Null
} catch {
    if ($isAdmin) {
        Invoke-RestMethod $ChocoInstall | Invoke-Expression
    } else {
        $ps = (Get-Command powershell).Source
        Start-Process $ps -ArgumentList "-Command", "Invoke-RestMethod '$ChocoInstall' | Invoke-Expression" -Verb RunAs -Wait
        Start-Process $ps -ArgumentList "-Command", "Invoke-RestMethod '$ScriptPath' | Invoke-Expression"
        exit
    }
}

