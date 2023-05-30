import pymysql
HOST = '10.134.136.178'
PORT = 3306
USER = 'root'
PSWD = 'Alivehex4ever'
DB = 'wardman'
conn = pymysql.connect(host=HOST, port=PORT, user=USER, passwd=PSWD, db=DB)
cursor = conn.cursor(cursor=pymysql.cursors.DictCursor)
cursor.execute('SELECT * FROM login_view')
result = cursor.fetchall()
cursor.close()
conn.close()
print(result)