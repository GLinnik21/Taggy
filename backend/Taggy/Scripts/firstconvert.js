 $.getJSON("/Get", function(data){
        	if (data){
        	 var to = "USD" // во что
        	 var from = "BYR"; // получать из еще одного списка
        	 var FROMrate;
        	 var TOrate;
        	 var toConvert = $("#price").html(); // заменить
        	 for(var i=0; i<data.length;i++)
        	 {
				if (data[i].From == from)
				{
					FROMrate = data[i].Rate; // рубль относительно доллара
					continue;
				}
			    if(data[i].From == to)
			    {
			    	TOrate = data[i].Rate; // евро относительно доллара
			    	continue;
			    }
        	 }

             var r = +TOrate / +FROMrate;
			 var prices = [];
			prices = toConvert.split(' ');
			for(var i=0; i<prices.length; i++)
			{
				prices[i] = prices[i] +" " + from + " ----- >>>>>" +  (prices[i] / +r).toFixed(3) + " " + to + " </br>";
			}
			$("#price").hide();
			$("#priceConverted").html(prices);
        	}
		});
	
