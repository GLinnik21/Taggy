from flask import jsonify, abort, make_response, render_template
from app import app, auth, db, models

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

@app.route('/')
@app.route('/index')
def index():
	rates = models.Rate.query.all()
	return render_template('index.html', rates = rates)

@app.route('/rates', methods=['GET'])
def getTasks():
	rates = models.Rate.query.all()
	return jsonify(rates)

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
