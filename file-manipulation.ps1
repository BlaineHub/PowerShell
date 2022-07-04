$list = Get-ChildItem -Path 'C:\Users\user\Documents\powershell\testfolder'

$detail_list = New-Object System.Collections.ArrayList

foreach ($file in $list){
$filename = $file.BaseName;
$name = (Split-Path -Path $filename -Leaf).split('_')[0];
$emp_id = (Split-Path -Path $filename -Leaf).split('_')[1];
[Datetime]$date = (Split-Path -Path $filename -Leaf).split('_')[2];
[Datetime]$startdate = '2012-04-29';



$extension =  $file.extension;
if ( ($date -ge $start_date) -and ($extension -eq '.emp') ) {
$eligibility = 'Yes'
}else{$eligibility = 'No'}
$detail = "$name, $emp_id, $eligibility" 
$detail_list.add($detail)
}

$detail_list.add("name,employeeid,eligibility")



for ($i=$detail_list.count; $i -ge 0; $i--){
Write-Output $detail_list[$i] >> "C:\Users\user\Documents\powershell\test.csv";
}




