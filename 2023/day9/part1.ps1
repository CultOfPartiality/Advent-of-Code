#Get input
#$inputSource = "$PSScriptRoot/example.txt"
$inputSource = "$PSScriptRoot/input.txt"

# =================== Parse Data =================== 
$dataSets = Get-Content $inputSource | %{ ,[long[]] ($_ -split " ") }

$dataSets | %{
    $dataSet = ,$_
    $i=0
    while(($dataSet[$i]|group).Length -ne 1){
        #$dataSet += ,[long[]]($dataSet[$i][1..($dataSet[$i].Length-1)])
        $dataSet += ,[long[]](1..($dataSet[$i].Length-1) | %{$dataset[$i][$_] - $dataset[$i][$_-1]})
        $i++
    }
    $result = 0
    while($i -ge 0){
        $result+=$dataSet[$i][-1]
        $i--
    }
    $result
}|measure -Sum|select -ExpandProperty Sum