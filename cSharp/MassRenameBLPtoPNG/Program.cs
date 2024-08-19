using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MassRenameBLPtoPNG
{
  internal class Program
  {
    static void Main(string[] args)
    {
      var files = Directory.GetFiles(".", "*.blp", SearchOption.AllDirectories);
      foreach (var file in files)
      {
        var fileInfo = new FileInfo(file);
        fileInfo.MoveTo(file.Replace(".blp", ".png"));
      }

      files = Directory.GetFiles(".", "*.BLP", SearchOption.AllDirectories);
      foreach (var file in files)
      {
        var fileInfo = new FileInfo(file);
        fileInfo.MoveTo(file.Replace(".BLP", ".png"));
      }
    }
  }
}
