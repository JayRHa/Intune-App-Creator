<#
.SYNOPSIS
Hadeling UI
.DESCRIPTION
Handling of the WPF UI
.NOTES
  Author: Jannik Reinhard
#>

########################################################################################
###################################### UI Actions ######################################
########################################################################################
function Set-UiActionButton{
    #App Finder
    Add-XamlEvent -object $WPFButtonSearchBox -event "Add_Click" -scriptBlock {
        Show-LoadingView
        [System.Windows.Forms.Application]::DoEvents()
        Set-SearchedApps
        [System.Windows.Forms.Application]::DoEvents()
        Hide-LoadingView
        [System.Windows.Forms.Application]::DoEvents()
    } 
    Add-XamlEvent -object $WPFButtonInstallChocolatey -event "Add_Click" -scriptBlock {
        Show-LoadingView
        [System.Windows.Forms.Application]::DoEvents()
        Add-Chocolatey
        [System.Windows.Forms.Application]::DoEvents()
        Show-InstallChocolatey
        [System.Windows.Forms.Application]::DoEvents()
        Hide-LoadingView
        [System.Windows.Forms.Application]::DoEvents()
    } 

    #About
    Add-XamlEvent -object $WPFBlogPost -event "Add_Click" -scriptBlock {Start-Process "https://github.com/JayRHa/Chocolatey-Intune-App-Creator"} 
    Add-XamlEvent -object $WPFReadme -event "Add_Click" -scriptBlock {Start-Process "https://github.com/JayRHa/Chocolatey-Intune-App-Creator"} 
    Add-XamlEvent -object $WPFButtonAboutWordpress -event "Add_Click" -scriptBlock {Start-Process "https://www.jannikreinhard.com"}
    Add-XamlEvent -object $WPFButtonAboutTwitter -event "Add_Click" -scriptBlock {Start-Process "https://twitter.com/jannik_reinhard"}
    Add-XamlEvent -object $WPFButtonAboutLinkedIn -event "Add_Click" -scriptBlock {Start-Process "https://www.linkedin.com/in/jannik-r/"}
}

function Show-LoadingView{
    $WPFLoadingDialog.Visibility="Visible"
    $WPFGridMain.IsEnabled=$false
    [System.Windows.Forms.Application]::DoEvents()
}

function Hide-LoadingView{
    $WPFLoadingDialog.Visibility="Collapsed"
    $WPFGridMain.IsEnabled=$true
    [System.Windows.Forms.Application]::DoEvents()
}

