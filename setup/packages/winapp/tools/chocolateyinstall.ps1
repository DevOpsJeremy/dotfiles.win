$ErrorActionPreference = 'Stop'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$fileLocation = (Get-Command winget).Source | Select -First 1
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  file         = $fileLocation

  softwareName  = 'winapp'
  silentArgs    = "install --force --accept-source-agreements --disable-interactivity --silent --accept-package-agreements `"Windows App`" --source winget"

  validExitCodes= @(0)
}
Install-ChocolateyInstallPackage @packageArgs
