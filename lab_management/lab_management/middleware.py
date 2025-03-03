from django.utils.deprecation import MiddlewareMixin
from django.db import connection

class SetCurrentUserMiddleware(MiddlewareMixin):
    def process_request(self, request):
        if request.user.is_authenticated:
            current_user = request.user.user_id
            with connection.cursor() as cursor:
                cursor.execute("SET @current_user = %s", [current_user])
