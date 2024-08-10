. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"


#function Solution {
#    param ($Path)

#Parse instructions
$data = get-content $Path  | %{
    $raw = $_
    $op,$arg1,$arg2,$null,$arg3 = $_ -split " "
    switch ($op) {
        "rect" {
            $A,$B = $arg1 -split "x"
            [PSCustomObject]@{
                Raw = $raw
                Op = $op
                A = [int]$A
                B = [int]$B
            }
        }
        "rotate"{
            if($arg1 -eq "row"){
                [PSCustomObject]@{
                    Raw = $raw
                    Op = "rot_row"
                    Row = [int]$arg2.Substring(2)
                    Shift = [int]$arg3
                }
            }
            else{
                [PSCustomObject]@{
                    Raw = $raw
                    Op = "rot_col"
                    Col = [int]$arg2.Substring(2)
                    Shift = [int]$arg3
                }
            }
            
        }
    }
    
}

#Setup datastructure to represent screen
$lcd = 1..(50*6) | %{$false}
function print-display{
    foreach($y in 0..5){
        $row = foreach($x in 0..49){
            $lcd[$y*50+$x] ? "#" : "."
        }
        Write-Host $($row -join "")
    }
}
function set-cell{
    param($x,$y)
    $lcd[$y*50+$x] = $true
}

#Operate over instructions
foreach($inst in $data){
    switch ($inst.Op) {
        "rect" { 
            for ($x = 0; $x -lt $inst.A; $x++) {
                for ($y = 0; $y -lt $inst.B; $y++) {
                    set-cell -x $x -y $y
                }
            }
        }
        "rot_row" {
            $oldRowCellIndexes = ($inst.Row*50)..($inst.Row*50+49)
            $oldRow = $lcd[$oldRowCellIndexes]
            $oldRowCellIndexes | %{
                $lcd[$_] = $oldRow[(50 + $_ - $inst.Shift) % 50]
            }
        }
        "rot_col" {
            $oldColCellIndexes = 0..5 | %{$_*50 + $inst.Col }
            $oldCol = $lcd[$oldColCellIndexes]
            0..5 | %{
                $lcd[$oldColCellIndexes[$_]] = $oldCol[ ( 6 + $_ - $inst.Shift ) % 6  ]
            }
        }
    }
    Write-Host "Instruction: $($inst.Raw)"
    print-display
    $z = $z

}

$pixelsLit = ($lcd | ?{$_} ).Count 
Write-Host "Part 1: $pixelsLit pixels lit" -ForegroundColor Magenta
Write-Host "Part 2: " -ForegroundColor Magenta
print-display

#Not 85

#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta
