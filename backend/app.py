from flask import Flask
from src.router import blueprint

from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.register_blueprint(blueprint)

if __name__ == '__main__':
    app.run(debug=True)
