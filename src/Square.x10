/**
 * Struct defining a square location holding a pawn.
 */
public struct Square
{
    public val x: int;
    public val y: int;

    public def this(x: int, y: int)
    {
        this.x = x;
        this.y = y;
    }
}
