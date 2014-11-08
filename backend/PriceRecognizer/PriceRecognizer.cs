using System;
using System.Collections.Generic;
using System.Linq;
using System.Drawing;
using Puma.Net;
using System.IO;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

namespace PriceRecognizer
{
    public static class PriceRecognizer
    {
        public static Bitmap ToBlackAndWhite(Bitmap b)
        {
            var bmp = b;
            PixelFormat pxf = PixelFormat.Format24bppRgb;
            Rectangle rect = new Rectangle(0, 0, bmp.Width, bmp.Height);
            BitmapData bmpData = bmp.LockBits(rect, ImageLockMode.ReadWrite, pxf);
            IntPtr ptr = bmpData.Scan0;
            int numBytes = bmpData.Stride * bmp.Height;
            int widthBytes = bmpData.Stride;
            byte[] rgbValues = new byte[numBytes];
            Marshal.Copy(ptr, rgbValues, 0, numBytes);
            for (int counter = 0; counter < rgbValues.Length - 2; counter += 3)
            {
                int value = rgbValues[counter] + rgbValues[counter + 1] + rgbValues[counter + 2];
                byte color_b = 0;
                color_b = Convert.ToByte(value / 3);
                rgbValues[counter] = color_b;
                rgbValues[counter + 1] = color_b;
                rgbValues[counter + 2] = color_b;
            }

            Marshal.Copy(rgbValues, 0, ptr, numBytes);
            bmp.UnlockBits(bmpData);
            return bmp;
        }

        public static string ParseImage(Bitmap bitmap)
        {
            string toReturn = "";
            PumaPage pumaPage = new PumaPage(ToBlackAndWhite(bitmap));

            using (pumaPage)
            {
                pumaPage.FileFormat = PumaFileFormat.TxtAscii;
                //pumaPage.AutoRotateImage = true;
                pumaPage.EnableSpeller = false;
                pumaPage.RecognizeTables = true;
                pumaPage.Language = PumaLanguage.Russian;

                toReturn = pumaPage.RecognizeToString();
            }

            return toReturn;
        }

        public static bool ContainsSymbols(string s) //!!!!!!
        {
            for (int i = 0; i < s.Length; i++)
            {
                if (!Char.IsDigit(s[i]) && s[i] != ',' && s[i] != '.')
                    return true;
            }
            return false;
        }

        public static string RecognizePrice(string s)
        {
            HashSet<char> alowedChars = new HashSet<char>()
            { // '; = 3
                '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '(', ')', 'о', 'О', '.', ',', ' '
            };
            string toRecognize = s;
            string newRec = "";

            for (int i = 1; i < toRecognize.Length - 1; i++)
            { // for torecognize[1] and toRecognize[toRecognize.Length] d0:
                if ((toRecognize[i] == 'О' || (toRecognize[i] == '(' && toRecognize[i + 1] == ')')) && Char.IsDigit(toRecognize[i - 1]) == true)
                {
                    newRec += '0';
                }
                else
                    newRec += toRecognize[i];
                // o - копейки или центы
            }

            toRecognize = "";

            for (int i = 0; i < newRec.Length - 1; i++)
                toRecognize += newRec[i];

            newRec = "";

            for (int i = 0; i < toRecognize.Length; i++)
            {
                if (!alowedChars.Contains(toRecognize[i]))
                    newRec += '#';
                else
                    newRec += toRecognize[i];
            }

            toRecognize = "";

            for (int i = 0; i < newRec.Length; i++)
            {
                if (newRec[i] == '#' || newRec[i] == ')' || newRec[i] == '(')
                {
                }
                else
                    toRecognize += newRec[i];
            }

            newRec = "";
            // 5400 54 4
            List<string> splited = toRecognize.Split(' ').ToList<string>();
            List<string> toRemove = new List<string>();

            foreach (var str in splited)
            {
                if (str == "")
                {
                    toRemove.Add("");
                }
            }

            foreach (var str2 in toRemove)
            {
                if (splited.Contains(str2))
                    splited.Remove(str2);
            }
            toRemove.Clear();

            foreach (var str in splited)
            {
                if (str.Length == 1)
                {
                    toRemove.Add(str);
                }
                else if (ContainsSymbols(str))
                {
                    toRemove.Add(str);
                }
                else if (str[str.Length - 1] == ',' || str[str.Length - 1] == '.')
                {
                    toRemove.Add(str);
                }
                else if (str[0] == '0' || str[str.Length - 1] != '0')
                {
                    toRemove.Add(str);
                } // else if (splited.Count > 1)

                /*  if (Convert.ToInt32(str) < 1000)
				{
                    toRemove.Add(str);
                }
                //int a = Convert.ToInt32(str); */

            }


            foreach (string str in toRemove)
            { // ContainsDigits
                if (splited.Contains(str))
                    splited.Remove(str);
            }

            /////
            foreach (var str in splited)
            {
                newRec += str;
                newRec += ' ';
            }

            return newRec.Trim();
        }
    }
}
