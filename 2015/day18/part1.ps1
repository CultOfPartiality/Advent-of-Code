. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#function Solution {
#    param ($Path)

#The following line is for development
$real = $false
$Path = "$PSScriptRoot/testcases/test1.txt"
$cycles = 4

# $real = $true
# $Path = "$PSScriptRoot/input.txt"
# $cycles = 100

function windowNeighbourSum{
    param ($serialArray,$sideLen,$index)
    $sum = 0 
    $colMin = ($index % $sideLen) -gt 0 ? $index-1 : $index
    $colMax = ($index % $sideLen) -lt ($sideLen-1) ? $index+1 : $index
    if([Math]::Floor($index/$sideLen) -gt 0){
        $serialArray[($colMin-$sideLen)..($colMax-$sideLen)] | %{$sum += $_}
    }
    $serialArray[($colMin)..($colMax)] | %{$sum += $_}
    if([Math]::Floor($index/$sideLen) -lt $sideLen-1){
        $serialArray[($colMin+$sideLen)..($colMax+$sideLen)] | %{$sum += $_}
    }
    $sum - $serialArray[$index]
}

function printBoard{
    param($serialArray,$sideLen)
    $charcount = 0
    $serialArray|%{
        write-host  -NoNewline ($_ ? "#" : ".")
        $charcount++
        if($charcount % $sideLen -eq 0){
            Write-Host
        }
    }
    Write-Host "`n"
}

$data = get-content $Path | %{ $_.ToCharArray() | %{$_ -eq "#" ? 1 : 0}}
$sideLen = [System.Math]::Sqrt($data.Count)

if(-not $real){
    Write-host "Initial Board"
    printBoard $data $sideLen
}

foreach ($cycle in (1..$cycles)) {
    $data = for ($i = 0; $i -lt $data.Count; $i++) {
        switch ( windowNeighbourSum -serialArray $data -sideLen $sideLen -index $i ) {
            2       {$data[$i]}
            3       {1}
            Default {0}
        }

    }
    Write-host "Step $cycle"
    if(-not $real){
        printBoard $data $sideLen
    }
}
$result = $data | measure -Sum | select -ExpandProperty Sum
Write-Host "Part 1: $result lights still lit after $cycle cycles" -ForegroundColor Magenta


    
#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta

