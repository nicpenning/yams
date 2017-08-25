<#PowerCuckoo
    Created by Nicholas Penning
    Date: 8/14/2017
    Updated: 8/25/2017
    Description: For automation!
    
    Note: Needs a good handful of tweaks before this will work. Right now it will read an unread message and parse the contents and 
    display what would be sent to Cuckoo. Will update later!
    Requirements: curl.exe is needed to feed the Cuckoo API. Find a legit curl.exe and store it in the same directory as this file.
#>

#REST Calls
$CuckooREST = 'http://localhost:8090'
$MaliciousFileREST = $CuckooREST + 'tasks/create/file'
$MaliciousURLREST = $CuckooREST + 'tasks/create/url'
$MaliciousArchiveREST = $CuckooREST + 'tasks/create/submit'

#Parse Email Message - Ready Outlook
Add-Type -assembly "Microsoft.Office.Interop.Outlook"
$Outlook = New-Object -comobject Outlook.Application
$namespace = $Outlook.GetNameSpace("MAPI")
$emailAddress = Read-Host -Prompt 'Input your email address'
$folderName = 'Cuckoo'
$subFolderName = 'Feeding Cuckoo'

#RegEx to Grab URL
#/<a\s+(?:[^>]*?\s+)?href="([^"]*)"/g
$RegExHtmlLinks = '<a\s+(?:[^>]*?\s+)?href="[h+f]([^"]*)"'
$urlsForSearch = @()
$urlsFound = @()

#Cuckoo Folder - #Feed the Cuckoo Subfolder
#$FeedTheCuckoo = $namespace.Folders.Item($emailAddress).Folders.Item('Inbox').Items | Format-List Unread, CreationTime, SenderName, ConversationTopic, Body, HTMLBody, To
$FeedTheCuckooUnread = $namespace.Folders.Item($emailAddress).Folders.Item('Inbox').Items | Where-Object UnRead -EQ true

#Mark Message as Read
$FeedTheCuckooUnread.UnRead = "False"

#Store URLs to get Searched from Email HTMLBody
$urlsForSearch += $FeedTheCuckooUnread.HTMLBody

#Loop through results for URLs
$urlsForSearch | ForEach-Object {
    if ($_ -match $RegExHtmlLinks)
        {
            $urlsFound += $matches[0]
        }
    }

#Clean URLs for Analysis
$cleanUrls = $urlsFound -replace '<a href='
$cleanedUrlsForAnalysis = $cleanUrls -replace '"'
$cleanedUrlsForAnalysis
Write-Host "Going to Submit:" $cleanedUrlsForAnalysis "to Cuckoo!!"
Sleep -Seconds 15
#Send the URLs away to be analyzed!
#maliciousURLSubmission($cleanedUrlsForAnalysis)

#Sample Data - Use for making sure your Cuckoo API and that PowerCuckoo is working :)
#$MaliciousSite = "https://www.google.com"
#$MaliciousFile = "C:\windows\system32\calc.exe"
#$MaliciousFile = ".\Alert.doc"
#$MaliciousFile = "\path\to\file.exe"

function maliciousFileSubmission ($submitFile) {
    Submit Malicious File
    .\curl.exe -F file=@$submitFile $MaliciousREST
    Invoke-RestMethod -Method Post -Uri $MaliciousFileREST -InFile Documents\Pafish.docm
    $upload = Invoke-RestMethod -Method Post -Uri $MaliciousFileREST -InFile $MaliciousFile -ContentType 'multipart/form-data' 
}


#Function for sending Cuckoo malicious URLs
function maliciousURLSubmission ($submitURL) {
#Invoke-RestMethod -Method Post -Uri $MaliciousURLREST -Body url=$MaliciousSite
$x = 0
#Loop through all the URLs in the cleaned up array
$submitURL | ForEach-Object {
        $submitURLx = $submitURL[$x]
        Invoke-RestMethod -Method Post -Uri $MaliciousURLREST -Body url=$submitURLx
        $submitURLx
        $x++
    }
}

#Call Malicous URL/File Submission Functions
#maliciousURLSubmission($cleanedUrlsForAnalysis)
#maliciousFileSubmission($MaliciousFile)

<# Cuckoo API Documenation - http://docs.cuckoosandbox.org/en/latest/usage/api/
Resource	Description
POST /tasks/create/file	Adds a file to the list of pending tasks to be processed and analyzed.
curl -F file=@/path/to/file http://localhost:8090/tasks/create/file
POST /tasks/create/url	Adds an URL to the list of pending tasks to be processed and analyzed.
POST /tasks/create/submit	Adds one or more files and/or files embedded in archives to the list of pending tasks.
GET /tasks/list	Returns the list of tasks stored in the internal Cuckoo database. You can optionally specify a limit of entries to return.
GET /tasks/view	Returns the details on the task assigned to the specified ID.
GET /tasks/reschedule	Reschedule a task assigned to the specified ID.
GET /tasks/delete	Removes the given task from the database and deletes the results.
GET /tasks/report	Returns the report generated out of the analysis of the task associated with the specified ID. You can optionally specify which report format to return, if none is specified the JSON report will be returned.
GET /tasks/screenshots	Retrieves one or all screenshots associated with a given analysis task ID.
GET /tasks/rereport	Re-run reporting for task associated with a given analysis task ID.
GET /tasks/reboot	Reboot a given analysis task ID.
GET /memory/list	Returns a list of memory dump files associated with a given analysis task ID.
GET /memory/get	Retrieves one memory dump file associated with a given analysis task ID.
GET /files/view	Search the analyzed binaries by MD5 hash, SHA256 hash or internal ID (referenced by the tasks details).
GET /files/get	Returns the content of the binary with the specified SHA256 hash.
GET /pcap/get	Returns the content of the PCAP associated with the given task.
GET /machines/list	Returns the list of analysis machines available to Cuckoo.
GET /machines/view	Returns details on the analysis machine associated with the specified name.
GET /cuckoo/status	Returns the basic cuckoo status, including version and tasks overview.
GET /vpn/status	Returns VPN status.
GET /exit	Shuts down the API server.
