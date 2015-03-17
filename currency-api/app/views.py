from flask import jsonify, abort, make_response, render_template
from app import app, auth, db, models

def latestRates():
    ratesCount = db.session.query(models.Rate.name).distinct().count()
    rates = models.Rate.query.order_by(models.Rate.id.desc())[0:ratesCount]
    return rates

def ratesHistory(start, count):
    ratesCount = db.session.query(models.Rate.name).distinct().count()
    dateRates = models.Rate.query.order_by(models.Rate.id.desc())[start * ratesCount:(start + count)*ratesCount]

    rates = dict()
    for rate in dateRates:
        if rate.name in rates:
            rates[rate.name][str(rate.date)] = rate.value
        else:
            rates[rate.name] = {str(rate.date): rate.value}

    return rates

def ratesToDict(rates):
    result = dict()
    for rate in rates:
        result[rate.name] = rate.value
    return result

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

@app.route('/')
def index():
    rates = sorted(latestRates(), key=lambda rate: rate.name)
    return render_template('index.html', rates = rates)

@app.route('/rates', methods=['GET'])
def getRates():
    rates = ratesToDict(latestRates());
    return jsonify(rates)

@app.route('/rates/<string:rateIds>', methods=['GET'])
#@auth.login_required
def getRate(rateIds):
    rates = ratesToDict(latestRates())
    resultRates = dict()
    for rateId in rateIds.split('+'):
        if not rateId in rates:
            abort(404)
        resultRates[rateId] = rates[rateId]
    return jsonify(resultRates)

@app.route('/history/<int:start>/<int:count>', methods=['GET'])
def getHistory(start, count):
    rates = ratesHistory(start, count);
    return jsonify(rates)
