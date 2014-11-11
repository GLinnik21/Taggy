using System.Web.Optimization;

namespace Taggy.AppStart
{
    public static class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            RegisterStyleBundles(bundles);
            RegisterJavascriptBundles(bundles);
        }

        private static void RegisterStyleBundles(BundleCollection bundles)
        {
            bundles.Add(new StyleBundle("~/css")
                            .Include("~/Content/css/bootstrap.css")
                            .Include("~/Content/css/bootstrap-theme.css")
                            .Include("~/Content/css/jumbotron-narrow.css"));
        }

        private static void RegisterJavascriptBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/js")
                            .Include("~/Scripts/jquery-2.1.1.js")
                            .Include("~/Scripts/binaryajax.js")
                            .Include("~/Scripts/exif.js")
                            .Include("~/Scripts/project1551.imageResizer.js")
                            .Include("~/Scripts/bootstrap.js"));
        }
    }
}