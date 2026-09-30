import pymysql

# DjangoのMySQLバックエンドはmysqlclientを前提とするため、PyMySQLで代替する
pymysql.install_as_MySQLdb()
