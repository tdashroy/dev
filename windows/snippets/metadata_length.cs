var shellAppType = Type.GetTypeFromProgID("Shell.Application");
dynamic shellApp = Activator.CreateInstance(shellAppType);
var folderPath = @"C:\path\to\folder";
var folder = shellApp.NameSpace(folderPath);
List<string> arrHeaders = new List<string>(); 
for (int i = 0; i < short.MaxValue; i++)
{
    string header = folder.GetDetailsOf(null, i);
    if (String.IsNullOrEmpty(header))
        break;
    arrHeaders.Add(header);
}

var lengthIdx = arrHeaders.FindIndex(x => x == "Length");
TimeSpan totalLength = new TimeSpan();
int i = 0;
foreach (var item in folder.Items())
{
    TimeSpan length = TimeSpan.ParseExact(folder.GetDetailsOf(item, lengthIdx), "g", null, System.Globalization.TimeSpanStyles.None);
    totalLength += length;
    Console.WriteLine($"{(++i).ToString("D2")}: {item.Name()} - {length} - {totalLength}");
}