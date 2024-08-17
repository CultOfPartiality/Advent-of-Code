<#Test efficiency of some MD5 hashing

Run each implementation 1000 times, just incrementing some index as input
#>
$cycles = (1,10,100,1000,2000,10000)
$startText = "hello"
$results = @()

$tests = @()

#Powershell
. "$PSScriptRoot\..\..\UsefulStuff.ps1"
$tests += @{
    Name = "Native PowerShell"
    Command = {
        $hash = $startText
        for ($i = 0; $i -lt $testCount; $i++) { $hash = MD5 $hash }
    }
}

$tests += @{
    Name = "External Python"
    Command = {
        $hash = python "$PSSCriptRoot\native_md5.py" $startText $testCount
    }
}

foreach($test in $tests){
    $result = @{
        Method = $test.Name 
    }
    foreach ($testCount in $cycles) {
        $time = Measure-Command {
            & $test.Command
        }
        $result[$testCount] = "$($time.TotalMilliseconds)ms"
    }
    $results += [PSCustomObject]$result
}

$results | format-table $( @("Method") + ($cycles | %{"$_"}))| out-string | write-host