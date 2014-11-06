using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using System.IO;
using System.Drawing;
using System.Text.RegularExpressions;
using System.Web.Helpers;
using System.Net;

namespace Taggy
{
    public class HomeController : Controller
    {
        string ip;

        [HttpGet]
        public ActionResult Index()
        {
            ip = Request.UserHostAddress;
            return View();
        }

        public ActionResult About()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(HttpPostedFileBase file)
        {
            if (file == null)
            {
                return View(new RecognitionData{ ok = false, message = "Файл не выбран" });
            }
                
			var bitmap = new Bitmap(file.InputStream);
            ViewBag.Image = BitmapToBase64(bitmap);

            var data = new RecognitionData {
                ok = true,
                message = "",
                price = new []{
                    "25000",
                }
            };
			data = (RecognitionData) ConvertBitmap(bitmap).Data;

            return View(data);
        }

       [HttpPost]
        public ActionResult Convert(HttpPostedFileBase file)
        {
            if (file == null)
            {
                return View();
            }

            var bitmap = new Bitmap(file.InputStream);
            return ConvertBitmap(bitmap);
        }

      /*  [HttpPost]
        public Json[] Get()
        {
            //{"err": "failed to parse response from xe.com."}
            List<Json> jsons = new List<Json> ();

            Regex regex = new Regex ("{\"to\": \"(?<to>D{3})\", \"rate\": (?<rate>\\d.\\d+), \"from\": \"(?<from>D{3})\"}");

            using (StreamReader reader = new StreamReader (Directory.GetCurrentDirectory ()) + "\\Content\\Rates.txt")
            {
                string r = " ";
                while (r != null) 
                {
                    r = reader.ReadLine ();
                    if (regex.IsMatch(r))
                    {
                        Match match = regex.Match (r);

                        Json result = { 
                            "to" = match.Groups["to"].Value,
                            "rate" = match.Groups["rate"].Value,
                            "from" = match.Groups["from"].Value
                        };
                        jsons.Add (result);
                    }
                }
            }
           
            Json[] toReturn = { };
            int counter = 0;
            foreach (var j in jsons) {
                toReturn [counter] = j;
                counter++;
            }
            return toReturn;
        }*/

        private JsonResult ConvertBitmap(Bitmap bitmap)
        {
            bool isOk = true;
            string message = "";
            string recognition = "";

            try
            {
                recognition = PriceRecognizer.PriceRecognizer.ParseImage(bitmap);
                recognition = PriceRecognizer.PriceRecognizer.RecognizePrice(recognition);
            }
            catch (Exception ex) {
                isOk = false;
                message = ex.Message;
            }

            var rslt = new JsonResult();
            rslt.Data = new RecognitionData { 
                ok = isOk, 
                message = message,
                price = new []{ 
                    recognition,
                } 
            };
            rslt.JsonRequestBehavior = JsonRequestBehavior.AllowGet;
            return rslt;
        }

        static public string GetCountry(string ip)
        {
            string country = "";
            //http://ru.smart-ip.net/geoip/87.252.227.29/auto
            WebClient wclient = new WebClient ();
            country = wclient.DownloadString (String.Format ("http://ip-api.com/json/{0}", ip));
            return country;
        }
        static public string BitmapToBase64(System.Drawing.Bitmap bitmap)
        {
            var stream = new MemoryStream();
            bitmap.Save(stream, System.Drawing.Imaging.ImageFormat.Jpeg);
            stream.Position = 0;
            var fileBytes = new byte[stream.Length];
            stream.Read(fileBytes, 0, (int)stream.Length);
            return System.Convert.ToBase64String(fileBytes, Base64FormattingOptions.None);
        }
    }
}

