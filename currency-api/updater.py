#!env/bin/python
from app import db, models
import urllib2
import simplejson
import datetime

APP_ID = "40639356d56148f1ae26348d670e889f"

print 'Updating rates...'
request = urllib2.Request("http://openexchangerates.org/api/latest.json?app_id=%s" % (APP_ID))
opener = urllib2.build_opener()
f = opener.open(request)
result = simplejson.load(f)
rates = result['rates']

for rate in rates:
    date = datetime.datetime.now()
    #round to minute
    date += datetime.timedelta(seconds=30)
    date -= datetime.timedelta(seconds=date.second, microseconds=date.microsecond)

    dbrate = models.Rate(name=rate, date=date, value=rates[rate])
    db.session.add(dbrate)
    print rate,

db.session.commit()
