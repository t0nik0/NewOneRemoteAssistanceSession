# It run a remote assistance session with "random" pass
# and send it and base64 message of the invitation file
# to my ifttt's webhook and copy itself to %desktop% )
# It was wrotten for my parents.

$myiftttevent = "MyIFTTTEventName"
$myiftttkey = "My_Shiny_New_Long-Long_IFTTT_Key"

Copy-Item -Path $PSCommandPath -Destination $([Environment]::GetFolderPath("Desktop"))

$pass = ( -join ((0x30..0x39) + ( 0x41..0x5A) | Get-Random -Count 12  | % {[char]$_}) )
$file = (Join-Path -Path $Env:temp -ChildPath "Invitation.msrcIncident")
$zip = (Join-Path -Path $Env:temp -ChildPath "I.zip")
Remove-Item $file 2> $null
Remove-Item $zip 2> $null 

msra /saveasfile $file $pass
Start-Sleep -Seconds 3

$file = Get-Item $file
Compress-Archive -Path $file -DestinationPath $zip
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($zip))
Remove-Item $file 2> $null
Remove-Item $zip 2> $null 

$webhookUrl = "https://maker.ifttt.com/trigger/$myiftttevent/with/key/$myiftttkey"
$body = @{
        value1 = $pass
        value2 = $base64string
        value3 = $Env:username
    }

Invoke-RestMethod -Method Get -Uri $webhookUrl -Body $body

# just for debugging
#Write-Host -NoNewLine 'Press any key to continue...';
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

# Gmail > Show original > Download Original and:
# echo $(sed 's/^M$//g; /^Extra Data: /,/^.*,$/!d; /^.*,$/q' Original.eml) | awk -F", " '{gsub(/ /,"",$2); printf "%s",$2}' | base64 -d > I.zip
