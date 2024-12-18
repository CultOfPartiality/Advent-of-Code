$orthDeltas = (-1,0),(0,-1),(0,1),(1,0)

class Coords {

    $row
    $col
    Coords($row, $col) {
        $this.row = $row
        $this.col = $col
    }

    # This constructor allows casting an array to a Coords using "[coords]$array"
    Coords([array]$array_row_col) {
        $this.row = $array_row_col[0]
        $this.col = $array_row_col[1]
    }

    [boolean] Equals($otherCoord) {
        return ($this.row -eq $otherCoord.row -and $this.col -eq $otherCoord.col)
    }

    static [Coords] op_Addition ([Coords]$first, [Coords]$second) {
        return [Coords]::new( ($first.row + $second.row), ($first.col + $second.col) )
    }

    # Allow addition of an array
    static [Coords] op_Addition ([Coords]$first, [Array]$second) {
        return [Coords]::new( ($first.row + $second[0]), ($first.col + $second[1]) )
    }

    static [Coords] op_Subtraction ([Coords]$first, [Coords]$second) {
        return [Coords]::new( ($first.row - $second.row), ($first.col - $second.col) )
    }

    #Manhattan distance to other coord
    [int]Distance($otherCoord){
        return ([math]::ABS($this.row-$otherCoord.row) + [math]::ABS($this.col-$otherCoord.col))
    }

    #A string to use as a hash value, in the form "row,col"
    [string] Hash() {
        return "$($this.row),$($this.col)"
    }

    #Return as an array, for using and a 2D array index
    [array] Array() {
        return @($this.row,$this.col)
    }

    #The index in a 1D array
    [int] OneDimIndex($colCount) {
        return ($this.row*$colCount + $this.col)
    }

    #Check if a coord is with a rectangle, starting from 0,0
    [bool]Contained($rowCount,$colCount){
        return (
            $this.row -ge 0 -and
            $this.row -lt $rowCount -and
            $this.col -ge 0 -and
            $this.col -lt $colCount
        )
    }

    # Return orthogonal neighbours in "reading order" (top to bottom, then left to right)
    [array] OrthNeighbours() {
        return (
            ($this+(-1,0)),
            ($this+(0,-1)),
            ($this+(0,1)),
            ($this+(1,0))
        )
    }

    # Return orthogonal neighbours in "reading order" (top to bottom, then left to right), but that
    # are contained inside the map starting at 0,0
    [array] ValidOrthNeighbours($rowCount,$colCount) {
        return $this.OrthNeighbours().Where({$_.Contained($rowCount,$colCount)})
    }

}
