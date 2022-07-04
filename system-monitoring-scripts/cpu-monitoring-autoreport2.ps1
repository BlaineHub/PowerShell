###############Intial Setup########################

$BASE_DIR = "C:\Users\user\Documents\powershell\advanced-system-scripts\cpu_monitor"
$LOG_FILE = $BASE_DIR + "\report_log_$(get-date -f yyyy-MM-dd).log"

$head = @"
<style>
h1,h5,h3,th { text-align: center }
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



Write-Output "$(get-date) :[INFO] Staring CPU Check Script" | out-file $LOG_FILE -append -force;

$cpu_error_thresehold = $xml_content.CPU_REPORT.MONITOR_LIMITS.CPU_ERROR



#### Testing CPU of servers ####

try{

foreach ($entity in $xml_content.CPU_REPORT.SERVERS){
$server = $entity.SERVER
$cpu_details = Get-Wmiobject -class win32_processor -ComputerName $server| Select-object systemname, loadpercentage 
if ($cpu_details.loadpercentage -ge $cpu_error_thresehold){

$body = "<h1>CPU limit of ($cpu_error_thresehold%) Breached </h1> `n<h3>Please Check Servers Below<h3>`n<h5>Updated on $(get-date)</h5>"
$cpu_details | Convertto-html -Property systemname, loadpercentage -head $head -body $body | Out-File $report

try{
#Credentials
$smtpserver= $xml_content.CPU_REPORT.EMAIL.SMTP
$smtpport=$xml_content.CPU_REPORT.EMAIL.SMTPPORT
$username=$xml_content.CPU_REPORT.EMAIL.USERNAME
$password=$xml_content.CPU_REPORT.EMAIL.PASSWORD


#Subject & Body
$message = New-Object system.net.mail.mailmessage
$message.subject = $xml_content.CPU_REPORT.EMAIL.SUBJECT
$message.body = Get-Content $report
$message.IsBodyHtml = $True
$message.to.add($xml_content.CPU_REPORT.EMAIL.TO)
$message.from = $xml_content.CPU_REPORT.EMAIL.FROM

#Send Email
$smtp = New-Object System.net.mail.smtpclient($smtpserver,$smtpport);
$smtp.enablessl = $true
$smtp.credentials = New-Object system.net.networkcredential($username,$password);
$smtp.send($message)
Write-Output "$(get-date) :[INFO] Report Email Sent Successfully" | out-file $LOG_FILE -append -force;
}catch{
$error_message = $_.Exception.message
write-output "$(get-date) :[ERROR] $error_message" | Out-file $log_file -append -force;
} 
}else{write-output "$(get-date) :[INFO] No CPU Issues To Report for All Servers"| Out-file $log_file -append -force}
}}catch{
$error_message = $_.Exception.message
write-output "$(get-date) :[ERROR] $error_message" | Out-file $log_file -append -force;
} 

write-output "$(get-date):[INFO] CPU Check Script Complete" | out-file $log_file -append -force;



