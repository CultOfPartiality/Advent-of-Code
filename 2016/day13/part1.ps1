. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)

#Test (solution in 11)
$favNumber = 10
$goal = (7,4)
#Live
$favNumber = 1364
$goal = (31,39)

$width = 60
$height = $width
$playfield = New-Object 'object[,]' $width,$height
function print-state{
    param($playfield)
    foreach($y in 0..($height-1)){
        $row = foreach($x in 0..($width-1)){
            $playfield[$x,$y].Value ? "#" : "."
        }
        write-host ($row -join "")
    }   
}
function distance-toGoal{
    param($currentCoords, $goalCoords)
    [math]::abs($goalCoords[0]-$currentCoords[0])+[math]::abs($goalCoords[1]-$currentCoords[1])
}

foreach($x in 0..($width-1)){
    foreach($y in 0..($height-1)){
        $val = $x*$x + 3*$x + 2*$x*$y + $y + $y*$y + $favNumber
        $binary = [Convert]::ToString($val, 2)
        $bitCount = $binary -split "" | ?{$_ -eq "1"} | measure | select -ExpandProperty Count

        $playfield[$x,$y] =  [PSCustomObject]@{
            Value = $bitCount % 2
            LeastSteps = [int32]::MaxValue
        }
    }
}
# print-state $playfield

#Setup, 1=wall. Now do A*
$searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int32]'
$playfield[1,1].LeastSteps=0
$searchSpace.Enqueue((1,1),(distance-toGoal (1,1) $goal ))

while($searchSpace.Count){
    $currentCoords = $searchSpace.Dequeue()
    foreach($delta in ((1,0),(0,1),(-1,0),(0,-1))){
        $newCoords = (($currentCoords[0]-$delta[0]),($currentCoords[1]-$delta[1]))
        #Valid coords
        if($newCoords -lt 0){continue}
        if($newCoords -ge $width){
            Write-Host "Expanded beyond $height grid. Might need bigger array?"
            continue
        }
        #Hit a wall
        if($playfield[$newCoords].Value -eq 1){continue}
        #If new tile has been visited in less steps, then we won't bother looking into it
        if($playfield[$newCoords].LeastSteps -lt $playfield[$currentCoords].LeastSteps){continue}
        #Otherwise, it's steps is this tiles steps++
        $playfield[$newCoords].LeastSteps = $playfield[$currentCoords].LeastSteps+1
        #If coords arent' the goal add to queue to check in future
        if(compare $newCoords $goal){
            $searchSpace.Enqueue($newCoords,(distance-toGoal $newCoords $goal))
        }
        else{
            #If we got here, we reached the goal
            write-host "Got to the goal in $($playfield[$newCoords].LeastSteps)"
        }
    }    
}


#part 2
($playfield.LeastSteps -le 50 ).Count


#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

