param (
    $ChocoPackagesPath = (Join-Path $PSScriptRoot "packages.config"),
    $ChocoInstallUri = "https://community.chocolatey.org/install.ps1",
    $ChocoOutputDir = $PSScriptRoot,
    $ChocoPackagesDir = (Join-Path $PSScriptRoot "packages"),
    $WinUtilsConfig = (Join-Path $PSScriptRoot "winutils.config.json"),
    $WinUtilsUri = "https://christitus.com/win"
)

function chocoPack {
    param (
        $Root,
        $OutputDirectory,
        [switch] $Parallel,
        [int] $MaxRunspaces = 5
    )
    Begin {
        $rsp = [runspacefactory]::CreateRunspacePool()
        $rsp.SetMaxRunspaces($MaxRunspaces) | Out-Null
        $rsp.Open()
        $outList = [System.Collections.ArrayList]::new()
        $psInstances = [System.Collections.ArrayList]::new()
    }
    Process {
        Get-ChildItem -Path $Root -Filter "*.nuspec" -File -Recurse |
            ForEach-Object {
                $ps = [powershell]::Create().
                    AddCommand("choco").
                    AddArgument("pack").
                    AddArgument($_.FullName)

                if ($OutputDirectory) {
                    $ps = $ps.
                        AddArgument('--output').
                        AddArgument($outputDir)
                }

                $ps.RunspacePool = $rsp
                if ($Parallel) {
                    $outList.Add($ps.BeginInvoke()) | Out-Null
                    $psInstances.Add($ps) | Out-Null
                } else {
                    $ps.Invoke()
                }
            }
        
        if (-not $Parallel) { return }

        do { Start-Sleep -Milliseconds 100 }
        while ($outList.IsCompleted -contains $false)

        for ($i = 0; $i -lt $outList.Count; $i++) {
            $handle = $outList[$i]
            $ps     = $psInstances[$i]

            $ps.EndInvoke($handle)

            $ps.Dispose()
        }
    }
    End {
        $rsp.Close()
    }
}

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
    chocoPack -Root $ChocoPackagesDir -OutputDirectory $ChocoOutputDir -Parallel
}

task choco-install {
    # Install Chocolatey packages
    choco install -y $ChocoPackagesPath
}

task choco-build choco-pack, choco-install

task setup install-chocolatey, choco-build, winutils
