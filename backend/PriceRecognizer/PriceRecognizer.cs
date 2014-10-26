using System;
using System.Collections.Generic;
using System.Linq;
using System.Drawing;
using Puma.Net;

namespace PriceRecognizer
{
    public static class PriceRecognizer
    {
        public static string ParseImage(Bitmap bitmap)
        {
            var pumaPage = new PumaPage(bitmap);//new PumaPage(@"D:\картинки\ценники\9e5208a1d53c9f7d9d18aa3e47773e6d.jpg");

            using (pumaPage)
            {
                pumaPage.FileFormat = PumaFileFormat.RtfAnsi;
                pumaPage.EnableSpeller = true;// Изначально False
                pumaPage.Language = PumaLanguage.Russian; // puma.checklanguage попробовать

                return pumaPage.RecognizeToString();
            }
        }

        public static bool ContainsSymbols(string s) //!!!!!!
        {
            for (int i = 0; i < s.Length; i++) {
                if (!Char.IsDigit(s[i]) && s[i] != ',' && s[i] != '.')
                    return true;
            }
            return false;
        }

        public static string RecognizePrice(string s)
        {
            HashSet<char> alowedChars = new HashSet<char>() { // '; = 3
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '(', ')', 'о', 'О', '.', ',', ' '
            };
            string toRecognize = s;
            string newRec = "";

            for (int i = 1; i < toRecognize.Length - 1; i++) { // for torecognize[1] and toRecognize[toRecognize.Length] d0:
                if ((toRecognize[i] == 'О' || (toRecognize[i] == '(' && toRecognize[i + 1] == ')')) && Char.IsDigit(toRecognize[i - 1]) == true) {
                    newRec += '0';
                } else
                    newRec += toRecognize[i];
                // o - копейки или центы
            }

            toRecognize = "";

            for (int i = 0; i < newRec.Length - 3; i++) {
                if (newRec[i] == ' ' && Char.IsDigit(newRec[i + 1]) && Char.IsDigit(newRec[i + 2]) && newRec[i + 3] == '0') {
                } else
                    toRecognize += newRec[i];
            }

            newRec = "";

            for (int i = 0; i < toRecognize.Length; i++) {
                if (!alowedChars.Contains(toRecognize[i]))
                    newRec += '#';
                else
                    newRec += toRecognize[i];
            }

            toRecognize = "";

            for (int i = 0; i < newRec.Length; i++) {
                if (newRec[i] == '#' || newRec[i] == ')' || newRec[i] == '(') {
                } else
                    toRecognize += newRec[i];
            }

            newRec = "";
            // 5400 54 4
            List<string> splited = toRecognize.Split(' ').ToList<string>();
            List<string> toRemove = new List<string>();

            foreach (var str in splited) {
                if (str == "") {
                    toRemove.Add("");
                }
            }

            foreach (var str2 in toRemove) {
                if (splited.Contains(str2))
                    splited.Remove(str2);
            }
            toRemove.Clear();

            foreach (var str in splited) {
                if (str.Length == 1) {
                    toRemove.Add(str);
                } else if (ContainsSymbols(str)) {
                    toRemove.Add(str);
                } else if (str[str.Length - 1] == ',' || str[str.Length - 1] == '.') {
                    toRemove.Add(str);
                } else if (str[0] == '0' || str[str.Length - 1] != '0') {
                    toRemove.Add(str);
                } else if (splited.Count > 1)
                if (Convert.ToInt32(str) < 1000) {
                    toRemove.Add(str);
                }
                //int a = Convert.ToInt32(str);

            }

            foreach (string str in toRemove) { // ContainsDigits
                if (splited.Contains(str))
                    splited.Remove(str);
            }

            /////
            foreach (var str in splited) {
                newRec += str;
                newRec += ' ';
            }

            return newRec.Trim();
        }
    }
}
