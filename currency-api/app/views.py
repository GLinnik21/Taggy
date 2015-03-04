from flask import jsonify, abort, make_response, render_template
from app import app, auth

rates = {
	'USD': 1.0,
	'BYR': 15016.416667
}

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

@app.route('/')
@app.route('/index')
def index():
	return render_template('index.html', rates = rates)

@app.route('/rates', methods=['GET'])
def getTasks():
	return jsonify(rates)

@app.route('/rates/<string:rateIds>', methods=['GET'])
#@auth.login_required
def getTask(rateIds):
	resultRates = dict()
	for rateId in rateIds.split('+'):
		if not rateId in rates:
			abort(404)
		resultRates[rateId] = rates[rateId]
	return jsonify(resultRates)
