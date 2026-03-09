param (
    $Owner = "DevOpsJeremy",
    $Repo = "dotfiles.win",
    $LocalRepoRoot = "$env:USERPROFILE/repos",
    $Branch = "init",
    $ScriptPath = "setup/setup.ps1"
)
#region Functions
function ghUrlZip {
    param (
        $uriHost = "https://github.com",
        $o = $script:Owner,
        $r = $script:Repo,
        $b = $script:Branch
    )
    return "{0}/{1}/{2}/archive/refs/heads/{3}.zip" -f $uriHost, $o, $r, $b
}
function getRepo {
    param (
        $outDir = $PWD.Path,
        $destName = $(Join-Path $script:LocalRepoRoot $Repo),
        $r = $script:Repo,
        $b = $script:Branch
    )
    Begin {
        $destDir = if (Test-Path $outDir -PathType Container) {
            Get-Item (Resolve-Path $outDir).Path
        } elseif (Test-Path $outDir -PathType Leaf) {
            throw "The path '$outDir' exists and is not a directory"
        } else {
            New-Item $outDir -ItemType Directory -Force
        }
        $repoDestName = "{0}-{1}" -f $r, $b
        $repoDestPath = Join-Path $destDir $repoDestName
        $url = ghUrlZip
        $tmpFile = ([IO.Path]::GetTempFileName()) + ".zip"
    }
    Process {
        Invoke-RestMethod $url -OutFile $tmpFile
        Expand-Archive $tmpFile -DestinationPath $destDir -Force
        return Move-Item $repoDestPath $destName -PassThru -Force
    }
    End {
        Remove-Item $tmpFile -ErrorAction SilentlyContinue -Force
    }
}
#endregion Functions

# Download the repo
$repoPath = getRepo

# PowerShell executable
$ps = (Get-Command powershell).Source

$scriptPathFull = Join-Path $repoPath $ScriptPath
Start-Process $ps -ArgumentList "-File", "$scriptPathFull", "-NoExit" -Verb RunAs