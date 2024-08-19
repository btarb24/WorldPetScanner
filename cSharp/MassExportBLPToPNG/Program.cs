using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using static System.Net.WebRequestMethods;
using File = System.IO.File;

namespace MassExportBLPToPNG
{
  internal class Program
  {
    static void Main(string[] args)
    {
      var filesEnumerable = Directory.EnumerateFiles(@"C:\Program Files (x86)\World of Warcraft\_retail_\BlizzardInterfaceArt\Interface", "*.blp", SearchOption.AllDirectories);

      var files = new List<string>(filesEnumerable);
      const int threadCount = 100;
      var assignments = new List<List<string>>();
      for (int i = 0; i < files.Count; i++)
      {
        var file = files[i];
        var thread = i % threadCount;
        if (assignments.Count - 1 < thread)
          assignments.Add(new List<string>());

        assignments[thread].Add(file);
      }

      var tasks = new List<Task>();
      foreach (var assignment in assignments)
      {
        tasks.Add(Task.Run(() => ProcessAssignment(assignment)));
      }

      Task.WhenAll(tasks).Wait();
    }

    private static void ProcessAssignment(List<string> assignment)
    {
      foreach (var file in assignment)
      {
        if (file.Contains("AdventureMap"))
          continue;

        var info = new FileInfo(file);
        var dir = info.Directory.FullName.Replace(@"C:\Program Files (x86)\World of Warcraft\_retail_\BlizzardInterfaceArt\Interface", "");
        dir = $@".{dir}\";
        if (!Directory.Exists(dir))
          Directory.CreateDirectory(dir);

        var outFile = info.Name.Replace(".blp", ".png");
        outFile = Path.Combine(dir, outFile);

        if (File.Exists(outFile))
          continue;

        var startInfo = new ProcessStartInfo(@"C:\Users\btarb\Documents\BlpConverter\BLPConverter.exe", $"\"{file}\" \"{outFile}\"");
        startInfo.CreateNoWindow = true;
        startInfo.UseShellExecute = false;
        var process = new Process() { StartInfo = startInfo };
        process.Start();
        process.WaitForExit();
      }
    }
  }
}
