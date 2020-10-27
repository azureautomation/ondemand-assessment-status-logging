On-Demand Assessment Status Logging
===================================

            

The Assessment-status-logging script provides insight in where the On-Demand assessment is with data collection or analysis. Since the assessment runs as a process it does not indicate what it is doing and possibly how long it will take to end.


This script allows you to track the assessment (when running) up to the end, after generating the recommendations and reports. During collection and analasys we show what collector (number) we are at and how many there are.


Run the script as Administrator. It requires the logging interval to be set. We suggest at minimum 120 seconds to avoid heavy logging, 30 minutes or 1800 seconds is recommended. If data collection usually takes two days, an interval of 3600 or even 7200
 is recommended.


The script creates an event log under the Applications and Services Logs and generates an event at the chosen interval.


 


![Image](https://github.com/azureautomation/ondemand-assessment-status-logging/raw/master/EventLog.png)


 


In the open PowerShell window, you also see the status logged.


![Image](https://github.com/azureautomation/ondemand-assessment-status-logging/raw/master/Output.png)


 


This script is not replacing the Assessment troubleshooting script. 


If you end the script, it stops logging in Event Log as well. You have to restart it to track the progress again.


This script can be started any time after data collection is started, it requires the OMSAssessment.exe to be running.


In case multiple assessments run, it will prompt you for the one to track.


 


 



PowerShell
Edit|Remove
powershell
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
    Run it after data collection was started.
    It needs to run as admin (needed for creating new event log)
    Interval parameter to be added upon start

#>



<#PSScriptInfo 
 
.VERSION 1.1 
 
.COMPANYNAME Microsoft 
 
#> 
 
<# 
.SYNOPSIS  
    Gathers information on script execution and logs an event in the event viewer with the progress of data collection 
 
.DESCRIPTION 
    This script collects information, collected data and assessment logs and logs an event in the event viewer with the progress of data collection 
 
Instructions to use :  
    Run it after data collection was started. 
    It needs to run as admin (needed for creating new event log) 
    Interval parameter to be added upon start 
 
#> 
 





        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
