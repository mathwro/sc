Param(
   [string]$collectionurl = "https://xxx.visualstudio.com",
   [string]$project = "ProjectName",
   [string]$user = "username",
   [string]$token = "Password/PAT", # jyotx6fq7t3vc3mts4dh23eymetktcesvrfs32f4mp73j4zwboxq
   [string]$apiVersion = "6.0"
)

# Base64-encodes the Personal Access Token (PAT) appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$token)))

$baseUrl = "$collectionurl/$project/_apis/wit/reporting/workitemrevisions?includeLatestOnly=true&api-version=$apiVersion"         
$response = (Invoke-RestMethod -Uri $baseUrl -Method Get -UseDefaultCredential -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}).values
#$wits = $response | Where-Object ({$_.fields.'System.WorkItemType' -eq 'Task'}) # Only retrieve Tasks

$witrevisions = @()

foreach($wit in $wits){

    $customObject = new-object PSObject -property @{
          "WitID" = $wit.fields.'System.Id'   
          "rev" = $wit.fields.'System.Rev'
          "Title" = $wit.fields.'System.Title'
          "AssignedTo" = $wit.fields.'System.AssignedTo'
          "ChangedDate" = $wit.fields.'System.ChangedDate'
          "ChangedBy" = $wit.fields.'System.ChangedBy'
          "WorkItemType" = $wit.fields.'System.WorkItemType'
        } 

    $witrevisions += $customObject      
}

$witrevisions | Select-Object `
                WitID,
                rev,
                Title, 
                AssignedTo,
                ChangedDate, 
                ChangedBy,
                WorkItemType #| export-csv -Path D:\temp\WIT.csv -NoTypeInformation