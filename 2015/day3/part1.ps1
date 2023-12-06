$inputSource = "$PSScriptRoot/input.txt"

$houses = @{"0,0"=1}
$x = 0
$y = 0
$directions = [char[]](get-Content $inputSource)

foreach($direction in $directions){
    switch ($direction) {
        '>' {$x+=1}
        '<' {$x-=1}
        '^' {$y+=1}
        'v' {$y-=1}
        default {continue}
    }
    $houses."$x,$y"+=1
}
Write-Host "$($houses.count) houses got at least one present"