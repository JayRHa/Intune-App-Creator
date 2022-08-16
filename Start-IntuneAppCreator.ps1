<#
Version: 1.0
Author: Jannik Reinhard (jannikreinhard.com)
Script: Start-IntuneAppCreator
Description:
Add cocolatey apps easy to intune
Release notes:
1.0 :
- Init
1.1 :
- Only install 'Microsoft.Graph.Devices.CorporateManagement'
- Minor changes
- Bug fixes
#> 
###########################################################################################################
############################################ Functions ####################################################
###########################################################################################################
function Get-MessageScreen{
    param (
        [Parameter(Mandatory = $true)]
        [String]$xamlPath
    )
    
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    Add-Type -AssemblyName PresentationFramework
    [xml]$xaml = Get-Content $xamlPath
    $global:messageScreen = ([Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml)))
    $global:messageScreenTitle = $global:messageScreen.FindName("TextMessageHeader")
    $global:messageScreenText = $global:messageScreen.FindName("TextMessageBody")
    $global:button1 = $global:messageScreen.FindName("ButtonMessage1")
    $global:button2 = $global:messageScreen.FindName("ButtonMessage2")

    $global:messageScreenTitle.Text = "Initializing Intune App Creator"
    $global:messageScreenText.Text = "Starting Intune App Creator"
    [System.Windows.Forms.Application]::DoEvents()
    $global:messageScreen.Show() | Out-Null
    [System.Windows.Forms.Application]::DoEvents()
}

function Import-AllModules
{
    foreach($file in (Get-Item -path "$global:Path\modules\*.psm1"))
    {      
        $fileName = [IO.Path]::GetFileName($file) 
        if($skipModules -contains $fileName) { Write-Warning "Module $fileName excluded"; continue; }
    
        $module = Import-Module $file -PassThru -Force -Global -ErrorAction SilentlyContinue
        if($module)
        {
            $global:messageScreenText.Text = "Module $($module.Name) loaded successfully"
        }
        else
        {
            $global:messageScreenText.Text = "Failed to load module $file"
        }
        [System.Windows.Forms.Application]::DoEvents()
    }
}

###########################################################################################################
############################################## Start ######################################################
###########################################################################################################
# Configure
$global:ChocolateyAppName = 'Chocolatey'

# App Info
$appName = "Intune App Creator (Unofficial)"
$appVersion = "1.1"

# Global Var
$global:Path = $PSScriptRoot
$global:PathSources = "$global:Path\.sources"

$global:Auth = $false
$global:ChocolateyAppId = $null
 
#####################
####### Start #######
#####################

# Start Start Screen
Get-MessageScreen -xamlPath ("$global:Path\xaml\message.xaml")
$global:messageScreenTitle.Text = "Initializing Device Troubleshooter"
$global:messageScreenText.Text = "Starting Device Troubleshooter"
[System.Windows.Forms.Application]::DoEvents()

# Load all Modules
$global:messageScreenText.Text = "Load all Modules"
[System.Windows.Forms.Application]::DoEvents()
Import-AllModules

# Init App
$global:messageScreenText.Text = "Init application and load dlls"
[System.Windows.Forms.Application]::DoEvents()
if (-not (Start-Init)){
    Write-Error "Error while loading the dlls. Exit the script"
    Write-Warning "Unblock all dlls and restart the powershell seassion"
    $global:messageScreen.Hide()
    Exit
}

# Load main windows
$returnMainForm = New-XamlScreen -xamlPath ("$global:Path\xaml\ui.xaml")
$global:formMainForm = $returnMainForm[0]
$xamlMainForm = $returnMainForm[1]
$xamlMainForm.SelectNodes("//*[@Name]") | % {Set-Variable -Name "WPF$($_.Name)" -Value $formMainForm.FindName($_.Name)}
$global:formMainForm.add_Loaded({
    $global:messageScreen.Hide()
    $global:formMainForm.Activate()
})
$theme = [MaterialDesignThemes.Wpf.ResourceDictionaryExtensions]::GetTheme($global:formMainForm.Resources)
[void][MaterialDesignThemes.Wpf.ThemeExtensions]::SetBaseTheme($theme, [MaterialDesignThemes.Wpf.Theme]::'Dark')
[void][MaterialDesignThemes.Wpf.ResourceDictionaryExtensions]::SetTheme($global:formMainForm.Resources, $theme)
$WPFLabelToolName.Content = "$appName - V$appVersion"
$Script:messageQueue =   [MaterialDesignThemes.Wpf.SnackbarMessageQueue]::new()
$Script:messageQueue.DiscardDuplicates = $true

# Load the click actions
$global:messageScreenText.Text = "Load Actions"
[System.Windows.Forms.Application]::DoEvents()
Set-UiAction
Set-UiActionButton

# Load User Interface
Set-UserInterface

# Get UserId
$global:messageScreen.Hide()
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Authentication'
$msg   = 'Enter your UPN:'
$userId = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
$global:messageScreen.Show()

# Login
$login = Set-LoginOrLogout -userId $userId
if($login -eq $false){
    Write-Error "Error during authentication"
    Write-Warning "Please try again"
    $global:messageScreen.Hide()
    Exit 
}

# Install IntuneWinAppUtility
$global:messageScreenText.Text = "Download IntuneWinAppUtil"
[System.Windows.Forms.Application]::DoEvents()
Install-IntuneWinAppUtility

# Install Chocolatey
Install-Chocolatey

# Get app id from Chocolatey
$global:messageScreenText.Text = "Get App Id from Chocolatey"
[System.Windows.Forms.Application]::DoEvents()
Show-InstallChocolatey

#Load Form
$formMainForm.ShowDialog() | out-null