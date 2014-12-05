﻿using System;
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
            //PumaPage pumaPage = new PumaPage(ToBlackAndWhite(bitmap));
            PumaPage pumaPage = new PumaPage(bitmap);
            using (pumaPage)
            {
                pumaPage.FileFormat = PumaFileFormat.TxtAscii;
                pumaPage.EnableSpeller = false;
                pumaPage.RecognizeTables = true;
                pumaPage.Language = PumaLanguage.Russian;
                //pumaPage.AutoRotateImage = true;
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
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '(', ')', 'о', 'О', '.', ',', ' ', 'o', 'O', '`', Convert.ToChar("'"), ';', 'б'
            };
            string toRecognize = "";
            string newRec = "";

            for (int i = 0; i < s.Length; i++) // ';
            {
                if (!alowedChars.Contains(s[i])) toRecognize += "#";
                else 
                    toRecognize += s[i];
            }
                
            for (int i = 0; i < toRecognize.Length; i++)
            {
                int c = 0;
                if (i < toRecognize.Length - 2)
                if (toRecognize[i] == ' ' && toRecognize[i + 1] == Convert.ToChar("'") && toRecognize[i + 2] == ';')
                    c++;

                if (i < toRecognize.Length - 1 && c == 0)
                if (toRecognize[i] == '(' && toRecognize[i + 1] == ')')
                {
                    c++;
                    newRec += "0";
                }
                if (c == 0 && (toRecognize[i] == 'о' || toRecognize[i] == 'О' || toRecognize[i] == 'o' || toRecognize[i] == 'O'))
                {
                    c++;
                    newRec += "0";
                }
                if (i < toRecognize.Length - 1 && i > 0)
                if (c == 0 && toRecognize[i] == Convert.ToChar("'") && Char.IsDigit(toRecognize[i - 1]) && Char.IsDigit(toRecognize[i + 1]))
                {
                    c++;
                    newRec += "";
                }

                if (i > 0)
                if (toRecognize[i] == ';' && toRecognize[i - 1] == Convert.ToChar("'") && c == 0)
                {
                    c++;
                }
                if (i < toRecognize.Length - 1 && i > 0)
                if (c == 0 && toRecognize[i] == 'б' && Char.IsDigit(toRecognize[i - 1]) && Char.IsDigit(toRecognize[i + 1]))
                {
                    c++;
                    newRec += 6;
                }
                if (c == 0 && toRecognize[i] == Convert.ToChar("'") && toRecognize[i + 1] == ';' && toRecognize[i - 1] == ' ')
                {
                    c++;
                    newRec += "3";
                }
                if (c == 0)
                    newRec += toRecognize[i];
            }
            toRecognize = "";

            for (int i = 0; i < newRec.Length; i++)
            {
                if (i>0 && ((newRec[i - 1] == '.' || newRec[i - 1] == ',') && newRec[i] == ' '))
                {
                }
                else
                {
                    toRecognize += newRec[i];
                }

            }
            newRec = "";

            for (int i = 0; i < toRecognize.Length; i++)
            {
                if (i < toRecognize.Length - 1 && (toRecognize[i] == ' ' && (toRecognize[i + 1] == '.' || toRecognize[i + 1] == ',')))
                    {
                    }
                else
                    newRec += toRecognize[i];
            }
            toRecognize = "";

            for (int i = 0; i < newRec.Length; i++)
            {
                if (Char.IsDigit(newRec[i]) )
                    toRecognize += newRec[i];
                else
                    toRecognize += ' ';
            }
            newRec = "";

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
            toRemove.Clear(); // Удаление пустых строк

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
            }


            foreach (string str in toRemove)
            { 
                if (splited.Contains(str))
                    splited.Remove(str);
            }
                
            foreach (var str in splited)
            {
                newRec += str;
                newRec += ' ';
            }
            return newRec.Trim();
        }
    }
}
