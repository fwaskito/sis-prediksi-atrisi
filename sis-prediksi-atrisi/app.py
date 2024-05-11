from flask import Flask, render_template, redirect, request  
from flask import session, url_for, flash, json, jsonify
from flask_mysqldb import MySQL
import MySQLdb
from forms import SigninForm

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'waskito'
app.config['MYSQL_PASSWORD'] = 'admwaskito'
app.config['MYSQL_DB'] = 'sppk'
mysql = MySQL(app)

app.secret_key = 'sis. prediksi atrisi secret key'

@app.route('/')
def main():
    return render_template('index.html')

@app.route('/logout')
def logout():
    session.pop('user', None)
    session.pop('predictions', None)
    return redirect(url_for('main'))

@app.route('/beranda')
def tampilBeranda():
    if session.get('user'):
        query = 'get_employees'
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.callproc(query)
        employees = cursor.fetchall()
        return render_template('beranda.html', employees=employees)
    else:
        return render_template('error.html', error='Unauthorized Access')

@app.route('/login', methods=['GET', 'POST'])
def logIn():
    form = SigninForm()
    if form.validate_on_submit():
        try:
            _username = form.username.data
            _password = form.password.data

            query = "select * from user where username='"+_username + "';"
            cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
            cursor.execute(query)
            data = cursor.fetchall()
            #print('data: ', data, '\n')
            #print(data[0]['password'])
            if len(data) > 0:

                if str(data[0]['password']) == str(_password):
                    session['user'] = data[0]
                    return redirect(url_for('tampilBeranda'))
                else:
                    flash("Password-nya salah mas..!")
                    return render_template('login.html', form=form)
            else:
                flash("Username-nya salah mas..!")
                return render_template('login.html', form=form)
        except Exception as e:
            print("Execption: ", e)
            return render_template('error.html', error=str(e))
    return render_template('login.html', form=form)

@app.route('/histori', methods=['GET', 'POST'])
def tampilHistori():
    if session.get('user'):
        query = 'get_train_data_distribution'
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.callproc(query)
        class_distrib = cursor.fetchall()[0]
        cursor.close()
        
        query = 'get_employees_history'
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.callproc(query)
        employees_history = cursor.fetchall()
        return render_template('histori.html', employees_history=employees_history, 
                                                class_distrib=class_distrib)
    else:
        return render_template('error.html', error='Unauthorized Access')

@app.route('/edit', methods=['POST'])
def editData():
    _id = request.form.get('id')    
    #_attrition = request.form.get('attrition')
    _age = request.form.get('age')
    #---- convert foreign key -----------------
    _departmant = request.form.get('department')
    _department_id = ''
    if _departmant.lower() == 'research & development':
        _department_id = 'DP1'
    elif _departmant.lower == 'sales':
        _department_id = 'DP2'
    else:
        _department_id = 'DP3'
    #------------------------------------------
    _dist_from_home = request.form.get('dist_from_home')
    _edu = request.form.get('edu')
    _edu_field = request.form.get('edu_field')
    _env_sat = request.form.get('env_sat')
    _job_sat = request.form.get('job_sat')
    _marital_sts = request.form.get('marital_sts')
    _num_comp_worked = request.form.get('num_comp_worked')
    _salary = request.form.get('salary')
    _wlb = request.form.get('wlb')
    _years_at_comp = request.form.get('years_at_comp')
    
    # set attrition null sebelum update
    query = 'set_attrition_null'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.callproc(query, [_id])
    mysql.connection.commit()
    cursor.close()

    # update data
    query = 'update employee \
             set age = %s, \
                 department_id = %s,\
                 dist_from_home = %s,\
                 edu = %s,\
                 edu_field = %s,\
                 env_sat = %s,\
                 job_sat = %s,\
                 marital_sts = %s,\
                 num_comp_worked = %s,\
                 salary = %s,\
                 wlb = %s,\
                 years_at_comp = %s\
            where id = %s'

    values = [_age, _department_id, _dist_from_home, _edu, \
            _edu_field, _env_sat, _job_sat, _marital_sts, \
            _num_comp_worked, _salary, _wlb, _years_at_comp, _id]

    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query, values)
    mysql.connection.commit()
    cursor.close()
    flash('Data ' + _id + ' berhasil diubah.')
    return redirect(url_for('tampilBeranda'))

@app.route('/delete', methods=['POST'])
def deleteData():
    _id = request.form.get('id')
    query = 'delete from employee where id = %s'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute(query, [_id])
    mysql.connection.commit()
    cursor.close()
    flash('Data ' + _id + ' berhasil dihapus.')
    return redirect(url_for('tampilBeranda'))


