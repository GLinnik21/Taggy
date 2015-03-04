import os
basedir = os.path.abspath(os.path.dirname(__file__))

SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'app.db')
SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db-repository')

CSRF_ENABLED = True
SECRET_KEY = 'taggy-very-secret-key-4c455186-5b47-4660-be49-ad6e124f045d'
