from flask import jsonify, abort, make_response, render_template
from app import app, auth, db, models

def latestRates():
	rates = models.Rate.query.group_by('name').all()
	return rates

def ratesHistory(count):
	rates = dict()
	query = db.session.query(models.Rate.date).distinct().order_by(models.Rate.date.desc())
	if count > 0:
		query = query.limit(count)

	dates = [date[0] for date in query.all()]

	for date in dates:
		dateRates = models.Rate.query.filter(models.Rate.date == date).all()
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
	rates = latestRates()
	return render_template('index.html', rates = rates)

@app.route('/rates', methods=['GET'])
def getTasks():
	rates = ratesToDict(latestRates());
	return jsonify(dbrates)

@app.route('/rates/<string:rateIds>', methods=['GET'])
#@auth.login_required
def getTask(rateIds):
	rates = ratesToDict(latestRates())
	resultRates = dict()
	for rateId in rateIds.split('+'):
		if not rateId in dbrates:
			abort(404)
		resultRates[rateId] = dbrates[rateId]
	return jsonify(resultRates)

@app.route('/history/<int:count>', methods=['GET'])
def getHistory(count):
	rates = ratesHistory(count);
	return jsonify(rates)