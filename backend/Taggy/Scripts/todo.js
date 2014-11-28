$('#getting-location').html('Получение текущей позиции...');
$.getJSON("http://ip-api.com/json", function (data) {
    if (data) {
        $('#latitude').val(data.lat);
        $('#longitude').val(data.lon);
        $('#country-code').val(data.countryCode);
        $('#country-name').val(data.country);
        $('#self-ip').val(data.query);
        $('#getting-location').html('Ваша страна: ' + $('#country-name').val() + '(' + $('#country-code').val() + ')');
    } else {
        $('#getting-location').html('Не удалось получить позицию.');
    }
});

$("#results-panel").hide();
$('#loading-button').on('click', function () {
    var btn = $(this).button('loading');
    var t = $('#file')[0].files[0];
    if (!t) {
        btn.button('reset');
        return;
    }
    prj1551.imageResizer.resize({
        file: t,
        maxWidth: 670,
        maxHeight: 670,
        complete: function (result) {
            $("#image").attr("src", "data:image/jpeg;base64" + result.data);
            $("#results-panel").show();
            prj1551.imageResizer.upload({
                url: 'Convert',
                data: result.data,
                mimeType: t.type,
                fileName: t.name,
                formDataName: 'file',
                progressIndicator: '.progress2',
                percentIndicator: '.percent2',
                success: function (data) {
                    btn.button('reset');
                    $('.progress2').hide();
                    $('.percent2').hide();
                    var obj = jQuery.parseJSON(this.response);
                    $('#price').html(obj.price);
                    $('#message').html(obj.message);
                    if (obj.ok) {
                        //$('#price').show();
                        $('#message').hide();
                        convert();
                        $('#currency').change(function () {
                            convert();
                        });

                    } else {
                        $('#price').hide();
                        $('#message').show();
                    }
                }
            });
        }
    });
});

function convert() {
    $.getJSON("/GetRates", function (data) {
    if ($('#price').html().length > 1)
        if (data) {
            //var to = $('#currency option:selected').val(); // во что
            var to = $('#currency option:selected').val(); // во что
            var from = "BYR"; // получать из еще одного списка
            var FROMrate;
            var TOrate;
            var toConvert = $("#price").html(); // заменить
            for (var i = 0; i < data.length; i++) {
                if (data[i].From == from) {
                    FROMrate = data[i].Rate; // рубль относительно доллара
                    continue;
                }
                if (data[i].From == to) {
                    TOrate = data[i].Rate; // евро относительно доллара
                    continue;
                }
            }

            var r = +TOrate / +FROMrate;
            var prices = [];
            prices = toConvert.split(' ');
            for (var i = 0; i < prices.length; i++) {
                prices[i] = prices[i] + " " + from + " ----- >>>>>" + (prices[i] / +r).toFixed(3) + " " + to + " </br>";
            }
            $("#price").hide();
            $('#priceConverted').hide();
            $("#priceConverted").html(prices);
            $('#priceConverted').show();
        }
    });
	if (!$('#price').html())
		{
			$('#priceConverted').html('Не удалось распознать ценник');
			$('#priceConverted').show();
		}
}