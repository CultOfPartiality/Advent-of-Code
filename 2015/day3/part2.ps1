$inputSource = "$PSScriptRoot/input.txt"

$houses = @{"0.0"=2}
$santa = [PSCustomObject]@{x=0;y=0}
$roboSanta = [PSCustomObject]@{x=0;y=0}
$directions = [char[]](get-Content $inputSource)
#$directions = [char[]]'^vv^'
$robosTurn = $false
foreach($direction in $directions){
    $currentSanta = $robosTurn ? $roboSanta : $santa
    switch ($direction) {
        '>' {$currentSanta.x++}
        '<' {$currentSanta.x--}
        '^' {$currentSanta.y++}
        'v' {$currentSanta.y--}
        default {write-host "ERROR"; continue}
    }
    $houses."$($currentSanta.x).$($currentSanta.y)"+=1
    Clear-Variable currentSanta
    $robosTurn = -not $robosTurn
}
Write-Host "With RoboSanta helping $($houses.count) houses got at least one present"