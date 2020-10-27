<#PSScriptInfo

.VERSION 1.1

.COMPANYNAME Microsoft

#>

<#
.SYNOPSIS 
    Gathers information on script execution and logs an event in the event viewer with the progress of data collection

.DESCRIPTION
    This script collects information, collected data and assessment logs and logs an event in the event viewer with the progress of data collection

Instructions to use : 
    Start after data colection is started.
    It needs to run as admin (needed for creating new event log)
    Interval parameter to be added in seconds, logs one event log each time and on screen.

#>

param([int]$interval)

clear-host
If(!$interval)
{
    [int]$interval = Read-Host "Please enter the time interval to wait between the records (Seconds)"
}
#------------------------------------- Variable Declaration Section--------------------------------------------------------------------

$ErrorActionPreference = "continue"
$AssessmentName = $null
[string]$logname = "On-Demand Assessment status"
$PatternArray = "Method=Main Message=Invoking the ConfigurationManager","Method=Main Message=Finished Invoking the ConfigurationManager","Method=LoadInternal Message=Unpacking package.","InterrogatorInitialized: Phase=Discovery Interrogator","InterrogationCompleted: Phase=Discovery Successful","Prerequisite success rate","type=collector Duration=","Type=Analyzer Duration","Type=Reporter","Message=GetIgnoreRecommendationsIds"
$Progresscounter = 0
$script:OutputDirectory = $null
$Script:OriginalPath = $null
$script:path = $null
$PathPattern = "ADAssessment","ADSecurityAssessment","ExchangeAssessment","SPAssessment","SfBAssessment","SCCMAssessment","SCOMAssessment","SQLAssessment","ExchangeOnlineAssessment","SharePointOnlineAssessment","SfBOnlineAssessment","WindowsServerAssessment","WindowsClientAssessment"
Add-Type -AssemblyName System.Windows.Forms

#------------------------------------- FUNCTION SECTION BEGINS------------------------------------------------------------------------
#FUNCTIONS TO PERFORM DIFFERENT ACTIONS

function Get-OutputDirectory ($Npath)
{ 
   
        $Script:OutputDirectory = $Npath
        #Write-Host $OutputDirectory
        return $Script:OutputDirectory
}
function get-Originalpath($opath)
{
       $Script:OriginalPath = $opath
       #Write-Host $OriginalPath
       return $Script:OriginalPath
}

#---------------------------------- FUNCTION SECTION ENDS -----------------------------------------------------------------------------

$OMSProcesses = Get-Process OMSAssessment -ErrorAction SilentlyContinue|Select-Object ProcessName,path 
If($OMSProcesses.count -eq 0)
{
    Write-Host "No Data collection Process is running exiting......"
    Start-Sleep 10
    Exit;
}

# GENERATING GUI FORM WITH BUTTONS.
if($OMSProcesses.count -gt 1)
{
        $Form = New-Object system.Windows.Forms.Form
        $Form.Size = New-Object System.Drawing.Size(600,350)
        $form.MaximizeBox = $false
        $Form.MinimizeBox = $false
        #$Form.ControlBox = $false
        $form.BackColor = "AliceBlue"
        $Form.StartPosition = "CenterScreen"
        $Form.FormBorderStyle = 'Fixed3D'
        $Form.Text = "Health Assessment status check"
        $Form.Topmost = $True

        $Label = New-Object System.Windows.Forms.Label
        $Label.Text = "Found Multiple assessment running. Please choose which one to track the status for :"
        $Label.AutoSize = $true
        $Label.Location = New-Object System.Drawing.Size(15,10)
        $Font = New-Object System.Drawing.Font("Arial",10,[System.Drawing.FontStyle]::Bold)
        $form.Font = $Font
        $Form.Controls.Add($Label)

        $ButtonPosition = 50
        foreach($OMSProcess in $OMSProcesses)
        {
                $OMSProcessesPath = $OMSProcess.path

                $PathPattern | ForEach-Object { IF ($OMSProcessesPath -match "(.+?)((?i)($_)(?-i))")
                                                    {
                                                        $script:path = $matches[0]
                                                    }
                                                }

                $button = New-Object System.Windows.Forms.Button
                $button.Location = New-Object System.Drawing.Size(150,$ButtonPosition)
                $button.Size = New-Object System.Drawing.Size(300,40)
                $button.BackColor ="Lightgray"
                $button.Text = $Path
                $Button.Tag = $OMSProcessesPath
                $Button.Add_Click({$var = (($($this.text)));$var1 = (($($this.tag)));Get-OutputDirectory ($var);get-Originalpath($var1);$Form.Close() |Out-Null})
                $Form.Controls.Add($button)
                $ButtonPosition = $ButtonPosition + 60
        }

 $Form.ShowDialog() |Out-Null
}
else
{
                $OMSProcessesPath = $OMSProcesses.path
                $Script:OriginalPath = $OMSProcessesPath

                $PathPattern | ForEach-Object { IF ($OMSProcessesPath -match "(.+?)((?i)($_)(?-i))")
                                                    {
                                                        $Script:OutputDirectory = $matches[0]
                                                    }
                                                }
                
}

