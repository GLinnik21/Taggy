using System;
using System.Collections.Generic;

namespace PriceRecognizer
{
    public class RatesConverter
    {
        public RatesConverter()
        {
        }

        public static  string Exchange(string From , string To, string s/*int v изначальной валюты*/) // USD   9.2674099999999994e-05  BYR
        {
            double rateValue = Double.Parse("9,2674099999999994e-05");
            // Когда заработает открытие файла, считывать строку, проверять, содержит ли подстроку Tо, Regex -> курс
            // From -> USD = X и To -> USD = Y, то From -> To = X * (1 / Y)
            string[] toConvert = s.Split(' ');
            string toReturn = "";
            foreach (var str in toConvert)
            {
                toReturn += str + " --->> " + Math.Round(Int32.Parse(str) * rateValue, 3) + "<br>";
            }
            return toReturn;
        }
    }
}

