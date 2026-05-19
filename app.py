from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'your_password',
    'database': 'warehouse_management',
    'autocommit': True
}

def get_db():
    return mysql.connector.connect(**db_config)

# ---------- 仓库管理 ----------
@app.route('/api/warehouses', methods=['GET'])
def get_warehouses():
    keyword = request.args.get('keyword', '')
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    if keyword:
        cursor.execute("SELECT * FROM warehouse WHERE code LIKE %s OR name LIKE %s", 
                       (f'%{keyword}%', f'%{keyword}%'))
    else:
        cursor.execute("SELECT * FROM warehouse")
    data = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(data)

@app.route('/api/warehouses/<int:id>', methods=['GET'])
def get_warehouse(id):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM warehouse WHERE id = %s", (id,))
    row = cursor.fetchone()
    cursor.close()
    conn.close()
    return jsonify(row) if row else ('', 404)

@app.route('/api/warehouses', methods=['POST'])
def add_warehouse():
    data = request.json
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO warehouse (code, name, address, manager, phone, status, description)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (data['code'], data['name'], data['address'], data['manager'], 
          data['phone'], data['status'], data['description']))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'success'}), 201

@app.route('/api/warehouses/<int:id>', methods=['PUT'])
def update_warehouse(id):
    data = request.json
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE warehouse SET code=%s, name=%s, address=%s, manager=%s, phone=%s, status=%s, description=%s
        WHERE id=%s
    """, (data['code'], data['name'], data['address'], data['manager'], 
          data['phone'], data['status'], data['description'], id))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'success'})

@app.route('/api/warehouses/<int:id>', methods=['DELETE'])
def delete_warehouse(id):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM warehouse WHERE id = %s", (id,))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'deleted'})

if __name__ == '__main__':
    app.run(debug=True)