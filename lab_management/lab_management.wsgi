import os import sys
# Add the project directory to the sys.path
sys.path.append('/root/labmas_2/lab_management')
# Set the default Django settings module
os.environ['DJANGO_SETTINGS_MODULE'] = 
'lab_management.settings' from django.core.wsgi import 
get_wsgi_application application = get_wsgi_application()
