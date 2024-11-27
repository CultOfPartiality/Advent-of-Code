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

}