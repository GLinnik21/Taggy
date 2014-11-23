$('#getting-location').html('Получение текущей позиции...');
	  	$.getJSON( "http://ip-api.com/json", function( data ) {
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
					success: function(data) {
						btn.button('reset');
						$('.progress2').hide();
						$('.percent2').hide();
						var obj = jQuery.parseJSON(this.response);
						$('#price').html(obj.price);
						$('#message').html(obj.message);
						if (obj.ok) {
							//$('#price').show();
							$('#message').hide();
						} else {
							$('#price').hide();
							$('#message').show();
						}
					}
				});
			}
		});
	});