from flask import Flask, render_template, request, redirect, url_for
import requests, json

app = Flask(__name__)

@app.route('/')
def get_courses():
    req = requests.get('http://127.0.0.1:5000/courses')
    data = json.loads(req.content)
    return render_template('index.html', data=data)

# Route to handle adding courses
@app.route('/add_course', methods=['POST'])
def add_course():
    # Extract course data from the form submitted by the user
    course_name = request.form['course_name']
    
    # Make a request to the API to add the course
    response = requests.post('http://127.0.0.1:5000/course', json={'course': course_name})
    
    # Check the status of the response
    if response.status_code == 200:
        return redirect(url_for('get_courses'))
    else:
        return redirect(url_for('get_courses'))
    
# Route to handle deleting courses
@app.route('/delete_course/<int:course_id>', methods=['POST'])
def delete_course(course_id):
    response = requests.delete(f'http://127.0.0.1:5000/course/{course_id}')
    
    if response.status_code == 200:
        return redirect(url_for('get_courses'))
    else:
        return redirect(url_for('get_courses'))
    
# Route to handle editing courses
@app.route('/edit_course/<int:course_id>', methods=['GET', 'POST'])
def edit_course(course_id):
    if request.method == 'POST':
        new_course_name = request.form['new_course_name']
        response = requests.put(f'http://127.0.0.1:5000/course/{course_id}', json={'course': new_course_name})
        
        if response.status_code == 200:
            return redirect(url_for('get_courses'))
        else:
            return redirect(url_for('get_courses'))

    # If request method is GET, render the edit form
    req = requests.get(f'http://127.0.0.1:5000/course/{course_id}')
    data = json.loads(req.content)
    print(data)
    return render_template('edit.html', data=data)

if __name__ == '__main__':
    app.run(debug=True, port=8000)
