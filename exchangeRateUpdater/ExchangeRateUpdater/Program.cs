using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Text.RegularExpressions;
using System.IO;

namespace ExchangeRateUpdater
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 1) 
            {
                Console.WriteLine("Run: this.exe [directory with Rates.txt]");
                return;
            }
            string url = "http://rate-exchange.appspot.com/currency?from={0}&to=USD";
            WebClient wclient = new WebClient();

            string directoryPath = String.Format(args[0]);
            string[] currencyAbbreviations = { "AUD", "EUR", "AZN", "ALL", "DZD", "USD", "XCD", "AOA", "ANG", "ARS", "AMD", 
                                                  "AWG", "AFA", "BSD", "BDT", "BBD", "BHD", "BYR", "BZD", "XOF", "BMD", "BGL", 
                                                  "BOB", "BAM", "BWP", "BRR", "BIF", "BTN", "VUV", "GBP", "HUF", "VEB", "VND",
                                                  "HTG", "GMD", "GHC", "GTQ", "GNF", "XAF", "GIP", "HML", "DKK", "GEL", "DJF", 
                                                  "DOP", "EGP", "ZMK", "WST", "ZWD", "ILS", "INR", "IDR", "JOD", "IQD", "IRR", 
                                                  "IEP", "ISK", "YER", "CVE", "KZT", "KYD", "KHR", "XAF", "CAD", "QAR", "KES", 
                                                  "CYP", "CNY", "COP", "KMF", "CRC", "CUP", "KWD", "KGS", "LAK", "LVL", "LSL", 
                                                  "LRD", "LBP", "LYD", "LTL", "CHF", "MUR", "MRO", "MGF", "MKD", "MWK", "MYR", 
                                                  "MVR", "MTL", "MAD", "MXN", "MZM", "MDL", "MNT", "XCD", "MMK", "ZAR", "NPR", 
                                                  "NGN", "ANG", "NIO", "NZD", "XPF", "NOK", "AED", "OMR", "PKR", "PGK", "PYG", 
                                                  "PEN", "PLZ", "RUB", "RWF", "ROL", "SVC", "STD", "SAR", "SZL", "KPW", "SCR", 
                                                  "XCD", "XOP", "RSD", "SGD", "SYP", "SIT", "SBD", "SOS", "SDD", "SRG", "SLL", 
                                                  "TMM", "THB", "TWD", "TZS", "TOP", "TTD", "TND", "TMM", "TRY", "UGS", "UZS", 
                                                  "UAH", "UYP", "DKK", "FJD", "PHP", "FKP", "HRK", "CZK", "CLP", "CHF", "SEK", 
                                                  "LKR", "ESC", "ERN", "EEK", "ETB", "KRW", "ZAR", "JPY" };
            Dictionary<string, double> dict = new Dictionary<string, double>(); // Аббр. + курс при конвертации в доллар США
            Regex regex = new Regex(@"""rate"": (?<rate>\d+\.\d+\S{4})\,");
            string response = null;


            using (StreamWriter writer = new StreamWriter(directoryPath + "\\Rates.txt"))
            {
                foreach (var abb in currencyAbbreviations)
                {
                    Console.WriteLine("Starting updating exchange rate for {0}...", abb);
                    try
                    {
                        response = wclient.DownloadString(String.Format(url, abb));
                        if (response != null)
                            if (!response.Contains("fail"))
                            {
                                string rate = "";
                                Match match = regex.Match(response);
                                string to = "USD";
                                string from = abb;
                                if (regex.IsMatch(response))
                                    rate = match.Groups["rate"].Value;
                                else 
                                {
                                    Regex r = new Regex(@"""rate"": (?<rate>\d+\.\d+)");
                                    if (r.IsMatch(response))
                                    {
                                        Match m = r.Match(response);
                                        rate = m.Groups["rate"].Value + "0";
                                    }
                                }
                                writer.WriteLine(to + "\t" + rate + "\t" + from);
                            }
                    }

                    catch (Exception e)
                    {
                        Console.WriteLine("Error: " + e);
                    }
                }
            }
        }
    }
}