# Getting the exact assessment name

$Assessmentresult = $Script:OutputDirectory |Split-Path -Leaf
switch -wildcard ($Assessmentresult)
                            {
                               {(($Assessmentresult).Trim() -like "ADAssessment")} {$AssessmentName = "ADAssessmentPlus"}
                               {(($Assessmentresult).Trim() -like "ADSecurityAssessment")} {$AssessmentName = "ADSecurityAssessment"}
                               {(($Assessmentresult).Trim() -like "ExchangeAssessment")} {$AssessmentName = "ExchangeAssessment"}
                               {(($Assessmentresult).Trim() -like "SPAssessment")} {$AssessmentName = "SPAssessment"}
                               {(($Assessmentresult).Trim() -like "SfBAssessment")} {$AssessmentName = "SfBAssessment"}
                               {(($Assessmentresult).Trim() -like "SCCMAssessment")} {$AssessmentName = "SCCMAssessmentPlus"}
                               {(($Assessmentresult).Trim() -like "SCOMAssessment")} {$AssessmentName = "SCOMAssessmentPlus"}
                               {(($Assessmentresult).Trim() -like "SQLAssessment")} {$AssessmentName = "SQLAssessmentPlus"}
                               {(($Assessmentresult).Trim() -like "ExchangeOnlineAssessment")} {$AssessmentName = "ExchangeOnlineAssessment"}
                               {(($Assessmentresult).Trim() -like "SharePointOnlineAssessment")} {$AssessmentName = "SharePointOnlineAssessment"}
                               {(($Assessmentresult).Trim() -like "SfBOnlineAssessment")} {$AssessmentName = "SfBOnlineAssessment"}
                               {(($Assessmentresult).Trim() -like "WindowsServerAssessment")} {$AssessmentName = "WindowsServerAssessment"}
                               {(($Assessmentresult).Trim() -like "WindowsClientAssessment")} {$AssessmentName = "WindowsClientAssessmentPlus"}
                            }


# EVENT SOURCE NAME
[string]$eventsource = "$AssessmentName - Script"

## Initiating Event writing
Write-host “  ##  $AssessmentName status check script started" -ForegroundColor cyan
Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName status check script started" -EventId 1 -EntryType information -ErrorAction SilentlyContinue

# CHECKING IF EVENT SOURCE LREADY PRESENT
if(!([System.Diagnostics.EventLog]::SourceExists($LogName)))
{
    write-host "Checking if Event log already exist"
    New-EventLog -LogName $logname -Source $eventsource
    Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName status check script started" -EventId 1 -EntryType information -ErrorAction SilentlyContinue
}
else
{
    If(!([System.Diagnostics.EventLog]::SourceExists($eventsource)))
    {
        [System.Diagnostics.EventLog]::CreateEventSource("$eventsource", "$logname")
    }
}

Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection started!” -EventId 1 -EntryType information
Write-host “  ##  $AssessmentName Data collection started!" -ForegroundColor cyan

## Finding the output directory created by assessment collection, to get the log file

 $outputDirectoryResults = ($originalpath -split "OmsAssessment")[0]
 #$Logdirectoryname = (get-childitem $outputDirectoryResults | Where-Object { $_.Name -match '^\d+$' }).name
 $Logdirectoryname = (get-childitem $outputDirectoryResults | Where-Object { $_.Name -match '^\d+$' -and $_.name -notlike $outputDirectoryResults.Split("_")[1] }|Sort-Object lastwritetime -Descending|select -First 1).name
 $logfilename = $outputDirectoryResults +"\" + $Logdirectoryname + "\" + "SironaLog_Advisor*.log"