function Set-UiAction{
    #Add App
    Add-XamlEvent -object $WPFDataGridAllApps -event "Add_GotMouseCapture" -scriptBlock {
        if($_.OriginalSource.Name -eq 'ButtonAddApp'){
            Show-LoadingView
            [System.Windows.Forms.Application]::DoEvents()

            if(-not ($global:ChocolateyAppId)){
                New-Snackbar -Snackbar $WPFSnackbar -Text 'Chocolate App not detected. Click "Install Chocolatey"'
                [System.Windows.Forms.Application]::DoEvents()
                return
            }
            Add-App -appName $this.CurrentItem.AppName
            [System.Windows.Forms.Application]::DoEvents()
        }
        Hide-LoadingView
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function Show-InstallChocolatey{
    $global:ChocolateyAppId = Get-AppId -appName $global:ChocolateyAppName
    if($global:ChocolateyAppId){
        $WPFLabelChocolateyAppId.Content = "App id: $($global:ChocolateyAppId)"
        $WPFLabelChocolateyAppId.Visibility="Visible"
        $WPFButtonInstallChocolatey.Visibility="Collapsed"
    }else{
        $WPFLabelChocolateyAppId.Content = "App id:"
        $WPFLabelChocolateyAppId.Visibility="Collapsed"
        $WPFButtonInstallChocolatey.Visibility="Visible"     
    }
}


function Set-SearchedApps {
    if(-not ($WPFTextboxSearchBoxDevice.Text)){
        $WPFLabelAppCount.Content = "Searchbox is empty"
        $WPFLabelAppCount.Foreground = '#FFC31A1A'
        return
    }

    $packages = @(Search-ChocolateyApp -searchText $WPFTextboxSearchBoxDevice.Text)
    [System.Windows.Forms.Application]::DoEvents()

    $global:apps = [System.Data.DataTable]::New()
    [void]$global:apps.Columns.AddRange(@('AppName', 'AppVersion'))
    $global:apps.primarykey = $global:apps.columns['AppName']
    $WPFDataGridAllApps.ItemsSource = $global:apps.DefaultView
    if(($packages).count -gt 0){$packages | ForEach-Object {[void]$global:apps.Rows.Add($_.Name, $_.Version)}}
    [System.Windows.Forms.Application]::DoEvents()

    $WPFLabelAppCount.Foreground = 'White'
    $WPFLabelAppCount.Content = "$($packages.count) Apps"
    [System.Windows.Forms.Application]::DoEvents()
}

function New-Snackbar {
    param (
        $Snackbar,
        $Text,
        $ButtonCaption
    )
    try{
        if ($ButtonCaption) {       
            $messageQueue.Enqueue($Text, $ButtonCaption, {$null}, $null, $false, $false, [TimeSpan]::FromHours( 9999 ))
        }
        else {
            $messageQueue.Enqueue($Text, $null, $null, $null, $false, $false, $null)
        }
        $snackbar.MessageQueue = $messageQueue
    }
    catch{
        Write-Error "No MessageQueue was declared in the window.`n$_"
    }
}

function Set-UserInterface {
    # App finder
    $iconSearch = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAMAAADXqc3KAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAgVBMVEUAAAAknvMnmfUomfUomfUnmfUpmvUjl/MomPYomfUomfYnmPYpmvYomfUpmvUol/Muov8omvcnmfUomfUmmfIomfUpmPQnmfQomPUomfUnmfMomfUnnesrlf8omfUkku0nm/MomfUomPUnmfUomvQpmfUomfUnmvYomfUomfX///+Vwm5wAAAAKXRSTlMAFYLO9M+DFlLx8lRR/bBACz+v/hTwd3WBskHQDQzzDkKAs+95fc2IfxLEHQcAAAABYktHRCpTvtSeAAAAB3RJTUUH5gYUDicDFaCpggAAAJ5JREFUKM+tkNkOgjAQRVs2obILtaDsgt7//0GJpHFq9Enm6eTc5GZmGPtnuGU7jusdPr0f4DXiaPowQpykaZbjZCRFCbnRGYK2KVQac3gksFFrzHAhgcBVY4PWCLp3IIyqXmMClwQDRo0xLHr2hNtGEgGnh8zA2DdNXSHyjSbM0/aSMjQ9GFeL0y6qIP6+evnl33t59vjh15UGtsc8AfKLD4mzmPrPAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDIyLTA2LTIwVDE0OjM5OjAzKzAwOjAwYoXoEAAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyMi0wNi0yMFQxNDozOTowMyswMDowMBPYUKwAAAAASUVORK5CYII="   
    $iconCount = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAAN0lEQVRIiWNgGAUDDRjhrIor/xkYGBgYOnQwxcgBUHOYyDZgxIDROBgFlIPRVDTwYDQORgHlAADHmRgNDUab0wAAAABJRU5ErkJggg=="
    
    # About
    $iconLinkedIn = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAABJ0lEQVRIie2Sr07DUBSHv9N1YmuxGCAMFG5BIJBYeAhCSOpm2wUMju0FyOawPMEegQSFJYHQsTkUCd34k/UgCKQ0KdDugoHP3T/n9+Wee+CfL5DkYrEVbQl0EeaKhCkMUbx+0+m97VkpXado+Gs58yJ0k3tW+kLR8AQLmYIUV4juCBxNY8sUiGon9N3j63G1ATwXFdhZB2pZu0ut0Y1KtA5SNi5AdUWFk9Sg5SazRSrsh4EjYeC8G+xJPBsGjqiySRxvMK5WEF0Fucgt+Ix+0+k9Pbpn4YE8hL57LqhvVLB8GK2VK6O7Wvt+G6A0iU+NCrREXcBGqQNc7s3cGhUQf//niwly8OOCD0+ttSM1EZoc7d9tkcLQQOYgU4DiTSkZIOpNUf8XeQFjeFM4aqoyewAAAABJRU5ErkJggg=="
    $iconTwitter = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAACA0lEQVRIie2SP2gTcRTHP+9y1+Qutf4dxCEJHXTUooOtWLqJILqIgrMgAXFqbMUlXUzqqCCosyIu4uBSFBHxz6A4ZQnFFrVasQ62uYsxXp5L06bJ5Uy66NDv+H3vfb7v9/jBhv61pNuBXVl1LNsbFzgDJICPCnd8y8ltXsR3Y95RhH2zY/GJloBk3r1mOU5m+oJU2sF7bO8JcDCg/B7YDiyYyMj0mPMJwFgpqwpC+nfZu79n8tumoADL9sbbwAH6gajC06rqibq5GiCiAovA8QrOu8RV71AzYfksYYqBRHdsdW41zKwqOeleFzjfYL0CvR2pmc8r0eicWfWWgEhIgM5edCKIaN0wG6u9ZeeSa7t7QQ4vW4Mgg77hY1a9vywPIKVGODSeCHBjXqYGE8DLDmgBqn1pdtYEqCH9BvIYGFpfAG9DA3o9Oy3wYp1wFB6FBhSyUpopO8MKZ4HXXfLnq+X4g2bTbDZStncPOADs7IYuIlc+Z6XlJxjNRtX300ARsDumK1MzKftGYHC7mWTOHRBDToNmghZpUKEn4o8UR/sWgoprTrT/plrz35f6TMvcbfh6TNFzoXBlyqByqji67Ue7lpUXpPKlI4jkgIGQbev6IKqXZ37G75KVWlhjy4mSeW9IqJ0UQ4ZVSQBbFL6KMicGb1B96JTjzwpZ+dXBIhv6D/QH8mKgEDaLDDsAAAAASUVORK5CYII="
    $iconWordpress = "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAABmJLR0QA/wD/AP+gvaeTAAAD8ElEQVRIid2VX4iUVRjGf+/5Znfn+2azxT/4J9dZKQpUSDKKErUugoLIyXDcQiMCk4T+XLRuRhcDEbVtGHQRtOJVRbUG6yaBN1uURX/MyEgrMXe2VSMoKXd3vtnd+c7Txcza6mxSl3Uun/Oe53nf5z3nPfBfX3apzeUFNZbScU7mc+CuAy2uHTsF/iuT2xeVw31HCzbxrwWyXaUNhrqBH83oRcnBkrvsFEA4OdJqLljjIW/GUjnrGOqI+v6ZQEEuG8bPG369KdiapCq/usS2gt0CtAENiCHBQCrwPYlSc1CyG3N9xVK4k4L56XSuLvMq+Y0Y62TJ3S5x34I9DqwEWoAMxjIzHkm8O2LyeVVsHfI3tUXxcxfzXSBQtcWvD5w2gnujRnypPjlJw5OT0R+VhiQnaUNb11huRouWF9Q4FpaOmdyDiSUNzuweZOdA90ocx9nXJs3CSGr4JiCbCqPwxKM2Xk1w5FZwPXNbomWHt9nkBRWU0nEOOBmV05/91Nk8UNyR2Y40D5hvxgqkuNiZ2VbckdkuNAeYD1hSHlt3PlufGnTY0Nnf4/V1Fsl8zozeUljqvOplNQGYYxBoAhaYeGzxLoW16O+BEECyFygoVWXzD2HqBXJ1AsAqlByUaJ8sx3dWeZK908yclarEdwF47E0gqe1cm02XblteUDNwhyrJR4LrZxBwCxsZP4NZq0n3Awx2zvoB+OZ8iDQOMNyZOYMYOI8Hlo7T5ZVAW1MwfhpYNFMFUywp4ParXzw3F0DQWythhDg6MGWTodemTjR4DsmUq+e6QMD/PEHTIsyGgMbJJNUOECTB3ppF+2kqLwgm4ocBSkGmTzCKOHZiR3haaCNQLJNeDJypFzD3JQrWmvR+NXNtATj5VPo4cARpLy7ZZFbFf+mwMbA+zPYv6Y5vBpYYNmBya2UcqhMwT7+HPFIP4IEblnaduwbAzPYQRwfA2oGVV3aPrABw5l/3xn4nnwe8J9mDs7wT/XUCUTncVx1cQQvQU0WDLQCDbeErFo5kqY4LEh9sruKZgXmXh1+AbZTZLjwLkW+d3RLWCxwt2IScdaBkdwLPgH0g2ExBjrwlImj/q1+6bwr/7ezoauCIl14y53oMe2LqFV/UZBjqiPow1xegtxK02eC9pVF5ddVDmyZAazYcrb5gF5StogccvA30DnZm3p3OWXdNi6VwJ+Y+dfChx78TldKfZ58dW4gwIAZKwHdOdgWAfBIpZZ+Y2cfFOHr6Yr6/nZRtXWM5QbfDhjD1evmDzXHzMMBI8+gSV3FrcJZHvhVZR/HJTP9MPJf8Mle9qoba4MrJWCVVv0yDYZkddqJ/dkvYP93z/9/6E+aHsqs7a3d1AAAAAElFTkSuQmCC"
    $iconBlog = "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"


    # App finder
    $WPFImgSearchBoxDevice.source = Get-DecodeBase64Image -ImageBase64 $iconSearch
    $WPFImgAppCount.source = Get-DecodeBase64Image -ImageBase64 $iconCount

    #About
    $WPFImgTwitter.source = Get-DecodeBase64Image -ImageBase64 $iconTwitter
    $WPFImgWordpress.source = Get-DecodeBase64Image -ImageBase64 $iconWordpress
    $WPFImgLinkedIn.source = Get-DecodeBase64Image -ImageBase64 $iconLinkedIn
    $WPFImgBlog.source = Get-DecodeBase64Image -ImageBase64 $iconBlog
}