$fileLocation = (Get-Command winget).Source | Select -First 1

$ErrorActionPreference = 'Stop'

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'everything'

  file         = $fileLocation
  silentArgs    = "uninstall --silent --force --purge --disable-interactivity `"Windows App`""
  validExitCodes= @(0)
}

Uninstall-ChocolateyPackage @packageArgs