## Finding the number of collectors and analyzers from the Execution config file

 $Executionconfigfilepath =  $outputDirectoryResults + "\" + $Logdirectoryname + "\Temp\Execution\" + $AssessmentName + "\" + "Executionconfig.xml"

 $retrycount = 0
 While(!(Test-Path $Executionconfigfilepath) -and $retrycount -lt 5)
     {
            ## Waiting for data execution to proceed
            write-host "Waiting for Files to be generated" -ForegroundColor cyan
            start-sleep -Seconds $interval
            $retrycount = $retrycount +1
     }

 [xml]$Executionconfigdata = Get-Content $Executionconfigfilepath
 $collectorscount = ($Executionconfigdata.ExecutionConfiguration.Collectors.CollectorRef).Count
 $analyzercount = ($Executionconfigdata.ExecutionConfiguration.Analyzers.AnalyzerRef).count

While((get-process OMSAssessment -ErrorAction SilentlyContinue) -and $Progresscounter -ne 8)
{       
        $phase = 1
        # start from Message=Invoking the ConfigurationManager
        If($Progresscounter -eq 0 -and ((Select-String -pattern $PatternArray[0] $logfilename).Matches.Count -ne 0))
        {
            Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status: Phase : $Phase out of 8 : Configuration Manager Invoked” -EventId 1 -EntryType information
            Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Configuration Manager Invoked" -ForegroundColor cyan

            while((Select-String -pattern $PatternArray[1] $logfilename).Matches.Count -eq 0)
            {
                Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status: Phase : $Phase out of 8 : Waiting for Configuration Manager” -EventId 1 -EntryType information
                Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : waiting for Configuration Manager " -ForegroundColor cyan
                start-sleep -Seconds $interval
            }

            $Progresscounter = 1
            $phase = 2
        }

        # start from "Unpacking package." till discovery start 
        If(($Progresscounter -eq 1) -and ((Select-String -pattern $PatternArray[2] $logfilename).Matches.Count -ne 0))
        {
            $phase = 2
            Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Unpacking of packages started" -EventId 1 -EntryType information
            Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Unpacking of packages started" -ForegroundColor cyan

            while((Select-String -pattern $PatternArray[3] $logfilename).Matches.Count -eq 0)
            {
                Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : waiting for  Unpacking of packages " -EventId 1 -EntryType information
                Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : waiting for Unpacking of packages" -ForegroundColor cyan
                start-sleep -Seconds $interval
            }

            $Progresscounter = 2
            $phase = 3
        }

        # Discovery phase check = start from discovery start to end  
        If($Progresscounter -eq 2 -and ((Select-String -pattern $PatternArray[3] $logfilename).Matches.Count -ne 0))
        {
            $phase = 3
            Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Discovery phase started" -EventId 1 -EntryType information
            Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Discovery phase started" -ForegroundColor cyan

            while((Select-String -pattern $PatternArray[4] $logfilename).Matches.Count -eq 0)
            {
                Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Waiting for Discovery phase to complete" -EventId 1 -EntryType information
                Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Waiting for Discovery phase to complete" -ForegroundColor cyan
                start-sleep -Seconds $interval
            } 
                
            $Progresscounter = 3
            $phase = 4
        }

        # discovery phase end to "Prerequisite success rate"
        If($Progresscounter -eq 3 -and ((Select-String -pattern $PatternArray[4] $logfilename).Matches.Count -gt 0))
        {   
            $phase = 4
            Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Running Prerequisite checks. " -EventId 1 -EntryType information
            Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Running Prerequisite Checks. " -ForegroundColor cyan
            
            while((Select-String -pattern $PatternArray[5] $logfilename).Matches.Count -eq 0)
            {
                Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Waiting for Prerequisite checks. " -EventId 1 -EntryType information
                Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Waiting for Prerequisite Checks. " -ForegroundColor cyan
                Start-Sleep -Seconds $interval
            }

            $Progresscounter = 4
            $phase = 5
        }

        # collectors Phase check = start from "Prerequisite success rate" to "type=collector Duration=" 
        If($Progresscounter -eq 4 -and ((Select-String -pattern $PatternArray[5] $logfilename).Matches.Count -ne 0))
        {   
            $phase = 5
            Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Processing collectors. " -EventId 1 -EntryType information
            Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Processing collectors. " -ForegroundColor cyan

            $templogfile = "$outputDirectoryResults\$Logdirectoryname\temp.log"

            $lencounter = 0
            Do
                {
                    Copy-Item $logfilename $templogfile
                    $str = Get-Content $templogfile | out-string
                    $start = $str.indexOf("Prerequisite success rate") + 1
                    $end = (Get-Content $templogfile | Measure-Object -Character).Characters
                    $length = $end - $start

                    If($lencounter -ne 0)
                    {
                        Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Initiating collectors " -EventId 1 -EntryType information
                        Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Initiating collectors. " -ForegroundColor cyan
                        Start-Sleep -Seconds $interval
                    }

                }While($length -lt 0)

            $result = $str.substring($start, $length)
            $result | out-file  $templogfile
           
            while(((Select-String -pattern $PatternArray[6] $templogfile).Matches.Count -lt $collectorscount) -and (Select-String -pattern $PatternArray[7] $logfilename).Matches.Count -eq 0)  
                {
                    $currentcollectorcount = (Select-String -pattern $PatternArray[6] $templogfile).Matches.Count
                    Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Processing collectors. Completed $currentcollectorcount out of $collectorscount" -EventId 1 -EntryType information
                    Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Processing collectors. Completed $currentcollectorcount out of $collectorscount" -ForegroundColor cyan
                    start-sleep -Seconds $interval
                    $templogfile = "$outputDirectoryResults\$Logdirectoryname\temp.log"
                    Copy-Item $logfilename $templogfile 
                    $str = Get-Content $templogfile | out-string
                    $start = $str.indexOf("Prerequisite success rate") + 1
                    $end = (Get-Content $templogfile | Measure-Object -Character).Characters
                    $length = $end - $start
                    $result = $str.substring($start, $length)
                    $result | out-file  $templogfile
                }  
                   
            $Progresscounter = 5
            $phase = 6
            Remove-Item $templogfile
        }

        # Analysers phase check = start from analyzer to Reporter 
        If($Progresscounter -eq 5 -and ((Select-String -pattern $PatternArray[7] $logfilename).Matches.Count -ne 0))
        {   
            $phase = 6
            Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Processing analyzers." -EventId 1 -EntryType information
            Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Processing analyzers." -ForegroundColor cyan

            while(((Select-String -pattern $PatternArray[7] $logfilename).Matches.Count -lt $analyzercount) -and (Select-String -pattern $PatternArray[8] $logfilename).Matches.Count -eq 0)
            {   
                $currentanalyzercount = (Select-String -pattern $PatternArray[7] $logfilename).Matches.Count
                Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Processing analyzers. Completed $currentanalyzercount out of $analyzercount" -EventId 1 -EntryType information
                Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Processing analyzers. Completed $currentanalyzercount out of $analyzercount" -ForegroundColor cyan
                start-sleep -Seconds $interval
            }     

            $Progresscounter = 6
            $phase = 7
        }

        # start Reporter to GetIgnoreRecommendationsIds =  Reporter check
        If($Progresscounter -eq 6 -and ((Select-String -pattern $PatternArray[8] $logfilename).Matches.Count -ne 0))
        {
            $phase = 7
            Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Processing Reports" -EventId 1 -EntryType information
            Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Processing Reports" -ForegroundColor cyan
            
            while((Select-String -pattern $PatternArray[9] $logfilename).Matches.Count -eq 0)
            {
                start-sleep -Seconds $interval
                Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Waiting to Process Reports" -EventId 1 -EntryType information
                Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Waiting to Process Reports" -ForegroundColor cyan
            }     
            $Progresscounter = 7
            $phase = 8
        }

        # End of DATA collection
        If($Progresscounter -eq 7 -and ((Select-String -pattern $PatternArray[9] $logfilename).Matches.Count -ne 0))
        {
             $phase = 8
             Write-EventLog -LogName $logname -Source $eventsource -Message “$AssessmentName Data collection status : Phase : $Phase out of 8 : Generating recommendation files and finishing the assessment" -EventId 1 -EntryType information
             Write-host “  ##  $AssessmentName Data collection status: Phase : $Phase out of 8 : Generating recommendation files and finishing the assessment" -ForegroundColor cyan
             start-sleep -Seconds $interval
             $Progresscounter = 8
        }
}
