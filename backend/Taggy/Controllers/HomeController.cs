using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using System.IO;
using System.Drawing;

namespace Taggy
{
    public class HomeController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
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

        private JsonResult ConvertBitmap(Bitmap bitmap)
        {
            bool isOk = true;
            string message = "";
            string recognition = "";

            try
            {

                recognition = PriceRecognizer.PriceRecognizer.ParseImage(bitmap);
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

