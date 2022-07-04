#Automating Report

#Sending Email Script

#Credentials
$smtpserver=""
$smtpport=""
$username=""
$password=""

#Recipients
$to = ''
$subject = "System Performance Report || $(Get-Date) "

#$Processes_Monitor = @("name","id","cpu","Pm")


#HTML REPORT POWERSHELL
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

$report = "C:\Users\user\Documents\powershell\System Performance.html";


$body = "<h1>Process Alert Information High CPU</h1> `n<h5>Updated on $(get-date)</h5>"
Get-Process | Sort-Object cpu -descending | Select-object -first 10 | ConvertTo-html -property ProcessName, id, CPU, PM `
 -head $head -body $body | Out-File $report

write-output "<br><br><br><br>" | out-file $report -append 

$body = "<h1>Process Alert Information High PM</h1> `n<h5>Updated on $(get-date)</h5>"
Get-Process | Sort-Object pm -descending | Select-object -first 10  | ConvertTo-html -property ProcessName, id, CPU, PM `
-body $body | Out-File $report -append

write-output "<br><br><br><br>" | out-file $report -append 

$body = "<h1>Services Status Review</h1> `n<h5>Updated on $(get-date)</h5>"
Get-Service | Select * | Group-object "status" | ConvertTo-html -property Count, Name `
-body $body | Out-File $report -append



#Subject & Body
$message = New-Object system.net.mail.mailmessage
$message.subject = $subject
$message.body = Get-Content $report
$message.isbodyhtml = $True
$message.from = "mycakediary1@gmail.com"
$message.to.add($to)

#Send Email
$smtp = New-Object System.net.mail.smtpclient($smtpserver,$smtpport);
$smtp.enablessl = $true
$smtp.credentials = New-Object system.net.networkcredential($username,$password);
$smtp.send($message)
