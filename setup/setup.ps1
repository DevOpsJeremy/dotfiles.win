param (
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
function packChoco {
    param (
        $PackagesPath = "$($PWD.Path)/packages",
        $OutputDirectory = $PWD.Path
    )
    Get-ChildItem -Path $PackagesPath -Filter "*.nuspec" -File -Recurse |
        ForEach-Object {
            choco pack "$($_.FullName)" --outputdirectory "$OutputDirectory"
        }
}
#endregion Functions

if (-not (checkAdmin)) {
    throw "Script must be ran as admin"
    exit 1
}

$root = Resolve-Path "$($MyInvocation.MyCommand.Source)/../.."
Set-Location $root

Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module InvokeBuild -Scope AllUsers

Invoke-Build setup

# PowerShell executable
$ps = (Get-Command powershell).Source

# Install Chocolatey if not already
try {
    Get-Command choco -ErrorAction Stop | Out-Null
} catch {
    Invoke-RestMethod $ChocoInstallUri | Invoke-Expression
}

# Install Chocolatey packages
choco install -y $PackagesPath

# Configure Windows tweaks
# This script takes control of the console, so launch in a new window
Start-Process $ps -ArgumentList "-Command", "& ([ScriptBlock]::Create((Invoke-RestMethod 'https://christitus.com/win'))) -Config '$((Resolve-Path $WinUtilsPath).Path)' -Run -Noui" -Wait