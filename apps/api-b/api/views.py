from django.http import JsonResponse

# trigger: ECRライフサイクル導入後、ECRへの再プッシュ確認用
def health(request):
    return JsonResponse({"status": "ok", "service": "api-b"})
