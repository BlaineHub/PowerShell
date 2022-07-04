#error handling
$file = "ImportantData.txt"

try{
Get-Content $file -ErrorAction Stop -ErrorVariable $err;
}catch {
$error_mess = $_.Exception.Message;
$error_mess;
Write-Host "$(Get-Date) sorry $file you does not exist" -ForegroundColor Yellow
}finally{
Write-Host "$(Get-Date) Goodbyt " -ForegroundColor Green
}

Get-Help about_Try_Catch_Finally -ShowWindow about_Try_Catch_Finally