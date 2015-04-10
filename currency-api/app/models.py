from app import db

class Rate(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    name = db.Column(db.String(3), index = True)
    date = db.Column(db.DateTime)
    value = db.Column(db.Float)

    def __repr__(self):
        return '<Rate %r>' % (self.name)
