param (
    $Owner = "DevOpsJeremy",
    $Repo = "dotfiles.win",
    $Branch = "init",
    $ScriptPath = "init.ps1",
    $PackagesPath = "packages.config",
    $WinUtilsPath = "winutils.config.json",
    $ChocoInstallUri = "https://community.chocolatey.org/install.ps1"
)
#region Functions
function checkAdmin {
    $winId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $winPrincipal = [System.Security.Principal.WindowsPrincipal]::new($winId)
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    return $winPrincipal.IsInRole($adminRole)
}
function ghUrlRaw {
    param (
        $p,
        $o = $script:Owner,
        $r = $script:Repo,
        $b = $script:Branch
    )
    return "https://raw.githubusercontent.com/{0}/{1}/refs/heads/{2}/{3}" -f $o, $r, $b, $p
}
#endregion Functions

$scriptUri = ghUrlRaw $ScriptPath

# Check if admin
$isAdmin = checkAdmin

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

# Install Chocolatey packages
$packagesUri = ghUrlRaw $PackagesPath
$packagesFileName = [IO.Path]::GetFileName($PackagesPath)
$packagesFilePath = Join-Path ([IO.Path]::GetTempPath()) $packagesFileName
Invoke-RestMethod $packagesUri -OutFile $packagesFilePath
choco install -y $packagesFilePath

# Configure Windows tweaks
$winutilsUri = ghUrlRaw $WinUtilsPath
$winutilsFileName = [IO.Path]::GetFileName($WinUtilsPath)
$winutilsFilePath = Join-Path ([IO.Path]::GetTempPath()) $winutilsFileName
& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Config $winutilsFilePath -Run