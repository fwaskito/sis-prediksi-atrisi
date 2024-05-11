from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired

class SigninForm(FlaskForm):
    username = StringField('Username', 
                        validators=[DataRequired()])
    password = PasswordField('Password', 
                        validators=[DataRequired()])
    submit = SubmitField('Signin')

class SignupForm(FlaskForm):
    name = StringField('Name', 
                        validators=[DataRequired()])
    username = StringField('Username', 
                        validators=[DataRequired()])
    password = PasswordField('Password', 
                        validators=[DataRequired()])
    submit = SubmitField('Submit')