from flask import Flask
import pyodbc

app = Flask(__name__)

@app.route('/')
def index():
    return "hello world"

@app.route('/test')
def test():
    try:
        connector_sql = pyodbc.connect("testing.tld")
    except Exception as err:
        print(err)
