from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.userlogin, name='userlogin'),
    path('', views.home, name='home'),
    path('set_lab/<int:laboratory_id>/', views.set_lab, name='set_lab'),
    path('logout/', views.logout_view, name='logout'),  # Added trailing slash
    path('inventory/', views.inventory_view, name='inventory_view'),
    path('inventory/addNewItem/', views.inventory_addNewItem_view, name='inventory_addNewItem'),  # Added trailing slash
    path('inventory/updateItem/', views.inventory_updateItem_view, name='inventory_updateItem'),  # Added trailing slash
    path('inventory/itemDetails/<int:item_id>/', views.inventory_itemDetails_view, name='inventory_itemDetails_view'),  # Consistent naming
    path('inventory/item/edit/<int:item_id>/', views.inventory_itemEdit_view, name='inventory_itemEdit_view'),
    path('inventory/item/delete/<int:item_id>/', views.inventory_itemDelete_view, name='inventory_itemDelete_view'),
    path('inventory/physicalCount/', views.inventory_physicalCount_view, name='inventory_physicalCount'),  # Added trailing slash
    path('borrowing/', views.borrowing_view, name='borrowing'),
    path('clearance/', views.clearance_view, name='clearance'),
    path('lab-reservation/', views.lab_reservation_view, name='lab_reservation'),
    path('reports/', views.reports_view, name='reports'),
    path('user-settings/', views.user_settings_view, name='user_settings'),
    path('suggest_items/', views.suggest_items, name='suggest_items'),

    # Superuser URLs
    path('login/superuser/', views.superuser_login, name='superuser_login'),  # Added trailing slash
    path('setup/logout/', views.superuser_logout, name='superuser_logout'),  # Added trailing slash
    path('setup/', views.superuser_setup, name='superuser_setup'),
    path('add-laboratory/', views.add_laboratory, name='add_laboratory'),  # New URL
]
