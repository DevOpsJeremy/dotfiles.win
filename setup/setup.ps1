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
