import os
from itertools import groupby
from collections import defaultdict
import time
from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/')
def home():
    file_names = sorted(os.listdir('static/images'))
    result = defaultdict(list)
    for file in file_names:
        number = file.partition('-')[0]
        if number.isnumeric():
            result[number].append(file)

    images = [images for images in result.values() if len(images) == 2]
    return render_template('index.html', images=result.values())

@app.route("/upload", methods=["POST"])
def upload():
    main, preview = request.files.getlist("images")
    prefix = str(int(time.time())) + '-'
    main.save(os.path.join("static/images", prefix + 'main' + os.path.splitext(main.filename)[1]))
    preview.save(os.path.join("static/images", prefix + 'preview' + os.path.splitext(preview.filename)[1]))
    return ""

if __name__ == '__main__':
   app.run()