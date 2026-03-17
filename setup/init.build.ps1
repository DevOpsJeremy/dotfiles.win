param (
    $ChocoPackagesPath = (Resolve-Path "packages.config").Path,
    $ChocoInstallUri = "https://community.chocolatey.org/install.ps1",
    $ChocoOutputDir = $PSScriptRoot,
    $ChocoPackagesDir = (Resolve-Path "packages").Path,
    $WinUtilsConfig = (Resolve-Path "winutils.config.json").Path,
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

task setup {
    echo "hello world"
    $ChocoPackagesPath
}