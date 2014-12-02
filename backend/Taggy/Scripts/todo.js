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

var curr;
var symbol;
var to = $('#currency option:selected').val();
var toSymbol;

$("#results-panel").hide();
$('#loading-button').on('click', function () {
    var btn = $(this).button('loading');
    var t = $('#file')[0].files[0];
    if (!t) {
        btn.button('reset');
        return;
    }
$('.progress2').show(),
        $('.percent2').show(),
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
                        getsymbol();
                        convert();
                        $('#currency').change(function () {
                            getsymbol();
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
                var from = curr; // получать из еще одного списка
                to = $('#currency option:selected').val();
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
                    prices[i] = prices[i] + " " + symbol + " ----- >>>>>" + (prices[i] / +r).toFixed(3) + " " + toSymbol + " </br>";
                }
                $("#price").hide();
                $('#priceConverted').hide();
                $("#priceConverted").html(prices);
                $('#priceConverted').show();
            }
    });
    if (!$('#price').html()) {
        $('#priceConverted').html('Не удалось распознать ценник');
        $('#priceConverted').show();
    }
}
function getsymbol() {
    var countryCode = $("#country-code").val();
    $.getJSON("/GetSymbols", function (data) {
        for (var i = 0; i < data.length; i++) {
            if (data[i].CountryCode == countryCode) {
                curr = data[i].Currency;
                symbol = data[i].Symbol;
            }
            to = $('#currency option:selected').val();
            if (data[i].Currency == to) {
                toSymbol = data[i].Symbol;
            }
        }
    });
}
    $(function(){
    var wrapper = $( ".file_upload" ),
        inp = wrapper.find( "input" ),
        btn = wrapper.find( "button" ),
        lbl = wrapper.find( "div" );

    // Crutches for the :focus style:
    btn.focus(function(){
        wrapper.addClass( "focus" );
    }).blur(function(){
        wrapper.removeClass( "focus" );
    });

    // Yep, it works!
    btn.add( lbl ).click(function(){
        inp.click();
    });

    var file_api = ( window.File && window.FileReader && window.FileList && window.Blob ) ? true : false;

    inp.change(function(){

        var file_name;
        if( file_api && inp[ 0 ].files[ 0 ] )
            file_name = inp[ 0 ].files[ 0 ].name;
        else
            file_name = inp.val().replace( "C:\\fakepath\\", '' );
        if( ! file_name.length )
            return;

        if( lbl.is( ":visible" ) ){
            lbl.text( file_name );
            btn.text( "Выбрать" );
        }else
            btn.text( file_name );
    }).change();

});
$( window ).resize(function(){
    $( ".file_upload input" ).triggerHandler( "change" );
});
