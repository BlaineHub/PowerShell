###############Intial Setup########################

$BASE_DIR = "C:\Users\user\Documents\powershell\advanced-system-scripts"
$LOG_FILE = $BASE_DIR + "\report_log_$(get-date -f yyyy-MM-dd).log"

$head = @"
<style>
h1,h5,th { text-align: center }
table { margin: auto }

table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
}
th, td {
    padding: 5px;
    text-align: left;
}
table {
    width: 90%;    
    background-color: #b8d1f3;
}
tr:nth-child(even) { background: #dae5f4;}
tr:nth-child(odd) { background: #b8d1f3;}

</style> 
"@

$report = $Base_Dir + "\memory_report_$(get-date -f yyyy-MM-dd).html"
$xml_config = $Base_Dir + "\config.xml"
[xml]$xml_content = Get-Content $xml_config



Write-Output "$(get-date) :[INFO] Staring Memory Check Script" | out-file $LOG_FILE -append -force;

$diskspace_error_thresehold = $xml_content.MEMORY_REPORT.MONITOR_lIMITS.DISKSPACE_ERROR
$diskspace_warning_thresehold = $xml_content.MEMORY_REPORT.MONITOR_lIMITS.DISKSPACE_WARNING



#### Testing Memory of servers ####

try{

foreach ($entity in $xml_content.MEMORY_REPORT.SERVERS){
$server = $entity.SERVER
$body = "<h1>MEMORY CHECK SUMMARY</h1> `n<h5>Updated on $(get-date)</h5>"
Get-Wmiobject -query "select * from win32_logicaldisk where drivetype=3" -computername $server |
Select-object SystemName, Deviceid, @{name="size";expression={[math]::Round($_.size/1GB,2)}},`
@{name="FreeSpace";expression={[math]::Round($_.freespace/1GB,2)}},`
@{name="occupied";expression={[math]::Round(100 - ([double]$_.freespace/[double]$_.size)* 100)}} |
Export-csv ($base_dir + "\disk_space_$(get-date -f yyyy-MM-dd).csv") -NoTypeinformation
}
$csv_content = Import-csv ($base_dir + "\disk_space_$(get-date -f yyyy-MM-dd).csv")


$body = "<h1>Servers in Error Status >90% </h1> `n<h5>Updated on $(get-date)</h5>"
$csv_content | Where-object {$_.occupied -ge $diskspace_error_thresehold} | Convertto-html -Property systemname, DeviceID, Size, Freespace, Occupied -head $head -body $body | Out-File $report

$body = "<h1>Servers in Warning Status >80% </h1> `n<h5>Updated on $(get-date)</h5>"
$csv_content | Where-object {$_.occupied -lt $diskspace_error_thresehold -and $_.occupied -ge $diskspace_warning_thresehold} | Convertto-html -Property systemname, DeviceID, Size, Freespace,Occupied -head $head -body $body | Out-File $report -append

$body = "<h1>Servers in Good Status <80% </h1> `n<h5>Updated on $(get-date)</h5>"
$csv_content | Where-object {$_.occupied -lt $diskspace_warning_thresehold} | Convertto-html -Property systemname, DeviceID, Size, Freespace, Occupied -head $head -body $body | Out-File $report -append


}catch{
$error_message = $_.Exception.message
write-output "$(get-date) :[ERROR] $error_message" | Out-file $log_file -append -force;
} 

write-output "$(get-date):[INFO] Report Preparation Complete" | out-file $log_file -append -force;


###############Sending The Report Email########################

try{
#Credentials
$smtpserver= $xml_content.MEMORY_REPORT.EMAIL.SMTP
$smtpport=$xml_content.MEMORY_REPORT.EMAIL.SMTPPORT
$username=$xml_content.MEMORY_REPORT.EMAIL.USERNAME
$password=$xml_content.MEMORY_REPORT.EMAIL.PASSWORD


#Subject & Body
$message = New-Object system.net.mail.mailmessage
$message.subject = $xml_content.MEMORY_REPORT.EMAIL.SUBJECT
$message.body = Get-Content $report
$message.IsBodyHtml = $True
$message.to.add($xml_content.MEMORY_REPORT.EMAIL.TO)
$message.from = $xml_content.MEMORY_REPORT.EMAIL.FROM

#Send Email
$smtp = New-Object System.net.mail.smtpclient($smtpserver,$smtpport);
$smtp.enablessl = $true
$smtp.credentials = New-Object system.net.networkcredential($username,$password);
$smtp.send($message)
Write-Output "$(get-date) :[INFO] Report Email Sent Successfully" | out-file $LOG_FILE -append -force;
}catch{
$error_message = $_.Exception.message
write-output "$(get-date) :[ERROR] $error_message" | Out-file $log_file -append -force;
} finally{
write-output "$(get-date): [INFO] Script Execution Completed" | out-file $log_file -append -force;
} 
