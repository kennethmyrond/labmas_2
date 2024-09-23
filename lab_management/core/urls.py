from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.userlogin, name='userlogin'),
    path('', views.home, name = 'home'),
    path("logout", views.logout_view, name='logout'),
    path('inventory/', views.inventory_view, name='inventory_view'),
    path('inventory/addNewItem', views.inventory_addNewItem_view, name='inventory_addNewItem'),
    path('inventory/updateItem', views.inventory_updateItem_view, name='inventory_updateItem'),
    path('inventory/itemDetails', views.inventory_itemDetails_view, name='inventory_itemDetails'),
    path('inventory/physicalCount', views.inventory_physicalCount_view, name='inventory_physicalCount'),
    path('borrowing/', views.borrowing_view, name='borrowing'),
    path('clearance/', views.clearance_view, name='clearance'),
    path('lab-reservation/', views.lab_reservation_view, name='lab_reservation'),
    path('reports/', views.reports_view, name='reports'),
    path('user-settings/', views.user_settings_view, name='user_settings'),

    # superuser
    path('login/superuser', views.superuser_login, name='login'),
    path('setup/logout', views.superuser_logout, name='superuser_logout'),
    path('setup/', views.superuser_setup, name='superuser_setup'),
    path('add-laboratory/', views.add_laboratory, name='add_laboratory'),  # New URL
]

