from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_wtf import FlaskForm
from flask_wtf.file import FileField, FileAllowed
from flask_wtf.csrf import CSRFProtect
from wtforms import StringField, SelectField, IntegerField, SubmitField, DateField
from wtforms.validators import DataRequired
import pandas as pd
from io import StringIO
from datetime import datetime
import os

# Initialize Flask App
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/HouseWorkDB'
app.config['SECRET_KEY'] = os.urandom(24)  # Use a secure random secret key
csrf = CSRFProtect(app)
app.config['SESSION_TYPE'] = 'filesystem'
db = SQLAlchemy(app)


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ['csv']


def process_csv(csv_file):
    try:
        # Query the database once and create lookup dictionaries
        persons = {p.name: p.id for p in Person.query.all()}
        tasks = {t.name: t.id for t in Task.query.all()}

        # Process the CSV file here
        content = csv_file.read().decode('utf-8')
        data = StringIO(content)
        # Read CSV data using pandas
        df = pd.read_csv(data)
        # Process each row and insert into the database
        # Since it's very low volume of data, we can process each row individually
        for index, row in df.iterrows():
            # Look up person_id and task_id using dictionaries
            person_id = persons.get(row['Person'])
            task_id = tasks.get(row['Task'])

            if not person_id:
                flash(f"Person '{row['Person']}' not found in database.", 'danger')
                continue

            if not task_id:
                flash(f"Task '{row['Task']}' not found in database.", 'danger')
                continue

            task_record = TaskRecord(
                # Ensure the CSV has all the required columns
                date=row['Date'],
                person_id=person_id,
                task_id=task_id,
                task_duration_minutes=row['Task Duration Minutes']
            )
            db.session.add(task_record)

        db.session.commit()

    except Exception as e:
        db.session.rollback()
        flash(f'Error processing CSV: {str(e)}', 'danger')


# Models
class Person(db.Model):
    __tablename__ = 'dim_person'
    __table_args__ = {'schema': 'public'}

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)


class Task(db.Model):
    __tablename__ = 'dim_task'
    __table_args__ = {'schema': 'public'}

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)


class TaskRecord(db.Model):
    __tablename__ = 'fact_housework_tasks'
    __table_args__ = {'schema': 'public'}

    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, nullable=False)
    person_id = db.Column(db.Integer, db.ForeignKey('public.dim_person.id'), nullable=False)
    task_id = db.Column(db.Integer, db.ForeignKey('public.dim_task.id'), nullable=False)
    task_duration_minutes = db.Column('task_duration_minutes', db.Integer, nullable=False)


# Form
class TaskRecordForm(FlaskForm):
    date = DateField('Date', format='%Y-%m-%d', validators=[DataRequired()], default=datetime.today)
    person = SelectField('Person', coerce=int, validators=[DataRequired()])
    task = SelectField('Task', coerce=int, validators=[DataRequired()])
    task_duration_minutes = IntegerField('Minutes', validators=[DataRequired()], default=0)
    file = FileField('Upload CSV', validators=[FileAllowed(['csv'], 'CSV Files Only')])
    submit = SubmitField('Submit')


# Routes
@app.route('/', methods=['GET', 'POST'])
def add_task_record():
    form = TaskRecordForm()
    # Populate dropdowns for person and task
    form.person.choices = [(p.id, p.name) for p in Person.query.all()]
    form.task.choices = [(t.id, t.name) for t in Task.query.all()]

    if request.method == 'POST':
        # Check which button was clicked
        action = request.form.get('action')

        if action == 'submit_record' and form.validate_on_submit():
            # Handle form submission for task record
            record = TaskRecord(
                date=form.date.data,
                person_id=form.person.data,
                task_id=form.task.data,
                task_duration_minutes=form.task_duration_minutes.data,
            )
            db.session.add(record)
            db.session.commit()
            flash('Task record added successfully!', 'success')
            return redirect(url_for('add_task_record'))

        elif action == 'upload_csv' and form.file.data:
            # Handle CSV file upload
            csv_file = form.file.data
            if not allowed_file(csv_file.filename):
                flash('Please upload a valid CSV file.', 'danger')
                return redirect(url_for('add_task_record'))

            # Process the CSV file
            process_csv(csv_file)
            flash('CSV file processed successfully!', 'success')
            return redirect(url_for('add_task_record'))

        else:
            flash('Invalid action or form submission.', 'danger')
            if form.task_duration_minutes.data <= 0:
                flash('Minutes field should be greater than 0.', 'danger')

    return render_template('task_record_form.html', form=form)


if __name__ == '__main__':
    app.run(debug=True)
