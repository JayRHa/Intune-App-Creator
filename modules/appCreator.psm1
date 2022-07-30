<#
.SYNOPSIS
App Creation functions
.DESCRIPTION
App Creation functions
.NOTES
  Author: Jannik Reinhard
#>

##
function Install-IntuneWinAppUtility {
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe" -OutFile "$global:PathSources\IntuneWinAppUtil.exe" | Out-Null
  
    }catch{
      Write-Error "Loading of the IntuneWinAppUtil failed"
      return $false
    }

    return $true
}

function Install-Chocolatey {
    $testchoco = powershell choco -v
    if(-not($testchoco)){
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
}

function Search-ChocolateyApp {
    param (
        [Parameter(Mandatory = $true)]
        [String]$searchText
    )
    $searchList = choco search $searchText
    $version, $searchList = $searchList

    $packages = @()
    
    $searchList | ForEach-Object{
        if($_ -like '*packages found.*'){return $packages}
        $objPackage = $_.Split()
        $package = [PSCustomObject]@{
            Name                  = $objPackage[0]
            Version               = $objPackage[1]
          }
          $packages += $package
    }
}

function Get-AppId {
    param (
        [Parameter(Mandatory = $true)]
        [String]$appName
    )
    $appId = @(Get-MgDeviceAppMgtMobileApp -Filter "DisplayName eq '$appName'")[0].Id
    return $appId
}

function Add-Chocolatey{
    $folder = "$global:PathSources\chocolatey"
    if(-not (Test-Path $folder)) {
        New-Item $folder -Itemtype Directory
    }
    if(-not (Test-Path "$folder\sources")) {
        New-Item "$folder\sources" -Itemtype Directory
    }
    $iconChocolatey = "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"
    if(-not(Test-Path ("$folder\chocolatey.png"))) {
        $imagePath = ("$folder\chocolatey.png")
        [byte[]]$Bytes = [convert]::FromBase64String($iconChocolatey)
        [System.IO.File]::WriteAllBytes($imagePath,$Bytes)
    }

    $global:chocolateyInstallationCommand | Out-File "$folder\sources\install.ps1"
    $global:chocolateyUnInstallationCommand | Out-File "$folder\sources\uninstall.ps1"

    Start-Sleep -Seconds 1.5
    $intuneWinFile = New-IntuneWin32AppPackage -SourceFolder "$folder\sources" -SetupFile "install.ps1" -OutputFolder $folder -IntuneWinAppUtilPath "$global:PathSources\IntuneWinAppUtil.exe"
    $detectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -Path "C:\ProgramData\" -FileOrFolder "chocolatey" -DetectionType "exists"
    $requirementRule = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedOperatingSystem 1607
    $icon = New-IntuneWin32AppIcon -FilePath $imagePath
    $installCommandLine = "powershell.exe -executionpolicy bypass .\install.ps1"
    $uninstallCommandLine = "powershell.exe -executionpolicy bypass .\uninstall.ps1"
    Add-IntuneWin32App -FilePath $intuneWinFile.Path -DisplayName $global:ChocolateyAppName -Publisher 'Chocolatey' -InformationURL 'https://chocolatey.org/' -Description "Chocolatey has the largest online registry of Windows packages. Chocolatey packages encapsulate everything required to manage a particular piece of software into one deployment artifact by wrapping installers, executables, zips, and/or scripts into a compiled package file." -InstallCommandLine $installCommandLine -UninstallCommandLine $uninstallCommandLine -Icon $icon -InstallExperience system -RestartBehavior suppress -DetectionRule $detectionRule -RequirementRule $requirementRule  
    New-Snackbar -Snackbar $WPFSnackbar -Text 'Chocolate App added to Intune'
}

function Add-App {
    param (
        [Parameter(Mandatory = $true)]
        [String]$appName
    )
    $appNameUpper = $appName.substring(0,1).toupper()+$appName.substring(1).tolower() 

    if(Get-AppId -appName $appNameUpper){
        New-Snackbar -Snackbar $WPFSnackbar -Text "$appNameUpper already exist in your tenant"
        return
    }

    $folder = "$global:PathSources\$appName"
    if(-not (Test-Path $folder)) {
        New-Item $folder -Itemtype Directory
    }
    if(-not (Test-Path "$folder\sources")) {
        New-Item "$folder\sources" -Itemtype Directory
    }

    $installCommand = '$appName = "' + $appName + '"' + "`n" + @'
$chocoinstall = Get-Command -Name 'choco' -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object -ExpandProperty Source
Invoke-Expression "cmd.exe /c $chocoInstall Install $appName -y" -ErrorAction Stop
'@
    $installCommand | Out-File "$folder\sources\install.ps1"
    "choco uninstall $appName -y" | Out-File "$folder\sources\uninstall.ps1"
    
    Start-Sleep -Seconds 1.5
    $intuneWinFile = New-IntuneWin32AppPackage -SourceFolder "$folder\sources" -SetupFile "install.ps1" -OutputFolder $folder -IntuneWinAppUtilPath "$global:PathSources\IntuneWinAppUtil.exe"

    $detectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -Path "C:\ProgramData\chocolatey\lib" -FileOrFolder $appName -DetectionType "exists"
    $requirementRule = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedOperatingSystem 1607
    $installCommandLine = "powershell.exe -executionpolicy bypass .\install.ps1"
    $uninstallCommandLine = "powershell.exe -executionpolicy bypass .\uninstall.ps1"

    $appInfo = choco info $appName
    $site = ($appInfo  | Where-Object {$_ -like '*Software Site*'}).Replace(" Software Site: ", "")
    $summary = ($appInfo | Where-Object {$_ -like '*Summary:*'}).Replace(" Summary: ", "")      


    Add-IntuneWin32App -FilePath $intuneWinFile.Path -DisplayName $appNameUpper -Publisher 'Chocolatey' -InformationURL $site -Description $summary -InstallCommandLine $installCommandLine -UninstallCommandLine $uninstallCommandLine -InstallExperience system -RestartBehavior suppress -DetectionRule $detectionRule -RequirementRule $requirementRule  
    

    $dependency = New-IntuneWin32AppDependency -ID $global:ChocolateyAppId -DependencyType "AutoInstall"
    $appId = Get-AppId -appName $appNameUpper
    Add-IntuneWin32AppDependency -ID $appId -Dependency $dependency
    New-Snackbar -Snackbar $WPFSnackbar -Text "$appNameUpper is added to your tenant"
}



$global:chocolateyInstallationCommand = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
$global:chocolateyUnInstallationCommand = @'
$VerbosePreference = 'Continue'
if (-not $env:ChocolateyInstall) {
    $message = @(
        "The ChocolateyInstall environment variable was not found."
        "Chocolatey is not detected as installed. Nothing to do."
    ) -join "`n"

    Write-Warning $message
    return
}

if (-not (Test-Path $env:ChocolateyInstall)) {
    $message = @(
        "No Chocolatey installation detected at '$env:ChocolateyInstall'."
        "Nothing to do."
    ) -join "`n"

    Write-Warning $message
    return
}

<#
    Using the .NET registry calls is necessary here in order to preserve environment variables embedded in PATH values;
    Powershell's registry provider doesn't provide a method of preserving variable references, and we don't want to
    accidentally overwrite them with absolute path values. Where the registry allows us to see "%SystemRoot%" in a PATH
    entry, PowerShell's registry provider only sees "C:\Windows", for example.
#>
$userKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment')
$userPath = $userKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

$machineKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\ControlSet001\Control\Session Manager\Environment\')
$machinePath = $machineKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

$backupPATHs = @(
    "User PATH: $userPath"
    "Machine PATH: $machinePath"
)
$backupFile = "C:\PATH_backups_ChocolateyUninstall.txt"
$backupPATHs | Set-Content -Path $backupFile -Encoding UTF8 -Force

$warningMessage = @"
    This could cause issues after reboot where nothing is found if something goes wrong.
    In that case, look at the backup file for the original PATH values in '$backupFile'.
"@

if ($userPath -like "*$env:ChocolateyInstall*") {
    Write-Verbose "Chocolatey Install location found in User Path. Removing..."
    Write-Warning $warningMessage

    $newUserPATH = @(
        $userPath -split [System.IO.Path]::PathSeparator |
            Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
    ) -join [System.IO.Path]::PathSeparator

    # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
    # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
    $userKey.SetValue('PATH', $newUserPATH, 'ExpandString')
}

if ($machinePath -like "*$env:ChocolateyInstall*") {
    Write-Verbose "Chocolatey Install location found in Machine Path. Removing..."
    Write-Warning $warningMessage

    $newMachinePATH = @(
        $machinePath -split [System.IO.Path]::PathSeparator |
            Where-Object { $_ -and $_ -ne "$env:ChocolateyInstall\bin" }
    ) -join [System.IO.Path]::PathSeparator

    # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
    # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
    $machineKey.SetValue('PATH', $newMachinePATH, 'ExpandString')
}

# Adapt for any services running in subfolders of ChocolateyInstall
$agentService = Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue
if ($agentService -and $agentService.Status -eq 'Running') {
    $agentService.Stop()
}
# TODO: add other services here

Remove-Item -Path $env:ChocolateyInstall -Recurse -Force -WhatIf

'ChocolateyInstall', 'ChocolateyLastPathUpdate' | ForEach-Object {
    foreach ($scope in 'User', 'Machine') {
        [Environment]::SetEnvironmentVariable($_, [string]::Empty, $scope)
    }
}

$machineKey.Close()
$userKey.Close()
'@