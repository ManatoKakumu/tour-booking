import os
import pymysql

def main():
    connection = pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_MASTER_USERNAME"],
        password=os.environ["DB_MASTER_PASSWORD"],
    )
    try:
        with connection.cursor() as cursor:
            username = os.environ["APP_DB_USERNAME"]
            password = os.environ["APP_DB_PASSWORD"]
            # usernameはTerraform側で固定管理された値のみを渡す想定(利用者入力ではない)
            cursor.execute(
                f"CREATE USER IF NOT EXISTS '{username}'@'%%' IDENTIFIED BY %s",
                (password,),
            )
        connection.commit()
    finally:
        connection.close()

if __name__ == "__main__":
    main()
