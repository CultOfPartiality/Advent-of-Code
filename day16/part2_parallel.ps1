. "$PSScriptRoot\..\Unit-Test.ps1"


function Solution {
    param ($Path)

    $data = Get-Content $Path

    $boardWidth = $data[0].Length
    $boardHeight = $data.Count

    $funcDef = ${function:Test-Start}.ToString()
    
    $vert1 = 0..($boardHeight - 1) | ForEach-Object -Parallel {
        ${function:Test-Start} = $using:funcDef
        write-host "Vert1 $($_+1)/$using:boardHeight"
        Test-Start -data $using:data -startLaser ([PSCustomObject]@{ x = 0; y = $_; direction = "right" })
        Test-Start -data $using:data -startLaser ([PSCustomObject]@{ x = $using:boardWidth-1; y = $_; direction = "left" })
    } -ThrottleLimit 120
    #[gc]::Collect()
    $hozis = 0..($boardWidth - 1) | ForEach-Object -Parallel {
        ${function:Test-Start} = $using:funcDef
        write-host "Hoz $($_+1)/$using:boardWidth"
        Test-Start -data $using:data -startLaser ([PSCustomObject]@{ x = $_; y = 0; direction = "down" })
        Test-Start -data $using:data -startLaser ([PSCustomObject]@{ x = $_; y = $using:boardHeight-1; direction = "up" })
    } -ThrottleLimit 120
    #[gc]::Collect()
    ($vert1 + $hozis) | measure -Maximum | select -ExpandProperty Maximum
}

function Test-Start {
    param ($data, $startLaser)

    #Seed the data with extra metadata
    $board = $data | % {
        , @([char[]]$_ | % {
                [PSCustomObject]@{
                    tile       = $_
                    energised  = $false
                    directions = @()
                }
            })
    }
    $boardWidth = $board[0].Count
    $boardHeight = $board.Count

    #generate a list of lasers, adding the first one
    $lasers = @($startLaser)

    #pick the first laser, follow it through.
    #if it hits a mirror add it to the list of lasers
    #if it is following a path a previous laser has followed, or it hits
    #the wall, then remove it from the list
    while ($lasers.Count -gt 0) {
        $laser = $lasers[0]
        if ($laser.x -eq $boardWidth -or
            $laser.x -lt 0 -or
            $laser.y -eq $boardHeight -or
            $laser.y -lt 0) {
            $null, [object[]]$lasers = $lasers
            continue
        }


        $cell = $board[$laser.y][$laser.x]    

        #check if laser has already traveled here.
        #If so, remove from the array
        if ($laser.direction -in $cell.directions) {
            $null, [object[]]$lasers = $lasers
            continue
        }
        else {
            $cell.directions += $laser.direction
            $cell.energised = $true
        }

        #change direction
        switch ($cell.tile) {
            '.' { <#do nothing#> break }
            '|' {
                if ($laser.direction -in "left", "right") {
                    #$lasers += [PSCustomObject]@{x=$laser.x;y=$laser.y;direction="down"}
                    $newLaser = $laser.psobject.copy(); $newLaser.direction = "down"
                    $laser.direction = "up"
                    $lasers += $newLaser
                }
            }
            '-' {
                if ($laser.direction -in "up", "down") {
                    $lasers += [PSCustomObject]@{x = $laser.x; y = $laser.y; direction = "right" }
                    $laser.direction = "left"
                }
            }
            '/' {
                switch ($laser.direction) {
                    "left" { $laser.direction = 'down' }
                    "right" { $laser.direction = 'up' }
                    "up" { $laser.direction = 'right' }
                    "down" { $laser.direction = 'left' }
                }
            }
            '\' {
                switch ($laser.direction) {
                    "left" { $laser.direction = 'up' }
                    "right" { $laser.direction = 'down' }
                    "up" { $laser.direction = 'left' }
                    "down" { $laser.direction = 'right' }
                }
            }
        }

        #new coords
        switch ($laser.direction) {
            "left" { $laser.x-- }
            "right" { $laser.x++ }
            "up" { $laser.y-- }
            "down" { $laser.y++ }
        }
    }
    
    ($board.energised -eq $true).Count
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 51
[gc]::Collect()
$result = Solution "$PSScriptRoot\input.txt"
[gc]::Collect()
Write-Host "Part 2: $result" -ForegroundColor Magenta