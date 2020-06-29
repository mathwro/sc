Param(
    [string] $InstallLogPath,
    [String] $ip,
    [string] $hostsPath,
    [String] $hostname
)
function WriteLog {
    Param(
        <# Can be null or empty #> $message
    )

    $timestampedMessage = $("[" + [System.DateTime]::Now + "] " + $message) | % {
        Out-File -InputObject $_ -FilePath $ScriptLog -Append
    }

    Write-Host $message
}

function InitializeFolders {
    if ($false -eq (Test-Path -Path $InstallLogPath)) {
        New-Item -Path $InstallLogPath -ItemType directory | Out-Null
    }

    if ($false -eq (Test-Path -Path $ArtifactFolder)) {
        New-Item -Path $ArtifactFolder -ItemType directory | Out-Null
    }
}

try {
    # Location of the log files
    $ArtifactFolder = Join-Path $InstallLogPath -ChildPath $("Windows-Add-HostEntry-" + [System.DateTime]::Now.ToString("yyyy-MM-dd-HH-mm-ss"))
    $ScriptLog = Join-Path -Path $ArtifactFolder -ChildPath "windows_add_hostentry.log"

    InitializeFolders;



    if ($ip -and $hostname) {
        $iplist = $ip.Split(',')
        $hostlist = $hostname.Split(',')

            if ($iplist.Length -eq $hostlist.Length) {
                for ($i = 0; $i -lt $iplist.Length; $i++) {
                    $hostentry = $iplist[$i] + " " + $hostlist[$i]
                    ac $hostsPath "`n`n$hostentry"
                    WriteLog "Host Entry nr ${i}:";
                    WriteLog "$hostentry";
                }
                WriteLog "Successfully added host entries";  
                exit 0;
            }
            else {
                WriteLog "Uneven ammount of IP's and hostnames given."
                exit -1;
            }
        }
        else {
            WriteLog "Script attempted to run, but either no IP or hostname was given"
            exit -1;
        }
}
    catch
    {
        WriteLog "add host entries failed";
        WriteLog $_.Exception.Message;
    
        exit -1;
    }
