param (
    $ChocoPackagesPath = (Join-Path $PSScriptRoot "packages.config"),
    $ChocoInstallUri = "https://community.chocolatey.org/install.ps1",
    $ChocoOutputDir = $PSScriptRoot,
    $ChocoPackagesDir = (Join-Path $PSScriptRoot "packages"),
    $WinUtilsConfig = (Join-Path $PSScriptRoot "winutils.config.json"),
    $WinUtilsUri = "https://christitus.com/win"
)

task install-chocolatey {
    # Install Chocolatey if not already
    try {
        Get-Command choco -ErrorAction Stop | Out-Null
    } catch {
        Invoke-RestMethod $ChocoInstallUri | Invoke-Expression
    }
}

task winutils {
    # Configure Windows tweaks
    # This script takes control of the console, so launch in a new instance
    [powershell]::Create().AddScript((
        Invoke-RestMethod $WinUtilsUri
    )).AddParameters(@{
        Config  = $WinUtilsConfig
        Run     = $true
        Noui    = $true
    }).Invoke()
}

task choco-pack {
    Get-ChildItem -Path $ChocoPackagesDir -Filter "*.nuspec" -File -Recurse |
        ForEach-Object {
            choco pack "$($_.FullName)" --outputdirectory "$ChocoOutputDir"
        }
}

task choco-install {
    # Install Chocolatey packages
    choco install -y $ChocoPackagesPath
}

task choco-build choco-pack, choco-install

task init install-chocolatey, choco-build, winutils
