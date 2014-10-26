using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Taggy
{
    public static class BootstrapExtensions
    {
        public static BootstrapPanel DefaultPanel(this HtmlHelper helper, string heading, string backUrl = null)
        {
            return new BootstrapPanel(helper.ViewContext, heading, backUrl);
        }

        public static BootstrapModal DefaultModal(this HtmlHelper helper, string modalId, string heading)
        {
            return new BootstrapModal(helper.ViewContext, modalId, heading);
        }

        public static MvcHtmlString StandartInput(this HtmlHelper helper, string inputType, string name, string title, string value = null, string placeHolder = null, bool withId = false, int colSm = 3)
        {
            var group = new TagBuilder("div");
            var label = new TagBuilder("label");
            var inputGroup = new TagBuilder("div");
            var input = new TagBuilder("input");

            input.AddCssClass("form-control");
            input.MergeAttribute("type", inputType);
            input.MergeAttribute("name", name);
            input.MergeAttribute("value", value);
            if(placeHolder != null)
                input.MergeAttribute("placeholder", placeHolder);
            if(withId)
                input.MergeAttribute("id", name);

            inputGroup.AddCssClass("col-sm-" + (12 - colSm));
            inputGroup.InnerHtml = input.ToString();

            label.AddCssClass("col-sm-" + colSm);
            label.AddCssClass("control-label");
            label.MergeAttribute("for", name);
            label.InnerHtml = title;

            group.AddCssClass("form-group");
            group.InnerHtml = label + "\n" + inputGroup;

            return new MvcHtmlString(group.ToString());
        }

        public static MvcHtmlString StandartInputSelect(this HtmlHelper helper, string name, string title,
            IEnumerable<KeyValuePair<string, string>> values, string value = null, bool withId = false, int colSm = 3)
        {
            var group = new TagBuilder("div");
            var label = new TagBuilder("label");
            var inputGroup = new TagBuilder("div");
            var input = new TagBuilder("select");

            input.AddCssClass("form-control");
            input.MergeAttribute("name", name);
            if (withId)
                input.MergeAttribute("id", name);

            foreach (var pair in values)
            {
                var option = new TagBuilder("option");
                option.MergeAttribute("value", pair.Key);
                option.InnerHtml = pair.Value;
                if (pair.Key == value)
                {
                    option.MergeAttribute("selected", "");
                }
                input.InnerHtml += option.ToString();
            }

            inputGroup.AddCssClass("col-sm-" + (12 - colSm));
            inputGroup.InnerHtml = input.ToString();

            label.AddCssClass("col-sm-" + colSm);
            label.AddCssClass("control-label");
            label.MergeAttribute("for", name);
            label.InnerHtml = title;

            group.AddCssClass("form-group");
            group.InnerHtml = label + "\n" + inputGroup;

            return new MvcHtmlString(group.ToString());
        }

        public static MvcHtmlString StandartInputSubmit(this HtmlHelper helper, string title, int colSm = 3)
        {
            var group = new TagBuilder("div");
            var inputGroup = new TagBuilder("div");
            var button = new TagBuilder("button");

            button.AddCssClass("btn");
            button.AddCssClass("btn-default");
            button.MergeAttribute("type", "submit");
            button.InnerHtml = title;

            inputGroup.AddCssClass("col-sm-offset-" + colSm);
            inputGroup.AddCssClass("col-sm-" + (12 - colSm));
            inputGroup.InnerHtml = button.ToString();

            group.AddCssClass("form-group");
            group.InnerHtml = inputGroup.ToString();

            return new MvcHtmlString(group.ToString());
        }

        public static MvcHtmlString Icon(this HtmlHelper helper, GlyphIconType icon)
        {
            var iconTag = new TagBuilder("i");
            iconTag.AddCssClass("glyphicon");
            iconTag.AddCssClass("glyphicon-" + icon.ToString().Replace("_", "-"));
            return new MvcHtmlString(iconTag.ToString());
        }

        public static MvcHtmlString UserSearchText(this HtmlHelper helper, string id = "findPeople", string placeholder = null, IEnumerable<KeyValuePair<string, string>> customAttributes = null, IEnumerable<string> customClasses = null)
        {
            var userIdTag = new TagBuilder("input");
            userIdTag.Attributes.Add("type", "hidden");
            userIdTag.Attributes.Add("id", id+"Id");
            var userTextTag = new TagBuilder("input");
            userTextTag.Attributes.Add("id", id);
            userTextTag.Attributes.Add("type", "text");
            if (customAttributes != null)
                foreach (var attribute in customAttributes)
                    userTextTag.Attributes.Add(attribute);
            if (customClasses != null)
                foreach (var customClass in customClasses)
                    userTextTag.AddCssClass(customClass);

            if (!string.IsNullOrEmpty(placeholder))
            {
                userTextTag.Attributes.Add("placeholder", placeholder);
            }
            var scriptTag = new TagBuilder("script")
            {
                InnerHtml = "$(function () {" +
                    "$('#" + id + "').autocomplete({" +
                    "serviceUrl: '/Api/UserApi/SearchUser'," +
                    "minChars: 3," +
                    //"maxHeight: 400," +
                    //"width: 300," +
                    "deferRequestBy: 300," +
                    "transformResult: function (response) {" +
                    "response = $.parseJSON(response);" +
                    "return {" +
                    "suggestions: $.map(response.users, function (user) {" +
                    "return { value: user.name, data: user.id };" +
                    "})" +
                    "};" +
                    "}," +
                    "onSelect: function (suggestion) {" +
                    "$('#findPeopleId').val(suggestion.data);" +
                    "}" +
                    "});" +
                    "});"
            };
            return new MvcHtmlString(userIdTag + "\n" + userTextTag + "\n" + scriptTag);
        }

        public static MvcHtmlString GroupsSearchText(this HtmlHelper helper, string id = "findGroup", string placeholder = null, IEnumerable<KeyValuePair<string, string>> customAttributes = null, IEnumerable<string> customClasses = null)
        {
            var userIdTag = new TagBuilder("input");
            userIdTag.Attributes.Add("type", "hidden");
            userIdTag.Attributes.Add("id", id + "Id");
            var userTextTag = new TagBuilder("input");
            userTextTag.Attributes.Add("id", id);
            userTextTag.Attributes.Add("type", "text");
            if (customAttributes != null)
                foreach (var attribute in customAttributes)
                    userTextTag.Attributes.Add(attribute);
            if (customClasses != null)
                foreach (var customClass in customClasses)
                    userTextTag.AddCssClass(customClass);

            if (!string.IsNullOrEmpty(placeholder))
            {
                userTextTag.Attributes.Add("placeholder", placeholder);
            }
            var scriptTag = new TagBuilder("script")
            {
                InnerHtml = "$(function () {" +
                    "$('#" + id + "').autocomplete({" +
                    "serviceUrl: '/Api/UserApi/SearchGroup'," +
                    "minChars: 3," +
                    //"maxHeight: 400," +
                    //"width: 300," +
                    "deferRequestBy: 300," +
                    "transformResult: function (response) {" +
                    "response = $.parseJSON(response);" +
                    "return {" +
                    "suggestions: $.map(response.groups, function (group) {" +
                    "return { value: group.name, data: group.id };" +
                    "})" +
                    "};" +
                    "}," +
                    "onSelect: function (suggestion) {" +
                    "$('#" + id + "Id').val(suggestion.data);" +
                    "}" +
                    "});" +
                    "});"
            };
            return new MvcHtmlString(userIdTag + "\n" + userTextTag + "\n" + scriptTag);
        }

        public static MvcHtmlString MenuLink(this HtmlHelper htmlHelper, string itemText,
            string controllerName, GlyphIconType? iconClass = null,
            MvcHtmlString[] childElements = null)
        {
            return MenuLink(htmlHelper, itemText, "Index", controllerName, iconClass, true, childElements);
        }

        public static MvcHtmlString MenuLink(this HtmlHelper htmlHelper, string itemText, string actionName, string controllerName, GlyphIconType? icon = null, bool onlyController = false, MvcHtmlString[] childElements = null)
        {
            var currentAction = htmlHelper.ViewContext.RouteData.GetRequiredString("action");
            var currentController = htmlHelper.ViewContext.RouteData.GetRequiredString("controller");
            string finalHtml;
            var linkBuilder = new TagBuilder("a");
            var liBuilder = new TagBuilder("li");

            if (icon.HasValue)
            {
                var iconBuilder = new TagBuilder("i");
                iconBuilder.AddCssClass("glyphicon");
                iconBuilder.AddCssClass("glyphicon-" + icon.Value);
                itemText = iconBuilder.ToString() + " " + itemText;
            }

            if (childElements != null && childElements.Length > 0)
            {
                linkBuilder.MergeAttribute("href", "#");
                linkBuilder.AddCssClass("dropdown-toggle");
                linkBuilder.InnerHtml = itemText + " <b class=\"caret\"></b>";
                linkBuilder.MergeAttribute("data-toggle", "dropdown");
                var ulBuilder = new TagBuilder("ul");
                ulBuilder.AddCssClass("dropdown-menu");
                ulBuilder.MergeAttribute("role", "menu");
                foreach (var item in childElements)
                {
                    ulBuilder.InnerHtml += item.ToString() + "\n";
                }

                liBuilder.InnerHtml = linkBuilder.ToString() + "\n" + ulBuilder.ToString();
                liBuilder.AddCssClass("dropdown");
                if (String.Equals(controllerName, currentController, StringComparison.InvariantCultureIgnoreCase) &&
                    (onlyController || String.Equals(actionName, currentAction, StringComparison.InvariantCultureIgnoreCase)))
                {
                    liBuilder.AddCssClass("active");
                }

                finalHtml = liBuilder.ToString() + ulBuilder.ToString();
            }
            else
            {
                UrlHelper urlHelper = new UrlHelper(htmlHelper.ViewContext.RequestContext, htmlHelper.RouteCollection);
                linkBuilder.MergeAttribute("href", urlHelper.Action(actionName, controllerName));
                linkBuilder.InnerHtml = itemText;
                liBuilder.InnerHtml = linkBuilder.ToString();
                if (String.Equals(controllerName, currentController, StringComparison.InvariantCultureIgnoreCase) && 
                    (onlyController || String.Equals(actionName, currentAction, StringComparison.InvariantCultureIgnoreCase)))
                {
                    liBuilder.AddCssClass("active");
                }

                finalHtml = liBuilder.ToString();
            }

            return new MvcHtmlString(finalHtml);
        }
        public static MvcHtmlString SideMenuLink(this HtmlHelper htmlHelper, string itemText, string actionName, object values = null, string controllerName = null, GlyphIconType? icon = null, bool? forceActive = null)
        {
            var currentAction = HttpContext.Current.Request.RequestContext.RouteData.GetRequiredString("action"); // Returns MAIN action.
            var currentController = HttpContext.Current.Request.RequestContext.RouteData.GetRequiredString("controller");
            var linkBuilder = new TagBuilder("a");

            if (icon.HasValue)
            {
                var iconBuilder = new TagBuilder("i");
                iconBuilder.AddCssClass("glyphicon");
                iconBuilder.AddCssClass("glyphicon-" + icon.Value.ToString().Replace("_", "-"));
                itemText = iconBuilder.ToString() + " " + itemText;
            }

            UrlHelper urlHelper = new UrlHelper(htmlHelper.ViewContext.RequestContext, htmlHelper.RouteCollection);
            linkBuilder.AddCssClass("list-group-item");
            linkBuilder.MergeAttribute("href",
                values == null
                ? urlHelper.Action(actionName, controllerName ?? currentController)
                : urlHelper.Action(actionName, controllerName ?? currentController, values));
            linkBuilder.InnerHtml = itemText;
            if (!forceActive.HasValue &&
                (controllerName == null || String.Equals(controllerName, currentController, StringComparison.InvariantCultureIgnoreCase)) &&
                String.Equals(actionName, currentAction, StringComparison.InvariantCultureIgnoreCase) || 
                forceActive.HasValue && forceActive.Value)
            {
                linkBuilder.AddCssClass("active");
            }

            return new MvcHtmlString(linkBuilder.ToString());
        }
    }

    public class BootstrapPanel : IDisposable
    {
        private bool _disposed;
        private bool _bodyEnded;
        private TextWriter _writer;

        public BootstrapPanel(ViewContext viewContext, string heading, string backUrl)
        {
            if (viewContext == null)
                throw new ArgumentNullException("viewContext");
            _writer = viewContext.Writer;
            _disposed = false;
            _bodyEnded = false;

            _writer.WriteLine("<div class=\"panel panel-default\">");
            _writer.WriteLine("<div class=\"panel-heading\"><strong>" +
                (backUrl != null
                    ? backUrl != "" ?
                    "<a href='" + backUrl +
                    "'><span class='glyphicon glyphicon-chevron-left'></span></a> "
                    : "<a href='javascript:history.back()'><span class='glyphicon glyphicon-chevron-left'></span></a>"
                    : "") + heading + "</strong></div>");
            _writer.WriteLine("<div class=\"panel-body\">");
        }

        public void Dispose()
        {
            if (_disposed) return;
            _disposed = true;

            _writer.WriteLine(EndBody());
            _writer.WriteLine("</div>");
        }

        public MvcHtmlString EndBody()
        {
            if (_bodyEnded) return null;
            _bodyEnded = true;

            return new MvcHtmlString("</div>");
        }
    }

    public class BootstrapModal : IDisposable
    {
        private bool _disposed;
        private bool _bodyEnded;
        private TextWriter _writer;

        public BootstrapModal(ViewContext viewContext, string modalId, string title)
        {
            if (viewContext == null)
                throw new ArgumentNullException("viewContext");
            _writer = viewContext.Writer;
            _disposed = false;
            _bodyEnded = false;

            _writer.WriteLine("<div class=\"modal fade\" id=\"" + modalId +
                "\" tabindex=\"-1\" role=\"dialog\" aria-labelledby=\"" + modalId +
                "Label\" aria-hidden=\"true\">\n" +
                "<div class=\"modal-dialog\">\n" +
                "<div class=\"modal-content\">\n" +
                "<div class=\"modal-header\">\n" +
                "<button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-hidden=\"true\">×</button>\n" +
                "<h3 id=\"" + modalId + "Label\">" + title + "</h3>\n" +
                "</div>\n" +
                "<div class=\"modal-body\" id=\"" + modalId + "Body\">");
        }

        public void Dispose()
        {
            if (_disposed) return;
            _disposed = true;

            _writer.WriteLine(EndBody());
            _writer.WriteLine("</div>\n" +
                "</div>\n" +
                "</div>\n" +
                "</div>");
        }

        public MvcHtmlString EndBody()
        {
            if (_bodyEnded) return null;
            _bodyEnded = true;

            return new MvcHtmlString("</div>\n" +
                "<div class=\"modal-footer\">");
        }
    }

    public enum GlyphIconType
    {
        adjust,
        align_center,
        align_justify,
        align_left,
        align_right,
        arrow_down,
        arrow_left,
        arrow_right,
        arrow_up,
        asterisk,
        backward,
        ban_circle,
        barcode,
        bell,
        bold,
        book,
        bookmark,
        briefcase,
        bullhorn,
        calendar,
        camera,
        certificate,
        check,
        chevron_down,
        chevron_left,
        chevron_right,
        chevron_up,
        circle_arrow_down,
        circle_arrow_left,
        circle_arrow_right,
        circle_arrow_up,
        cloud,
        cloud_download,
        cloud_upload,
        cog,
        collapse_down,
        collapse_up,
        comment,
        compressed,
        copyright_mark,
        credit_card,
        cutlery,
        dashboard,
        download,
        download_alt,
        earphone,
        edit,
        eject,
        envelope,
        euro,
        exclamation_sign,
        expand,
        export,
        eye_close,
        eye_open,
        facetime_video,
        fast_backward,
        fast_forward,
        file,
        film,
        filter,
        fire,
        flag,
        flash,
        floppy_disk,
        floppy_open,
        floppy_remove,
        floppy_save,
        floppy_saved,
        folder_close,
        folder_open,
        font,
        forward,
        fullscreen,
        gbp,
        gift,
        glass,
        globe,
        hand_down,
        hand_left,
        hand_right,
        hand_up,
        hd_video,
        hdd,
        header,
        headphones,
        heart,
        heart_empty,
        home,
        import,
        inbox,
        indent_left,
        indent_right,
        info_sign,
        italic,
        leaf,
        link,
        list,
        list_alt,
        log_in,
        log_out,
        magnet,
        map_marker,
        minus,
        minus_sign,
        move,
        music,
        new_window,
        off,
        ok,
        ok_circle,
        ok_sign,
        open,
        paperclip,
        pause,
        pencil,
        phone,
        phone_alt,
        picture,
        plane,
        play,
        play_circle,
        plus,
        plus_sign,
        print,
        pushpin,
        qrcode,
        question_sign,
        random,
        record,
        refresh,
        registration_mark,
        remove,
        remove_circle,
        remove_sign,
        repeat,
        resize_full,
        resize_horizontal,
        resize_small,
        resize_vertical,
        retweet,
        road,
        save,
        saved,
        screenshot,
        sd_video,
        search,
        send,
        share,
        share_alt,
        shopping_cart,
        signal,
        sort,
        sort_by_alphabet,
        sort_by_alphabet_alt,
        sort_by_attributes,
        sort_by_attributes_alt,
        sort_by_order,
        sort_by_order_alt,
        sound_5_1,
        sound_6_1,
        sound_7_1,
        sound_dolby,
        sound_stereo,
        star,
        star_empty,
        stats,
        step_backward,
        step_forward,
        stop,
        subtitles,
        tag,
        tags,
        tasks,
        text_height,
        text_width,
        th,
        th_large,
        th_list,
        thumbs_down,
        thumbs_up,
        time,
        tint,
        tower,
        transfer,
        trash,
        tree_conifer,
        tree_deciduous,
        upload,
        usd,
        user,
        volume_down,
        volume_off,
        volume_up,
        warning_sign,
        wrench,
        zoom_in,
        zoom_out
    }

}
