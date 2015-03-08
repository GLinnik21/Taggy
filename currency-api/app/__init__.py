from flask import Flask
from flask.ext.httpauth import HTTPBasicAuth
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config.from_object('config')

auth = HTTPBasicAuth()

db = SQLAlchemy(app)

from app import views, authinfo, models
