# IMPORTANT: Before releasing this package, copy/paste the next 2 lines into PowerShell to remove all comments from this file:
#   $f='c:\path\to\thisFile.ps1'
#   gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

## NOTE: In 80-90% of the cases (95% with licensed versions due to Package Synchronizer and other enhancements),
## AutoUninstaller should be able to detect and handle registry uninstalls without a chocolateyUninstall.ps1.
## See https://docs.chocolatey.org/en-us/choco/commands/uninstall
## and https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateypackage

## If this is an MSI, ensure 'softwareName' is appropriate, then clean up comments and you are done.
## If this is an exe, change fileType, silentArgs, and validExitCodes
$fileLocation = (Get-Command winget).Source | Select -First 1

$ErrorActionPreference = 'Stop' # stop on all errors
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'msstore'  #part or all of the Display Name as you see it in Programs and Features. It should be enough to be unique
  file         = $fileLocation
  # fileType      = 'EXE_MSI_OR_MSU' #only one of these: MSI or EXE (ignore MSU for now)
  # MSI
  silentArgs    = "uninstall `"Microsoft Store Developer CLI`""
  validExitCodes= @(0)
  # OTHERS
  # Uncomment matching EXE type (sorted by most to least common)
  #silentArgs   = '/S'           # NSIS
  #silentArgs   = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-' # Inno Setup
  #silentArgs   = '/s'           # InstallShield
  #silentArgs   = '/s /v"/qn"'   # InstallShield with MSI
  #silentArgs   = '/s'           # Wise InstallMaster
  #silentArgs   = '-s'           # Squirrel
  #silentArgs   = '-q'           # Install4j
  #silentArgs   = '-s -u'        # Ghost
  # Note that some installers, in addition to the silentArgs above, may also need assistance of AHK to achieve silence.
  #silentArgs   = ''             # none; make silent with input macro script like AutoHotKey (AHK)
                                 #       https://community.chocolatey.org/packages/autohotkey.portable
  #validExitCodes= @(0) #please insert other valid exit codes here
}

Uninstall-ChocolateyPackage @packageArgs

## OTHER POWERSHELL FUNCTIONS
## https://docs.chocolatey.org/en-us/create/functions
#Uninstall-ChocolateyZipPackage $packageName # Only necessary if you did not unpack to package directory - see https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyzippackage
#Uninstall-ChocolateyEnvironmentVariable - https://docs.chocolatey.org/en-us/create/functions/uninstall-chocolateyenvironmentvariable
#Uninstall-BinFile # Only needed if you used Install-BinFile - see https://docs.chocolatey.org/en-us/create/functions/uninstall-binfile
## Remove any shortcuts you added in the install script.

