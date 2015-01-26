#User variables
$SystemPrepMasterScriptUrl = 'https://url/to/masterscript.ps1'
$SystemPrepParams = @{
    Param1 = "Value1"
    Param2 = "Value2"
    Param3 = "Value3"
    Param4 = "Value4"
}

#System variables
$DateTime = $(get-date -format "yyyyMMdd_HHmm_ss")
$ScriptName = $MyInvocation.mycommand.name
$SystemPrepDir = "${env:SystemDrive}\SystemPrep"
$SystemPrepLogFile = "${SystemPrepDir}\SystemPrep-Log_${DateTime}.txt"

function log {
	[CmdLetBinding()]
	Param(
		[Parameter(Mandatory=$true,Position=0,ValueFromPipeLine=$true,ValueFromPipeLineByPropertyName=$true)] [string[]] $LogMessage
	)
	PROCESS {
		#Writes the input $LogMessage to the log file $SystemPrepLogFile.
		Add-Content -Path $SystemPrepLogFile -Value "$(get-date -format `"yyyyMMdd_HHmm_ss`"): ${ScriptName}: ${LogMessage}"
	}
}

if (-Not (Test-Path $SystemPrepDir)) { New-Item -Path $SystemPrepDir -ItemType "directory" -Force > $null; log "Created SystemPrep directory -- ${SystemPrepDir}" } else { log "SystemPrep directory already exists -- $SystemPrepDir" }
$ScriptFileName = (${SystemPrepMasterScriptUrl}.split('/'))[-1]
$ScriptFullPath = "${SystemPrepDir}\${ScriptFileName}"
log "Downloading the SystemPrep master script -- ${SystemPrepMasterScriptUrl}"
((new-object net.webclient).DownloadFile("${SystemPrepMasterScriptUrl}","${ScriptFullPath}") 2>&1) | log
log "Running the SystemPrep master script -- ${ScriptFullPath}"
(Invoke-Expression "& ${ScriptFullPath} @SystemPrepParams" 2>&1) | log
log "Exiting SystemPrep BootStrap script"
