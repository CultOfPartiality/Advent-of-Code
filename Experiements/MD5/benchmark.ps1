<#Test efficiency of some MD5 hashing

Run each implementation 1000 times, just incrementing some index as input
#>
$testCount = 100
$results = @()


$time = Measure-Command {    
    . "$PSScriptRoot\..\..\UsefulStuff.ps1"
    for ($i = 0; $i -lt $testCount; $i++) {MD5 "$i"}
}
$results += [PSCustomObject]@{
    Medthod = "Current Powershell"
    Time = "$($time.TotalMilliseconds)ms" 
}

$time = Measure-Command {    
    for ($i = 0; $i -lt $testCount; $i++) {
        python "$PSSCriptRoot\native_md5.py" "$i"
    }
}
$results += [PSCustomObject]@{
    Medthod = "External Python"
    Time = "$($time.TotalMilliseconds)ms" 
}






$results | format-table | out-string | write-host