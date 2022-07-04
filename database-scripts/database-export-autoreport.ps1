
###############Intial Setup########################

$BASE_DIR = "C:\Users\user\Documents\powershell\cakediaryreport"
$LOG_FILE = $BASE_DIR + "\daily_report_log.log"

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

$report = $Base_Dir + "\daily_products_report.html"
$xml_config = $Base_Dir + "\credentials.xml"
[xml]$xml_content = Get-Content $xml_config



Write-Output "$(get-date) :[INFO] Staring reort preparation script" | out-file $LOG_FILE -append -force;



$server = $xml_content.credentials.database_details.server
$database = $xml_content.credentials.database_details.database
$username = $xml_content.credentials.database_details.username
$password = $xml_content.credentials.database_details.password
$port = $xml_content.credentials.database_details.port

$db_query = $xml_content.queries.query1


###############PREPARING REPORT###########################

try{

$mysql = Connect-Mysql -user "$username" -password "$password" -database "$database" -server "$server" -port "$port"

$products = Invoke-mysql -connection $mysql -query "SELECT * FROM store_product"

$body = "<h1>Product Summary</h1> `n<h5>Updated on $(get-date)</h5>"
$products | Convertto-html -Property product_name, price, is_available -head $head -body $body | Out-File $report
}catch{
$error_message = $_.Exception.message
write-output "$(get-date) :[ERROR] Something went wrong : $error_message" | Out-file $log_file -append -force;
} finally{
write-output "$(get-date): [INFO] Closing database connection" | out-file $log_file -append -force;
} 

write-output "$(get-date):[INFO] Report Preparation Complete" | out-file $log_file -append -force;

###############Sending The Report Email########################

try{
#Credentials
$smtpserver= $xml_content.CREDENTIALS.EMAIL.SMTP
$smtpport=$xml_content.CREDENTIALS.EMAIL.SMTPPORT
$username=$xml_content.CREDENTIALS.EMAIL.USERNAME
$password=$xml_content.CREDENTIALS.EMAIL.PASSWORD


#Subject & Body
$message = New-Object system.net.mail.mailmessage
$message.subject = $xml_content.CREDENTIALS.EMAIL.SUBJECT
$message.body = Get-Content $report
$message.IsBodyHtml = $True
$message.to.add($xml_content.CREDENTIALS.EMAIL.TO)
$message.from = $xml_content.CREDENTIALS.EMAIL.FROM

#Send Email
$smtp = New-Object System.net.mail.smtpclient($smtpserver,$smtpport);
$smtp.enablessl = $true
$smtp.credentials = New-Object system.net.networkcredential($username,$password);
$smtp.send($message)
Write-Output "$(get-date) :[INFO] Email Sent Successfully" | out-file $LOG_FILE -append -force;
}catch{
$error_message = $_.Exception.message
write-output "$(get-date) :[ERROR] Something went wrong : $error_message" | Out-file $log_file -append -force;
} finally{
write-output "$(get-date): [INFO] Script Execution Completed" | out-file $log_file -append -force;
} 


