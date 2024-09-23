from django.contrib import admin

# Register your models here.

from .models import item_inventory, item_description, suppliers, item_transactions

admin.site.register(item_inventory)
admin.site.register(item_description)
admin.site.register(suppliers)
admin.site.register(item_transactions)
