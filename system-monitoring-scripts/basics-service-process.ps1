#Services
Get-Service | Select-Object -first 5 
Get-Service | Where-Object { $_.status -eq 'stopped' } | Where-Object { $_.name -like "a*" }
Get-Service | Group-Object -property "status" 



#Processes
Get-Process | Select-Object -first 5
Get-Process | Sort-object cpu -Descending | Select-Object -property Name, CPU, PM -first 5
Get-Process | Where-Object { $_.CPU -ge 100 }

Get-Process | Sort-object cpu -Descending | Select-Object -first 5
Get-Process | Sort-object pm -Descending | Select-Object -first 5


Get-Process | Select-Object -first 10 | Foreach-object{
Write-Host "processing: Do something on" $_.Name
}


#Remove Old Files From Directory (older then 10 days)
$purge_dir = "C:\Users\user\Downloads\TestFiles"
$days = 10

Get-ChildItem -File -Recurse $purge_dir |
Where-object {$_.lastwritetime -lt (get-date).adddays(-10)} | % {
$_.fullname | del -Force    -whatif
}



















