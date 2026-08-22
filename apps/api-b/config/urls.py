from django.urls import path, include

urlpatterns = [
    path("b/api/", include("api.urls")),
]
