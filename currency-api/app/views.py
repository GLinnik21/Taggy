from flask import jsonify, abort, make_response, render_template
from app import app, auth, db, models

def dbRates():
	rates = models.Rate.query.all()
	result = dict()
	for rate in rates:
		result[rate.name] = rate.value
	return result

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

@app.route('/')
def index():
	rates = models.Rate.query.order_by('name').all()
	return render_template('index.html', rates = rates)

@app.route('/rates', methods=['GET'])
def getTasks():
	dbrates = dbRates();
	return jsonify(dbrates)

@app.route('/rates/<string:rateIds>', methods=['GET'])
#@auth.login_required
def getTask(rateIds):
	rates = models.Rate.query.all()
	resultRates = dict()
	for rateId in rateIds.split('+'):
		if not rateId in rates:
			abort(404)
		resultRates[rateId] = rates[rateId]
	return jsonify(resultRates)
