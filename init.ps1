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
        $TempDirName = 'repo-temp',
        $destName = $(Join-Path $script:LocalRepoRoot $script:Repo),
        $r = $script:Repo,
        $b = $script:Branch
    )
    Begin {
        # Get the temp directory to save our files
        $tmp = [IO.Path]::GetTempPath()
        $destDir = Join-Path $tmp $TempDirName
        New-Item $destDir -ItemType Directory -Force | Out-Null
        $repoDestName = "{0}-{1}" -f $r, $b
        $repoDestPath = Join-Path $destDir $repoDestName
        $url = ghUrlZip
        $tmpFile = Join-Path $destDir "$TempDirName.zip"
    }
    Process {
        Invoke-RestMethod $url -OutFile $tmpFile
        Expand-Archive $tmpFile -DestinationPath $destDir -Force
        return Move-Item $repoDestPath $destName -PassThru -Force
    }
    End {
        Remove-Item $destDir -ErrorAction SilentlyContinue -Recurse -Force
    }
}
#endregion Functions

$localRepoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath((Join-Path $LocalRepoRoot $Repo))

# If repo path exists and is a file, fail
if (Test-Path $localRepoPath -PathType Leaf) {
    throw "The path '$localRepoPath' exists and is not a directory"
    exit 1
}

# If repo directory exists, prompt user before deleting and recreating
if (Test-Path $localRepoPath) {
    $no = 1
    $answer = $Host.UI.PromptForChoice(
        "Rebuild local repo?", # Caption
        "The '$localRepoPath' directory exists. Recreate?", # Message
        @('&Yes', '&No'), # Choices
        $no # Default: No
    )

    if ($answer -eq $no) {
        Write-Host "Exiting."
        exit
    }

    Remove-Item $localRepoPath -Force -Recurse
}

# Download the repo
$repoPath = getRepo

# PowerShell executable
$ps = (Get-Command powershell).Source

$scriptPathFull = Join-Path $repoPath $ScriptPath
Start-Process $ps -ArgumentList "-File", "$scriptPathFull", "-NoExit" -Verb RunAs