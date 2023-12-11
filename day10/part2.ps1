. "$PSScriptRoot\..\Unit-Test.ps1"

function part1 {
    #Standard Inputs
    param ($path)
    $rawInput = Get-Content $path

    $width = $rawInput[0].Length
    $height = $rawInput.Count
    $rawGrid = [char[][]]$rawInput
    $newGrid = New-Object char[][] $height,$width
    for ($row = 0; $row -lt $height; $row++) {
        for ($col = 0; $col -lt $width; $col++) {
            $newGrid[$row][$col] = "_"
        }
    }

    #Find S
    $startRow = ($rawInput -match 'S')[0]
    $row = $rawInput.IndexOf($startRow)
    $col = $startRow.IndexOf('S')
    
    

    $totalDist = 0
    $currChar = 'S'
    $turns = 0 
    $LEFT = 1; $RIGHT = -1

    #Check each direction to start the loop
    switch (1) {
        {$rawGrid[$row][$col-1] -in '-','F','L' } { $currDir = "left"; break }
        {$rawGrid[$row][$col+1] -in '-','7','J' } { $currDir = "right"; break }
        {$rawGrid[$row-1][$col] -in '|','7','F' } { $currDir = "up"; break }
        {$rawGrid[$row+1][$col] -in '|','J','L' } { $currDir = "down"; break }
        Default {write-host "ERROR: No next pipe from 'S'" -ForegroundColor Red;exit}
    }
    
    do {
        $totalDist++
        #Set tile as Pipe
        $newGrid[$row][$col] = "P"
        #Check either side of the pipe. In the direction of travel:
        #   - A non-pipe on the left of a pipe gets a "1"
        #   - A non-pipe on the right of the pipe gets a "2"
        switch ($currDir) {
            "left"  {
                if($row -lt $height-1){$newGrid[$row+1][$col] = $newGrid[$row+1][$col] -notmatch "[P12]" ? "1" : $newGrid[$row+1][$col]}
                if($row -gt 0){$newGrid[$row-1][$col] = $newGrid[$row-1][$col] -notmatch "[P12]" ? "2" : $newGrid[$row-1][$col]}
            }
            "right" {
                if($row -lt $height-1){$newGrid[$row+1][$col] = $newGrid[$row+1][$col] -notmatch "[P12]" ? "2" : $newGrid[$row+1][$col]}
                if($row -gt 0){$newGrid[$row-1][$col] = $newGrid[$row-1][$col] -notmatch "[P12]" ? "1" : $newGrid[$row-1][$col]}
            }
            "up"    {
                if($col -gt 0){$newGrid[$row][$col-1] = $newGrid[$row][$col-1] -notmatch "[P12]" ? "1" : $newGrid[$row][$col-1]}
                if($col -lt $width-1){$newGrid[$row][$col+1] = $newGrid[$row][$col+1] -notmatch "[P12]" ? "2" : $newGrid[$row][$col+1]}
            }
            "down"  {
                if($col -gt 0){$newGrid[$row][$col-1] = $newGrid[$row][$col-1] -notmatch "[P12]" ? "2" : $newGrid[$row][$col-1]}
                if($col -lt $width-1){$newGrid[$row][$col+1] = $newGrid[$row][$col+1] -notmatch "[P12]" ? "1" : $newGrid[$row][$col+1]}
            }
        }
        #Next indexes
        switch ($currDir) {
            "left"  {$col--}
            "right" {$col++}
            "up"    {$row--}
            "down"  {$row++}
        }
        #Check either side of the pipe. In the direction of travel:
        #   - A non-pipe on the left of a pipe gets a "1"
        #   - A non-pipe on the right of the pipe gets a "2"
        switch ($currDir) {
            "left"  {
                if($row -lt $height-1){$newGrid[$row+1][$col] = $newGrid[$row+1][$col] -notmatch "[P12]" ? "1" : $newGrid[$row+1][$col]}
                if($row -gt 0){$newGrid[$row-1][$col] = $newGrid[$row-1][$col] -notmatch "[P12]" ? "2" : $newGrid[$row-1][$col]}
            }
            "right" {
                if($row -lt $height-1){$newGrid[$row+1][$col] = $newGrid[$row+1][$col] -notmatch "[P12]" ? "2" : $newGrid[$row+1][$col]}
                if($row -gt 0){$newGrid[$row-1][$col] = $newGrid[$row-1][$col] -notmatch "[P12]" ? "1" : $newGrid[$row-1][$col]}
            }
            "up"    {
                if($col -gt 0){$newGrid[$row][$col-1] = $newGrid[$row][$col-1] -notmatch "[P12]" ? "1" : $newGrid[$row][$col-1]}
                if($col -lt $width-1){$newGrid[$row][$col+1] = $newGrid[$row][$col+1] -notmatch "[P12]" ? "2" : $newGrid[$row][$col+1]}
            }
            "down"  {
                if($col -gt 0){$newGrid[$row][$col-1] = $newGrid[$row][$col-1] -notmatch "[P12]" ? "2" : $newGrid[$row][$col-1]}
                if($col -lt $width-1){$newGrid[$row][$col+1] = $newGrid[$row][$col+1] -notmatch "[P12]" ? "1" : $newGrid[$row][$col+1]}
            }
        }
        #Next char
        $currChar = $rawGrid[$row][$col]
        #Next direction
        # (also keep track of turns)
        $currDir = switch ($currChar) {
            "|"{ $currDir }
            "-"{ $currDir }
            "L"{ 
                if($currDir -eq "down"){
                    $turns+=$LEFT;
                    "right"
                }
                else{
                    $turns+=$RIGHT;
                    "up"
                }
            }
            "J"{
                if($currDir -eq "down"){
                    $turns+=$RIGHT;
                    "left"
                }
                else{
                    $turns+=$LEFT;
                    "up"
                }
            }
            "7"{ 
                if($currDir -eq "up"){
                    $turns+=$LEFT;
                    "left"
                }
                else{
                    $turns+=$RIGHT;
                    "down"
                }
            }
            "F"{
                if($currDir -eq "up"){
                    $turns+=$RIGHT;
                    "right"
                }
                else{
                    $turns+=$LEFT;
                    "down"
                }
            }
            "S"{ $currDir = $currDir }
            Default {write-host "ERROR";exit}
        }
        
    } until ($newGrid[$row][$col] -eq 'P')

    #Clear anything in the rawGrid that isn't a pipe
    #$rawGrid -replace "[LJ7FS|-]","."

    #DEBUG
    #Write-Host "Debug:";$rawGrid | %{write-host ($_ -join "") -BackgroundColor Gray -NoNewline; Write-Host -BackgroundColor Black};write-host ""

    while(($newGrid | %{$_|where{$_ -eq "_"}}).Count -gt 0){
        for ($row = 0; $row -lt $height; $row++) {
            for ($col = 0; $col -lt $width; $col++) {
                $minRow = $row -eq 0 ? 0 : $row-1
                $maxRow = $row -eq $height-1 ? $row : $row+1
                $minCol = $col -eq 0 ? 0 : $col-1
                $maxCol = $col -eq $width-1 ? $col : $col+1

                $surroundings = $newGrid[$minrow][$minCol..$maxCol] +
                                $newGrid[$row][$minCol..$maxCol] +
                                $newGrid[$maxrow][$minCol..$maxCol]
                
                if($newGrid[$row][$col] -ne "P" -and $surroundings -match "[12]"){
                    $minCol..$maxCol | %{
                        $val = [regex]::Match($surroundings,"[12]").Value
                        if($newGrid[$minRow][$_] -eq "_"){$newGrid[$minRow][$_] = $val}
                        if($newGrid[$row][$_] -eq "_"){$newGrid[$row][$_] = $val}
                        if($newGrid[$maxRow][$_] -eq "_"){$newGrid[$maxRow][$_] = $val}
                    }
                }
            }
        }


        #DEBUG
        #Write-Host "Debug:";$newGrid | %{write-host ($_ -join "") -BackgroundColor Gray -NoNewline; Write-Host -BackgroundColor Black};write-host ""
        #sleep 3

    }
    $insideChar = $turns -gt 0 ? "1" : "2"
    $tilesInside = ($newGrid | %{$_|where{$_ -eq $insideChar}}).Count
    
    #output result
    $tilesInside
}

Unit-Test ${function:part1} "$PSScriptRoot\testcases\test1_4.txt" 1
Unit-Test ${function:part1} "$PSScriptRoot\testcases\test2_8.txt" 1
Unit-Test ${function:part1} "$PSScriptRoot\testcases\test3_8.txt" 8

$res = part1 -path "$PSScriptRoot\input.txt"
write-host "Part 2: $res" -ForegroundColor Magenta