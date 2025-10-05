using System.Management.Automation;


namespace Coord2D
{
    public class Coord : IEquatable<Coord>
    {
        public int row;
        public int col;

        public Coord(int[] ints)
        {
            this.row = ints[0];
            this.col = ints[1];
        }
        public Coord(int row, int col)
        {
            this.row = row;
            this.col = col;
        }

        public override bool Equals(object obj) => Equals(obj as Coord);
        public bool Equals(Coord obj)
        {
            if (obj is null) return false;
            if (Object.ReferenceEquals(this, obj)) return true;
            if (this.GetType() != obj.GetType()) return false;
            return (this.row == obj.row) && (this.col == obj.col);
        }

        public override int GetHashCode() => (row, col).GetHashCode();

        public static bool operator ==(Coord lhs, Coord rhs)
        {
            if (lhs is null)
            {
                if (rhs is null) return true;
                return false;
            }
            return lhs.Equals(rhs);
        }
        public static bool operator !=(Coord lhs, Coord rhs) => !(lhs == rhs);

        public string Hash()
        {
            return this.row.ToString() + "," + this.col.ToString();
        }
        public int Hash(int width)
        {
            return this.row * width + this.col;
        }

        public static Coord operator +(Coord lhs, Coord rhs)
        {
            return new Coord( (lhs.row + rhs.row), (lhs.col + rhs.col));
        }
        public static Coord operator *(Coord lhs, Coord rhs)
        {
            return new Coord((lhs.row * rhs.row), (lhs.col * rhs.col));
        }
        public static Coord operator *(Coord lhs, int[] rhs)
        {
            return new Coord((lhs.row * rhs[0]), (lhs.col * rhs[1]));
        }
    }



    //[Cmdlet(VerbsCommon.Get, "Test")]
    //public class GetTest : Cmdlet
    //{
    //    protected override void ProcessRecord()
    //    {
    //        WriteObject("Hi there");
    //    }
    //}
}
