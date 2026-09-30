"""
DBの初期設定を行う一度きりのタスク(CI/CDのworkflow_dispatchからECS RunTaskで実行する)

マスターユーザーで次を順に行う。
1. アプリ用データベースとDBユーザーを作成する
2. マイグレーションを実行する(アプリ用ユーザーにはCREATE等を与えないため、マスターユーザーで行う)
3. アプリ用ユーザーに最小権限をGRANTする(テーブルが存在しないとGRANTできないため、マイグレーションの後)

api-bのtoursを参照するため、api-bのタスクの後に実行する。
"""

import os

import pymysql

DB_NAME = "tour_booking"

# アプリが実際に行う操作だけを許可する
GRANTS = [
    # ツアーの一覧・詳細
    "GRANT SELECT ON {db}.tours TO '{user}'@'%'",
    # 残り枠の増減(capacity.py)のみ。価格・タイトル等のガイドのデータはC側から書き換えさせない
    "GRANT UPDATE (remaining) ON {db}.tours TO '{user}'@'%'",
    # 予約の一覧・作成・確定/取消。削除は行わないためDELETEは付けない
    "GRANT SELECT, INSERT, UPDATE ON {db}.bookings TO '{user}'@'%'",
]


def create_database_and_user(cursor, username, password):
    # RDSはdb_name未指定で作成しているため、アプリ用データベースをここで作る
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME} CHARACTER SET utf8mb4")
    # usernameはTerraform側で固定管理された値のみを渡す想定(利用者入力ではない)
    cursor.execute(f"CREATE USER IF NOT EXISTS '{username}'@'%%' IDENTIFIED BY %s", (password,))
    # 既存ユーザーでもSecrets Managerのパスワードと一致させる(ローテーション後の再実行に備える)
    cursor.execute(f"ALTER USER '{username}'@'%%' IDENTIFIED BY %s", (password,))


def migrate():
    # アプリの設定(config/settings.py)はDB_USER/DB_PASSWORDで接続するため、マスターユーザーの値を入れる
    os.environ["DB_USER"] = os.environ["DB_MASTER_USERNAME"]
    os.environ["DB_PASSWORD"] = os.environ["DB_MASTER_PASSWORD"]
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

    import django
    from django.core.management import call_command

    django.setup()
    call_command("migrate", interactive=False)


def grant_privileges(cursor, username):
    # GRANTは追加しかしないため、一度すべて取り消してから付け直し、GRANTSと実際の権限を一致させる
    cursor.execute(f"REVOKE ALL PRIVILEGES, GRANT OPTION FROM '{username}'@'%'")
    for statement in GRANTS:
        cursor.execute(statement.format(db=DB_NAME, user=username))


def main():
    username = os.environ["APP_DB_USERNAME"]
    password = os.environ["APP_DB_PASSWORD"]
    connection = pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_MASTER_USERNAME"],
        password=os.environ["DB_MASTER_PASSWORD"],
    )
    try:
        with connection.cursor() as cursor:
            create_database_and_user(cursor, username, password)
        connection.commit()

        migrate()

        with connection.cursor() as cursor:
            grant_privileges(cursor, username)
        connection.commit()
    finally:
        connection.close()


if __name__ == "__main__":
    main()
