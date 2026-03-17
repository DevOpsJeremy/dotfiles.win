task install-chocolatey {
    # Install Chocolatey if not already
    try {
        Get-Command choco -ErrorAction Stop | Out-Null
    } catch {
        Invoke-RestMethod $Task.Data.ChocoInstallUri | Invoke-Expression
    }
} -Data @{
    ChocoInstallUri = "https://community.chocolatey.org/install.ps1"
}

task winutils {
    # PowerShell executable
    $ps = (Get-Command powershell).Source

    # Configure Windows tweaks
    # This script takes control of the console, so launch in a new window
    Start-Process $ps -ArgumentList "-Command", "& ([ScriptBlock]::Create((Invoke-RestMethod $Task.Data.WinUtilsUri))) -Config '$((Resolve-Path $Task.Data.WinUtilsPath).Path)' -Run -Noui" -Wait
} -Data @{
    WinUtilsUri     = "https://christitus.com/win"
    WinUtilsPath    = Resolve-Path "setup/winutils.config.json"
}

task choco-pack {
    Get-ChildItem -Path $Task.Data.PackagesDir -Filter "*.nuspec" -File -Recurse |
        ForEach-Object {
            choco pack "$($_.FullName)" --outputdirectory "$Task.Data.OutputDirectory"
        }
} -Data @{
    PackagesDir     = Resolve-Path "setup/packages"
    OutputDirectory = $PSScriptRoot
}

task choco-install {
    # Install Chocolatey packages
    choco install -y $Task.Data.PackagesPath
} -Data @{
    PackagesPath = Resolve-Path "setup/packages.config"
}

task setup {
    echo "hello world"
}