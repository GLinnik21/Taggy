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

        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        public ActionResult Information()
        {
            Bitmap bitmap = new Bitmap (Server.MapPath("~/Content/ImageAndroid.jpg"));
            ViewBag.InfoAndroid = BitmapToBase64 (bitmap);

            bitmap = new Bitmap (Server.MapPath("~/Content/ImageWP.jpg"));
            ViewBag.InfoWP = BitmapToBase64 (bitmap);

            return View ();
        }
        public ActionResult About()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Index(HttpPostedFileBase file)
        {
            var Long = ViewBag.Long;
            var Lat = ViewBag.Lat;
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
                },
                ip = Request.ServerVariables["REMOTE_ADDR"]
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

        public ActionResult GetSymbols() // Возвращает все станы, используемые в них национальные валюты и их символы
        {
            List<object> list = new List<object> ();
            using (var reader = System.IO.File.OpenText (Server.MapPath ("~/Countries.txt"))) //EUR € IT // Открытие файла с символами на сервере, получение пути к файлу
            {
                string rstring = reader.ReadLine ();
                while (rstring != null) 
                {
                    string[] splited = rstring.Split (' '); // Регуляное выражение не работало
                    if (splited.Length > 0) 
                    {
                        list.Add (new { // Формирование объекта для возвращения
                            Currency = splited[0],
                            Symbol = splited[1],
                            CountryCode = splited[2]
                        });
                    }
                    rstring = reader.ReadLine ();
                }
                JsonResult toReturn = new JsonResult ();
                toReturn.Data = list.ToArray ();
                toReturn.JsonRequestBehavior = JsonRequestBehavior.AllowGet;
                return toReturn; // Возвращение результата
            }

            return new JsonResult ();
        }
        public ActionResult GetRates() // Возвращение курсов валют относительно доллара
        {
            List<object> rateList = new List<object> ();
            using (var reader = System.IO.File.OpenText(Server.MapPath("~/Rates.txt")))  // Аналогично открытие файла
            {
                string rstring = reader.ReadLine ();
                Regex r = new Regex (@"(?<to>[A-Z]{3})\t(?<ratehigh>\d+)\.(?<ratelow>\S+)\t(?<from>[A-Z]{3})"); // OK Регярное выражение получения названия валюты, курса

                while (rstring != null) 
                {
                    if (!rstring.Contains ("failed")) 
                    {
                        MatchCollection collection = r.Matches (rstring);
                        if (collection != null) 
                        {
                            foreach (Match match in collection) 
                            {
                                rateList.Add (new { // Формирование объектов для возвращения
                                    To = match.Groups ["to"].Value, 
                                    From = match.Groups ["from"].Value,
                                    Rate = match.Groups ["ratehigh"].Value + /*System.Globalization.NumberFormatInfo.CurrentInfo.NumberDecimalSeparator*/ "." + match.Groups ["ratelow"].Value
                                });
                            }
                        }
                    }
                    rstring = reader.ReadLine ();
                }
            }
            JsonResult toReturn = new JsonResult ();

            toReturn.Data = rateList.ToArray();
            toReturn.JsonRequestBehavior = JsonRequestBehavior.AllowGet;
            return toReturn; // Возвращение JSON строки
        }

        private JsonResult ConvertBitmap(Bitmap bitmap)
        {
            Bitmap sourceBitmap = bitmap;
            bool isOk = true;
            string message = "";
            string recognition = "";
            string rates = "";
            string ip = Request.ServerVariables["HTTP_X_FORWARDED_FOR"] ?? Request.ServerVariables ["REMOTE_ADDR"];
            try
            {
                recognition = PriceRecognizer.PriceRecognizer.ParseImage(bitmap,1); // В строку возвращается распознанный текст
                recognition = PriceRecognizer.PriceRecognizer.RecognizePrice(recognition); // Отсеивание ненужных символов, на выходе - числа через пробел
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
                },
                position = new []{
                    "",
                    "",
                },
                ip = ip
            };
            rslt.JsonRequestBehavior = JsonRequestBehavior.AllowGet;
            return rslt;
        }
            
        static public string GetCountry(string ip) // Не нужно,  выполняется в JavaScripte
        {
            string country = "";
            WebClient wclient = new WebClient ();
            country = wclient.DownloadString (String.Format ("http://ip-api.com/json/{0}", ip));
            if (country != null) 
            {
                Regex r = new Regex (@"""country"":""(?<country>\D+)"",""countryCode""");
                Match m = r.Match (country);
                country = m.Groups ["country"].Value.ToString ();
            }
            return country;
        }
        static public string BitmapToBase64(System.Drawing.Bitmap bitmap) // Преобразование изобаржения в строку base 64
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

