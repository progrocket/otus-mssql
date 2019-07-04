using System.Text.RegularExpressions;

public class RegExtension
{
    public static bool IsMatch(string value, string regex)
    {
        return Regex.IsMatch(value, regex);
    }
}
