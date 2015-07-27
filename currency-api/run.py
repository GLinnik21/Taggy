#!env/bin/python
from app import app
import sys

port = 5000
debug = True
if len(sys.argv) == 3:
	debug = sys.argv[1] == 'debug'
	port = int(sys.argv[2])

app.run(host='0.0.0.0', debug = debug, port = port)
