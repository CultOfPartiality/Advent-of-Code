. "$PSScriptRoot\..\..\Unit-Test.ps1"

function part1 {
    #Standard Inputs
    param ($path)
    $rawInput = Get-Content $path

    #Find S
    $startRow = ($rawInput -match 'S')[0]
    $row = $rawInput.IndexOf($startRow)
    $col = $startRow.IndexOf('S')
    $grid = [char[][]]$rawInput

    $totalDist = 0
    $currChar = 'S'

    #Check each direction to start the loop
    switch (1) {
        {$grid[$row][$col-1] -in '-','F','L' } { $currDir = "left"; break }
        {$grid[$row][$col+1] -in '-','7','J' } { $currDir = "right"; break }
        {$grid[$row-1][$col] -in '|','7','F' } { $currDir = "up"; break }
        {$grid[$row+1][$col] -in '|','J','L' } { $currDir = "down"; break }
        Default {write-host "ERROR: No next pipe from 'S'" -ForegroundColor Red;exit}
    }
    
    do {
        $totalDist++
        #Next indexes
        switch ($currDir) {
            "left"  {$col--}
            "right" {$col++}
            "up"    {$row--}
            "down"  {$row++}
        }
        #Next char
        $currChar = $grid[$row][$col]
        #Next direction
        $currDir = switch ($currChar) {
            "|"{ $currDir }
            "-"{ $currDir }
            "L"{ $currDir -eq "down" ? "right" : "up"   }
            "J"{ $currDir -eq "down" ? "left"  : "up"   }
            "7"{ $currDir -eq "up"   ? "left"  : "down" }
            "F"{ $currDir -eq "up"   ? "right" : "down" }
            "S"{ $currDir }
            Default {write-host "ERROR";exit}
        }
    } until ($currChar -eq 'S')
    
    #output result
    $totalDist/2
}

Unit-Test ${function:part1} "$PSScriptRoot\testcases\test1_4.txt" 4
Unit-Test ${function:part1} "$PSScriptRoot\testcases\test2_8.txt" 8

$res = part1 -path "$PSScriptRoot\input.txt"
write-host "Part 1: $res" -ForegroundColor Magenta