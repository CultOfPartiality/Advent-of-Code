. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#Grab the coords class
. "$PSScriptRoot\..\..\OtherUsefulStuff\Class_Coords.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $data = get-content $Path

    # To simplify code, lookups are generated as hashtables
    $directions = "<", "v", ">", "^"
    $stepDeltas = @{
        [char]"<" = [coords](0, -1)
        [char]">" = [coords](0, 1)
        [char]"^" = [coords](-1, 0)
        [char]"v" = [coords](1, 0) 
    }
    $underlyingPaths = @{
        [char]"<" = "-"
        [char]">" = "-"
        [char]"^" = "|"
        [char]"v" = "|"
    }

    # Locate carts and build representation
    # Load track into hash keyed by coords. If this needs speeding up, could use an array and just eat the memory hit

    $carts = @()
    $tracks = @{}
    for ($y = 0; $y -lt $data.Count; $y++) {
        $row = $data[$y]
        for ($x = 0; $x -lt $row.length; $x++) {
            $symbol = $row[$x]

            # If it's a cart, add it to the array and add mutate the symbol to the underlying track piece
            if ($symbol -in $directions) {
                $carts += [PSCustomObject]@{
                    dir     = $symbol
                    coords  = [coords]($y, $x)
                    turnNum = 0
                }
                $symbol = $underlyingPaths[ $symbol ]
            }

            # Add track piece to the hashmap
            $tracks[ ([coords]($y, $x)).Hash() ] = $symbol
        }   
    }

    #Debug
    function print {
        $copy = $data | % { , $_.Clone().tochararray() }

        foreach ($cart in $carts) {
            $copy[$cart.coords.row][$cart.coords.col] = $cart.dir
        }
        $copy | % { write-host $_ }
    }

    # When simulating, order the carts before hand ascending y, then ascending x
    # Each step, check for duplicate coords. If found, that's our first crash and we're done
    # write-host "Direction: "$carts[0].dir" Coords:"$carts[0].coords.row","$carts[0].coords.col
    :inf while ($true) {
        # print
        $carts = $carts | sort { $_.coords.row }, { $_.coords.col }
        foreach ($cart in $carts) {
            # Move one step
            $cart.coords += $stepDeltas[$cart.dir]
            # Change direction if required, using ordered array and shifting the index
            switch ($tracks[$cart.coords.Hash()]) {
                "+" {
                    $dirIndex = $directions.IndexOf([string]$cart.dir)
                    switch ($cart.turnNum) {
                        0 { $cart.dir = [char]$directions[($dirIndex + 1) % 4] }
                        2 { $cart.dir = [char]$directions[($dirIndex + 3) % 4] }
                    }
                    $cart.turnNum = ($cart.turnNum + 1) % 3
                }
                "/" {
                    $cart.dir = switch ($cart.dir) {
                        "<" { [char]"v" }
                        ">" { [char]"^" }
                        "^" { [char]">" }
                        "v" { [char]"<" }
                    }
                }
                "\" {
                    $cart.dir = switch ($cart.dir) {
                        "<" { [char]"^" }
                        ">" { [char]"v" }
                        "^" { [char]"<" }
                        "v" { [char]">" }
                    }
                }
            }
            # Check for collisions
            if (($carts.coords | ? { $_ -eq $cart.coords } ).Count -gt 1) {
                break inf
            }
    
        }
    }
    "$($cart.coords.col),$($cart.coords.row)"

    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "7,3"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

