using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MVCTraining.Models;
using System.IO;
using Puma.Net;

namespace MVCTraining.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            

            return View();
        }

        [HttpPost]
        public ActionResult Convert(HttpPostedFileBase file)
        {
            IEnumerable<string> files = new string[0];
            ViewBag.Files = files;

            if (file == null)
            {
                return View();
            }
            var bitmap = new System.Drawing.Bitmap(file.InputStream);
            ViewBag.Image = BitmapToBase64(bitmap);
            var pumaPage = new PumaPage(bitmap);//new PumaPage(@"D:\картинки\ценники\9e5208a1d53c9f7d9d18aa3e47773e6d.jpg");
            string recognizedText = null;

            using (pumaPage)
            {
                pumaPage.FileFormat = PumaFileFormat.RtfAnsi;
                pumaPage.EnableSpeller = true;// Изначально False
                pumaPage.Language = PumaLanguage.Russian; // puma.checklanguage попробовать

                try
                {
                    recognizedText = pumaPage.RecognizeToString();
                    ViewBag.Out = pumaPage.RecognizeToString();
                    ViewBag.NotRecognized = pumaPage.UnrecognizedChar;
                }
                catch (Exception ex)
                {
                    ViewBag.Out = ex.Message.ToString();
                }

            }

            //return View();
            var rslt = new JsonResult();
            rslt.Data = new { 
                ok = true, 
                price = new []{ 
                    MVCTraining.PriceRecognizer.RecognizePrice(recognizedText)
                } 
            };
            rslt.JsonRequestBehavior = JsonRequestBehavior.AllowGet;
            return rslt;
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

        public ActionResult About()
        {
            return View();
        }
    }
}