@app.route('/prediksi', methods=['GET', 'POST'])
def prediksiAtrisi():
    query = 'get_test_data'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.callproc(query)
    test_data = cursor.fetchall()
    cursor.close()

    if session.get('predictions') == None:
        predictions = {}
        session['predictions'] = predictions

    if request.method == 'POST':
        import pandas as pd
        from model.model import Classifier
        
        # data latih
        query = 'get_train_data'
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.callproc(query)
        train_df = pd.DataFrame(cursor.fetchall())
        
        if request.form.get('predict_type') == 'single':
            # data uji
            _id = request.form.get('id')
            for data in test_data:
                if data['id'] == _id:
                    single_test_data = [data]
                    break
            test_df = pd.DataFrame(single_test_data)

            # Pemisahan idetifier data latih dan uji
            train_df.drop('employee_id', axis=1, inplace=True)
            test_id = test_df['id'].values.tolist()
            test_df.drop('id', axis=1, inplace=True)

            # Prediksi (klasifikasi) atrisi menggunakan k-NN dengan nilai k=7
            cls = Classifier()
            predictions = cls.get_classification(train_df, test_df, test_id, k=7)
            
            predictions_sess = session.get('predictions')
            predictions_sess[_id] = predictions[_id]
            session['predictions'] = predictions_sess
            flash(str(len(test_id)) + " data berhasil di prediksi.")
            return render_template('prediksi.html', test_data=test_data)
        else:
            predictions_sess = session.get('predictions')
            predicted_id = predictions_sess.keys()

            many_test_data = []
            for data in test_data:
                if data['id'] not in predicted_id:
                    many_test_data.append(data)
            test_df = pd.DataFrame(many_test_data)

            # Pemisahan idetifier data latih dan uji
            train_df.drop('employee_id', axis=1, inplace=True)
            test_id = test_df['id'].values.tolist()
            test_df.drop('id', axis=1, inplace=True)

            # Prediksi (klasifikasi) atrisi menggunakan k-NN dengan nilai k=7
            cls = Classifier()
            predictions = cls.get_classification(train_df, test_df, test_id, k=7)
            
            for id in test_id:
                predictions_sess[id] = predictions[id]

            session['predictions'] = predictions_sess
            flash(str(len(test_id)) + " data berhasil di prediksi.")
            return render_template('prediksi.html', test_data=test_data)
    else:
        return render_template('prediksi.html', test_data=test_data)

@app.route('/simpanprediksi', methods=['POST'])
def simpanPrediksi():
    predictions_sess = session.get('predictions')
    predicted_id = predictions_sess.keys()

    query = 'update employee set attrition = %s where id = %s'
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    for id in predicted_id:
        cursor.execute(query, [predictions_sess[id], id])
        mysql.connection.commit()
    cursor.close()
    flash(str(len(predicted_id))+' data prediksi berhasil disimpan.')
    session.pop('predictions', None)
    return redirect(url_for('prediksiAtrisi'))



"""
@app.route('/signup', methods=['GET', 'POST'])
def signUp():
    form = SignupForm()
    if form.validate_on_submit():
        _name = form.name.data
        _username = form.username.data
        _password = form.password.data
        try:
            conn = mysql.connection
            cursor = conn.cursor()
            cursor.callproc('sp_createUser', (_name, _username, _password))

            data = cursor.fetchall()
            print('>data:', data)
            print('>len data:', len(data), '\n')
            if len(data) == 0:
                print('Register Sucessfull')
                flash('Register Successfull!!')
                conn.commit()
            else:
                flash('Insert into DB failde!')

            return render_template('signup2.html', form=form)
        except Exception as e:
            print(e)
            # flash('Internal server error!')
            return render_template('signup2.html', form=form)
    return render_template('signup2.html', form=form)


# --------------DAO----------------------------------------------
@app.route("/ajax_add", methods=["POST", "GET"])
def ajax_add():
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    if request.method == 'POST':
        cur.execute('SELECT COUNT(*) as num_of_emp FROM employee;')
        num_of_emp = cur.fetchall()[0]['num_of_emp']
        cur.execute('SELECT * FROM employee limit %s,%s;', [num_of_emp-1,num_of_emp])
        last_id_no = cur.fetchall()[0]['id']
        print("\last id no:", last_id_no, '\n')
        last_id_no = int(last_id_no.replace('ep', ''))
        print("num of emp: ", num_of_emp, "\n")
        id = 'ep'+ str(num_of_emp)
        txtname = request.form['txtname']
        txtdepartment = request.form['txtdepartment']
        txtphone = request.form['txtphone']
        print(txtname)
        if txtname == '':
            msg = 'Please Input name'
        elif txtdepartment == '':
            msg = 'Please Input Department'
        elif txtphone == '':
            msg = 'Please Input Phone'
        else:
            cur.execute("INSERT INTO employee (id,name,department,phone) VALUES (%s,%s,%s,%s)", [
                            id, txtname, txtdepartment, txtphone])
            mysql.connection.commit()
            cur.close()
            msg = 'New record created successfully'
    return jsonify(msg)


@app.route("/ajax_update", methods=["POST", "GET"])
def ajax_update():
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    if request.method == 'POST':
        string = request.form['string']
        txtname = request.form['txtname']
        txtdepartment = request.form['txtdepartment']
        txtphone = request.form['txtphone']
        print(string)
        cur.execute("UPDATE employee SET name = %s, department = %s, phone = %s WHERE id = %s ", [
                    txtname, txtdepartment, txtphone, string])
        mysql.connection.commit()
        cur.close()
        msg = 'Record successfully Updated'
    return jsonify(msg)


@app.route("/ajax_delete", methods=["POST", "GET"])
def ajax_delete():
    cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    if request.method == 'POST':
        getid = request.form['string']
        print(getid)
        cur.execute('DELETE FROM employee WHERE id = %s', [getid])
        mysql.connection.commit()
        cur.close()
        msg = 'Record deleted successfully'
    return jsonify(msg)
"""

if __name__ == "__main__":
    app.run()
