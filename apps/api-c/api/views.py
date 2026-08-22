from django.http import JsonResponse

# trigger: イミュータブルタグ衝突回避のためのダミー変更
def health(request):
    return JsonResponse({"status": "ok", "service": "api-c"})
