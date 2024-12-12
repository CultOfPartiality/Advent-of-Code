. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

# To handle coords
. "$PSScriptRoot\Class_Coords.ps1"

function Solution {
   param ($Path)

$data = get-content $Path

# -- The Plan --
# First work out all the nodes (e.g. all numbers in the input data)
# Then, for each node, work out the distance from it to any other node (suspect this will be repeated A*)
# Use this data to build a graph of all possible connections and distances (do we need split these if a path goes through a third node?)
#   Alternatively, we can just check all possible permutations?
# -- End Plan --

# Loop over the playfield, and setup the objects to represent the playfield. We'll only grab the valid squares.
# As such, we can skip the first and last row, as they're all blockers, same as first and last column
# These are stored in a hash, using the coordinates as the key. We can easily check if a square's neighbour exists by looking up the
# coordinates using the hash
$numbers = @()
$distances = @{}
$squares = @{}
for ($row = 1; $row -lt $data.Count - 1; $row++) {
    $rowData = ($data[$row]).ToCharArray()
    for ($col = 1; $col -lt $rowData.Count - 1; $col++) {
        $squareValue = $rowData[$col]
        if ($squareValue -eq "#") { continue }
        $node = [PSCustomObject]@{
            data       = $squareValue
            coords     = [Coords]::new($row, $col)
            # nextSquare = $null
            steps      = [int32]::MaxValue
        }
        if ($squareValue -match "\d") {
            $numbers += $node
        }
        $squares[$node.coords.Hash()] = $node
    }
}
$numbers = $numbers | sort { $_.data }

# Get all neighbouring squares
function Get-ValidNeighours {
    param($square)
    @((1, 0), (0, 1), (-1, 0), (0, -1)) | % {
        $hash = "$($square.Coords.row + $_[0]),$($square.Coords.col + $_[1])"
        if ( $squares.ContainsKey($hash) ) {
            $squares[$hash]
        }
    }
}

# Do A* (or is it dijkstra?) to avoid redoing work within each search. We'll use a queue, so as to do a bredth first search
# TODO: will need to reset nextSquares for next round of A*
# for each number in numbers
foreach ($startingNumber in $numbers) {
    Write-Host "Starting dijkstra from number $($startingNumber.data)"
    $squares.Values | %{
        $_.steps=[int32]::MaxValue
    #    $_.nextSquare=$null
    }
    $startingNumber.steps = 0
    $searchSpace = New-Object System.Collections.Queue
    $searchSpace.Enqueue($startingNumber)

    while ($searchSpace.Count) {
        $square = $searchSpace.Dequeue()
        Get-ValidNeighours($square) | ? { $_.steps -gt ($square.steps+1) } | % {
            $_.steps = $square.steps + 1
            #$_.nextSquare = $square
            $searchSpace.Enqueue($_)
        }
    }
    foreach ($number in ($numbers | ? { $_.data -ne $startingNumber.data } ) ) {
        $distances["$($startingNumber.data)->$($number.data)"] = $number.steps
    }
}

write-host "Generating permutations..."
$perms = Get-AllPermutations (1..($numbers.Count-1)) | %{ ,(@(,0) + $_ + @(,0))}
write-host "Generated $($perms.Count) permutations"
$minSteps = [int32]::MaxValue
$minSequence = ""
foreach ($perm in $perms) {
    $totalSteps = 0
    $lastNode = 0
    $sequence = "0->"
    for ($i = 1; $i -lt $perm.Count; $i++) {
        $totalSteps += $distances["$lastNode->$($perm[$i])"]
        $sequence += "$($perm[$i])"
        $lastNode = $perm[$i]
    }
    if($totalSteps -lt $minSteps){
        $minSteps = $totalSteps
        $minSequence = $sequence
    }
}
$minSteps
    
}
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 14
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

