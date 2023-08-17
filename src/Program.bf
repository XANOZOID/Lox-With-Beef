using System;
using System.IO;

namespace vacon {
	class Program {
		public static void Main() {
			String rootDir = scope .();
			Directory.GetCurrentDirectory(rootDir);

			let filePath = Path.InternalCombine(.. scope .(), rootDir, "src", "test", "basic_test.lox");

			String text = new String();
			if (File.ReadAllText(filePath, text) case .Ok) {
				Console.Write(text);

				Scanner l = scope .(text);

				for (;;) {
					var token = l.ScanToken();
					if (token.Type == .TokenEOF) break;
					Console.WriteLine(token.Source);
				}

			}
			
			Console.Read();
			/*delete rootDir;*/
			/*delete text;*/
		}
	}
}