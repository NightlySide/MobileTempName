package;

class Utils
{
    public static function clamp(value:Float, min:Float, max:Float)
    {
        if (value > max)
            return max;
        else if (value < min)
            return min;
        return value;
    }
}