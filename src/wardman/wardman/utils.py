import pymysql
import sys
sys.path.append('.')
from .config import HOST, PORT, USER, PSWD, DB

class MyHelper:
    def __init__(self):
        self.conn()
    # 连接数据库
    def conn(self):
        self.conn = pymysql.connect(host=HOST, port=PORT, user=USER, passwd=PSWD, db=DB)
        self.cursor = self.conn.cursor(cursor=pymysql.cursors.DictCursor)

    # 获取列表
    def get_list(self, sql):
        self.cursor.execute(sql)
        result = self.cursor.fetchall()
        return result
    
    # 获取单个
    def get_one(self, sql):
        self.cursor.execute(sql)
        result = self.cursor.fetchone()
        return result
    
    # 修改
    def modify(self, sql):
        if self.cursor.execute(sql):
            self.conn.commit()
            return True
        else: return False

    # 批量修改
    def multi_modify(self, sql):
        if self.cursor.executemany(sql):
            self.conn.commit()
            return True
        else: return False

    # 创建
    def create(self, sql):
        self.cursor.execute(sql)
        self.conn.commit()
        return True
    
    # 关闭连接
    def close(self):
        self.cursor.close()
        self.conn.close()
        return True