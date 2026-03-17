param (
    $ChocoPackagesPath = (Resolve-Path "setup/packages.config").Path,
    $ChocoInstallUri = "https://community.chocolatey.org/install.ps1",
    $ChocoOutputDir = $PSScriptRoot,
    $ChocoPackagesDir = (Resolve-Path "setup/packages").Path,
    $WinUtilsPath = (Resolve-Path "setup/winutils.config.json").Path,
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
    # PowerShell executable
    $ps = (Get-Command powershell).Source

    # Configure Windows tweaks
    # This script takes control of the console, so launch in a new window
    Start-Process $ps -ArgumentList "-Command", "& ([ScriptBlock]::Create((Invoke-RestMethod $WinUtilsUri))) -Config '$((Resolve-Path $WinUtilsPath).Path)' -Run -Noui" -Wait
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