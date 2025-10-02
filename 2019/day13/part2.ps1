. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

function Solution {
    param ($Path)
   
    $memory = (get-content $Path) -split ',' | % { [int64]$_ } 
    $memory[0] = 2 #Play for free
    $ArcadeMachine = [Computer]::New($memory)
    $ArcadeMachine.RunComputer(0)

    $LEFT = -1
    $RIGHT = 1

    $ball = [PSCustomObject]@{
        x          = 0
        y          = 0
        prevx      = 0
        prevy      = 0
        dir        = 0
        movingdown = $true
    }
    $paddle = [PSCustomObject]@{
        x     = 0
        y     = 0
        prevx = 0
        prevy = 0
    }

    $maxX = 44
    $maxY = 23
    $Screen = New-Object "int[,]" ($maxY + 1), ($maxX + 1)

    function ParseMachineOutput() {
        $score = 0
        $ArcadeMachine.outputBuffer | Split-Array -GroupSize 3 | % {
            $x, $y, $id = $_
            if ($x -eq -1 -and $y -eq 0) {
                # write-host "Score: $id"
                $score = $id
            }
            else {
                $Screen[$y, $x] = $id
                switch ($id) {
                    #Block
                    2 {  }
                    #Paddle
                    3 {
                        $paddle.prevx = $paddle.x
                        $paddle.prevy = $paddle.y
                        $paddle.x = $x
                        $paddle.y = $y
                    
                    }
                    #Ball
                    4 {
                        $ball.prevx = $ball.x
                        $ball.prevy = $ball.y
                        $ball.x = $x
                        $ball.y = $y
                        $ball.MovingDown = $ball.y -gt $ball.prevy
                    }
                }
            }
        }
        $ArcadeMachine.outputBuffer = @()
        $score
    }

    do {
    
        $null = ParseMachineOutput
        #Work out the current ball direction
        if ($ball.y -eq ($paddle.y - 1) -and $ball.x -eq $paddle.x) {
            $ball.dir = - $ball.dir
        }
        else {
            $ball.dir = $ball.x -gt $ball.prevx ? $RIGHT : $LEFT #TODO - Need to work out if we just bounced
        }

        # Debug for drawing the screen
        if ($false) {
            for ($y = 0; $y -le $maxY; $y++) {
                $row = ""
                for ($x = 0; $x -le $maxX; $x++) {
                    $row += switch ($screen[$y, $x]) {
                        0 { " " }
                        1 { "▒" }
                        2 { "█" }
                        3 { "-" }
                        4 { "●" }
                    }
                }
                write-host $row
            }
            write-host " "
        }

        if (($ball.y + 1) -eq $paddle.y -and $ball.x -eq $paddle.x) { $JoystickPosition = 0 }
        elseif ($ball.dir -eq $LEFT) {
            if ($paddle.x -eq $ball.x) { $JoystickPosition = $LEFT }
            if ($paddle.x -eq ($ball.x - 1)) { $JoystickPosition = 0 }
            if ($paddle.x -lt ($ball.x - 1)) { $JoystickPosition = $RIGHT }
            if ($paddle.x -gt $ball.x) { $JoystickPosition = $LEFT }
        }
        else {
            if ($paddle.x -eq $ball.x) { $JoystickPosition = $RIGHT }
            if ($paddle.x -eq ($ball.x + 1)) { $JoystickPosition = 0 }
            if ($paddle.x -gt ($ball.x + 1)) { $JoystickPosition = $LEFT }
            if ($paddle.x -lt $ball.x) { $JoystickPosition = $RIGHT }
        }
        # write-host "Joystick - $($JoystickPosition)"
    
        $ArcadeMachine.RunComputer($JoystickPosition)

    } while (!$ArcadeMachine.complete)
    $score = ParseMachineOutput
    $score
}

$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" } #23981
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

