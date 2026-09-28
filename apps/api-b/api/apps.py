from django.apps import AppConfig


class ApiConfig(AppConfig):
    name = "api"
    # api-b/api-cは同じDBのdjango_migrationsテーブルを共有するため、ラベルで区別する
    label = "api_b"
