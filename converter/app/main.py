from flask import Flask
import subprocess

app = Flask(__name__)

@app.route("/")
def entrypoint():
    # TODO: call the entry point for the application
    # subprocess.call(["bash", "./cmd.sh"])
    return "{\"message\":\"OK\"}"

if __name__ == "__main__":
    app.run(debug=True)