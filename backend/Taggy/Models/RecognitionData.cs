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
    public class RecognitionData
    {
        public bool ok { get; set; }
        public string message { get; set; }
        public string[] price { get; set; }
        public string country { get; set; }
    }
    
}
