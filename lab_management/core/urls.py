from django.contrib import admin
from django.urls import path, include
from . import views
from django.contrib.auth import views as auth_views

from django.conf import settings
from django.conf.urls.static import static
from django.conf.urls import handler404
from core.views import custom_404_view
handler404 = custom_404_view

urlpatterns = [
    path('login/', views.userlogin, name='userlogin'),
    path('register/', views.register, name='register'),
    path("confirm-email/<uidb64>/<token>/", views.confirm_email, name="confirm_email"),
    
    path('', views.home, name='home'),
    path('request_laboratory/', views.request_laboratory, name='request_laboratory'),
    path('get_laboratory_roles/', views.get_laboratory_roles, name='get_laboratory_roles'),

    path('set_lab/<int:laboratory_id>/', views.set_lab, name='set_lab'),
    path('logout/', views.logout_view, name='logout'),  # Added trailing slash
    path('error/', views.error_page, name='error_page'),
    path('edit-profile/', views.edit_profile, name='edit_profile'),
    path('my-profile/', views.my_profile, name='my_profile'),
    path('deactivate-account/', views.deactivate_account, name='deactivate_account'),
    path('social/signup/', views.signup_redirect, name='signup_redirect'),

    # path('accounts/', include('allauth.urls')),
    # path('auth/', include('dj_rest_auth.urls')),

    # inventory
    path('inventory/', views.inventory_view, name='inventory_view'),
    path("update-maintenance/<str:inventory_item_id>/", views.update_maintenance, name="update_maintenance"),

    path('inventory/addNewItem/', views.inventory_addNewItem_view, name='inventory_addNewItem'),  # Added trailing slash
    path('inventory/mass-upload/', views.inventory_mass_upload_view, name="inventory_mass_upload"),
    path('inventory/updateItem/', views.inventory_updateItem_view, name='inventory_updateItem'),  # Added trailing slash
    path('inventory/itemDetails/<int:item_id>/', views.inventory_itemDetails_view, name='inventory_itemDetails_view'),  # Consistent naming
    path('inventory/item/edit/<int:item_id>/', views.inventory_itemEdit_view, name='inventory_itemEdit_view'),
    path('inventory/get_item_type_add_cols/<int:itemType_id>/', views.get_item_type_add_cols, name='get_item_type_add_cols'),
    path('inventory/item/delete/<int:item_id>/', views.inventory_itemDelete_view, name='inventory_itemDelete_view'),
    path('inventory/physicalCount/', views.inventory_physicalCount_view, name='inventory_physicalCount'),  # Added trailing slash
    path('inventory/config/', views.inventory_config_view, name='inventory_config'),
    path('check_item_expiration/<int:item_id>/', views.check_item_expiration, name='check_item_expiration'),
    path('inventory/manageSuppliers/', views.inventory_manageSuppliers_view, name='inventory_manageSuppliers'),
    path('inventory/supplierDetails/<int:supplier_id>/', views.inventory_supplierDetails_view, name='inventory_supplierDetails'),
    path('inventory_config/', views.inventory_config_view, name='inventory_config'),
    path('add_category/', views.add_category, name='add_category'),
    path('add_attributes/', views.add_attributes, name='add_attributes'),
    path('delete_category/<int:category_id>/', views.delete_category, name='delete_category'),
    path('delete_attribute/<int:category_id>/<str:attribute_name>/', views.delete_attribute, name='delete_attribute'),
    path('get_fixed_choices/<int:category_id>/', views.get_fixed_choices, name='get_fixed_choices'),
    path('experiments/', views.inventory_experiments, name='inventory_experiments'),
    path('shopping_list/', views.inventory_buyList, name='inventory_buyList'),

    path("inventory/shopping_list/clear/<int:item_id>/", views.clear_buyItem, name="clear_buyItem"),

    # ajax select2
    path('suggest_items/', views.suggest_items, name='suggest_items'),
    path('suggest_suppliers/', views.suggest_suppliers, name='suggest_suppliers'),
    path('suggest_inventory_items/<str:item_id>/', views.suggest_inventory_items, name='suggest_inventory_items'),

    # New URL for fetching add_cols
    path('get_add_cols/<int:category_id>/', views.get_add_cols, name='get_add_cols'),

    path('test', views.test_view, name='test_view'),

    # borrowing
    path('borrowing/', views.borrowing_view, name='borrowing'),
    path('borrowing/student/borrow_prebook', views.borrowing_student_prebookview, name='borrowing_studentPrebook'),
    path('borrowing/student/borrow_walkin', views.borrowing_student_walkinview, name='borrowing_studentWalkin'),
    path('borrowing/student/viewPreBookRequests', views.borrowing_student_viewPreBookRequestsview, name='borrowing_studentviewPreBookRequests'),
    path('cancel-request/', views.cancel_borrow_request, name='cancel_borrow_request'),
    path('borrowing/student/viewWalkInRequests', views.borrowing_student_detailedWalkInRequestsview, name='borrowing_studentviewWalkInRequests'),
    path('borrowing/student/detailedPreBookRequests/<int:borrow_id>/', views.borrowing_student_detailedPreBookRequestsview, name='borrowing_studentDetailedPreBookRequests'),
    path('borrowing/student/detailedWalkInRequests', views.borrowing_student_detailedWalkInRequestsview, name='borrowing_studentDetailedWalkInRequests'),
    
    path('borrowing/labcoord/prebookrequests', views.borrowing_labcoord_prebookrequests, name='borrowing_labcoord_prebookrequests'),
    path('borrowing/labcoord/detailedPrebookrequests/<int:borrow_id>/', views.borrowing_labcoord_detailedPrebookrequests, name='borrowing_labcoord_detailedPrebookrequests'),
    path('borrowing/labcoord/borrowconfig', views.borrowing_labcoord_borrowconfig, name='borrowing_labcoord_borrowconfig'),

    path('mark-all-notifications-read/', views.mark_all_notifications_read, name='mark_all_notifications_read'),

    path('borrowing/student/get-items/<int:item_type_id>/', views.get_items_by_type, name='get_items_by_type'),
    path('borrowing/student/get-quantity/<int:item_id>/', views.get_quantity_for_item, name='get_quantity_for_item'),
    
    path('borrowing/labtech/prebookrequests', views.borrowing_labtech_prebookrequests, name='borrowing_labtech_prebookrequests'),
    path('borrowing/labtech/detailedprebookrequests/<int:borrow_id>/', views.borrowing_labtech_detailedprebookrequests, name='borrowing_labtech_detailedprebookrequests'),
    path('borrowing/return-items/', views.return_borrowed_items, name='return_borrowed_items'),
    
    # clearance
    path('clearance/', views.clearance_view, name='clearance'),
    path('clearance/student/view_clearance', views.clearance_student_viewClearance, name='clearance_student_viewClearance'),
    path('clearance/student/view_clearance_detailed/<int:report_id>/', views.clearance_student_viewClearanceDetailed, name='clearance_student_viewClearanceDetailed'), 
    path('clearance/labtech/view_clearance', views.clearance_labtech_viewclearance, name='clearance_labtech_viewclearance'), 
    path('clearance/labtech/view_clearance_detailed/<int:report_id>/', views.clearance_labtech_viewclearanceDetailed, name='clearance_labtech_viewclearanceDetailed'),
    path('suggest_report_users/', views.suggest_report_users, name='suggest_report_users'),
    path('validate_borrow_id/', views.validate_borrow_id, name='validate_borrow_id'),
    
    # lab reservation
    path('lab-reservation/', views.lab_reservation_view, name='lab_reservation'),
    path('lab-reservation/student/reserveLabPreApproval', views.lab_reservation_preapproval, name='lab_reservation_preapproval'),
    path('lab-reservation/student/reserveLabChooseRoom', views.lab_reservation_student_reserveLabChooseRoom, name='lab_reservation_student_reserveLabChooseRoom'),
    path('lab-reservation/student/reserveLabConfirm/', views.lab_reservation_student_reserveLabConfirm, name='lab_reservation_student_reserveLabConfirm'),
    path('lab-reservation/student/reserveLabConfirmDetails/', views.lab_reservation_student_reserveLabConfirmDetails, name='lab_reservation_student_reserveLabConfirmDetails'),
    
    path('lab-reservation/student/reserveLabChooseTime', views.lab_reservation_student_reserveLabChooseTime, name='lab_reservation_student_reserveLabChooseTime'),
    path('lab-reservation/student/reserveLabSummary', views.lab_reservation_student_reserveLabSummary, name='lab_reservation_student_reserveLabSummary'),
    path('lab-reservation/student/reservation/<int:reservation_id>/', views.lab_reservation_detail, name='lab_reservation_detail'),
    path('lab-reservation/student/cancelReservation/<int:reservation_id>/', views.cancel_reservation, name='cancel_reservation'),
    path('lab-reservation/labcoord/configRoom', views.labres_labcoord_configroom, name='labres_labcoord_configroom'),
    path('get-room-configuration/<int:room_id>/', views.get_room_configuration, name='get_room_configuration'),

    
    path('get_room_tables/', views.get_room_tables, name='get_room_tables'),
    path('lab-reservation/bulk-upload/', views.labres_bulk_upload, name='labres_bulk_upload'),
    path('lab-reservation/bulk-upload-time/', views.labres_bulk_upload_time, name='labres_bulk_upload_time'),
    path('lab-reservation/lab/schedule', views.labres_lab_schedule, name='labres_lab_schedule'),
    path('lab-reservation/lab/reservationRequests', views.labres_lab_reservationreqs, name='labres_lab_reservationreqs'),
    path('lab-reservation/lab/reservationRequests_detailed/<int:reservation_id>/', views.labres_lab_reservationreqsDetailed, name='labres_lab_reservationreqsDetailed'),

    # wip
    path('wip/student/', views.student_create_wip, name="student_wip_list"),
    path('wip/laboratory/', views.lab_wip_list, name="lab_wip_list"),
    path('wip/<str:wip_id>/', views.view_wip, name='view_wip'),
    path('wip/<str:wip_id>/clear/', views.clear_wip, name='clear_wip'),

    # reports
    path('user-reports/', views.reports_view, name='user_reports'),
    path('inventory-reports/', views.inventory_reports, name='inventory_reports'),
    path('borrowing-reports/', views.borrowing_reports, name='borrowing_reports'),
    path('clearance-reports/', views.clearance_reports, name='clearance_reports'),
    path('labres-reports/', views.labres_reports, name='labres_reports'),

    path('inventory-data/<int:item_type_id>/<int:laboratory_id>/', views.inventory_data, name='inventory_data'),
    path('admin-reports/', views.admin_reports_view, name='admin_reports'),

    # Superuser URLs
    path('login/superuser/', views.superuser_login, name='superuser_login'),  # Added trailing slash
    path('setup/logout/', views.superuser_logout, name='superuser_logout'),  # Added trailing slash
    path('setup/', views.superuser_setup, name='superuser_setup'),
    path('add-laboratory/', views.add_laboratory, name='add_laboratory'),  # New URL
    path('setup/manageLabs', views.superuser_manage_labs, name='superuser_manage_labs'),
    path('setup/labInfo/<int:laboratory_id>/', views.superuser_lab_info, name='superuser_lab_info'),
    # path('setup/labInfo/addModule/<int:laboratory_id>/', views.add_module_to_lab, name='add_module_to_lab'),
    path('setup/editLab/<int:laboratory_id>/', views.edit_lab_info, name='edit_lab_info'),
    path('setup/deactivate_lab/<int:laboratory_id>/', views.deactivate_lab, name='deactivate_lab'),
    path('setup/labInfo/<int:laboratory_id>/toggle_module/', views.toggle_module_status, name='toggle_module_status'),
    
    path('setup/labInfo/<int:laboratory_id>/add_room/', views.add_room, name='add_room'),
    #path('setup/editLab/<int:laboratory_id>/', views.setup_editLab, name='setup_editLab'),
    path('setup/manageRooms', views.setup_manageRooms, name='setup_manageRooms'),
    path('superuser/bulk_upload/', views.bulk_upload_users, name='bulk_upload_users'),
    path('setup/labInfo/<int:laboratory_id>/bulk_upload_existing_users/', views.bulk_upload_users_to_lab, name='bulk_upload_existing_users'),
    path('setup/manageusers', views.superuser_manage_users, name='superuser_manage_users'),
    path('setup/userInfo/<int:user_id>/', views.superuser_user_info, name='superuser_user_info'),
    path('setup/edituser', views.setup_edituser, name='setup_edituser'),
    
    path('setup/createlab', views.setup_createlab, name='setup_createlab'),
    path('update_permissions/<int:laboratory_id>/', views.update_permissions, name='update_permissions'),
    path('add_role/', views.add_role, name='add_role'),
    
    path('labs/<int:laboratory_id>/add_user/', views.add_user_laboratory, name='add_user_laboratory'),  # To add user
    path('suggest_users/', views.suggest_users, name='suggest_users'),
    path('labs/<int:laboratory_id>/edit_user_role/', views.edit_user_role, name='edit_user_role'),
    path('labs/toggle_user_status/', views.toggle_user_status, name='toggle_user_status'),

    path('add-user/', views.add_user, name='add_user'),
    path('user/<int:user_id>/', views.superuser_user_info, name='superuser_user_info'),
    path('user/<int:user_id>/edit/', views.edit_user, name='edit_user'),
    path('user/<int:user_id>/deactivate/', views.deactivate_user, name='deactivate_user'),
    path('user/<int:user_id>/assign-lab/', views.assign_lab, name='assign_lab'),

    path('export-schedule/', views.export_schedule_to_excel, name='export_schedule'),

    path('get_roles/<int:laboratory_id>/', views.get_roles, name='get_roles'),
    path('remove_lab_user/<int:lab_user_id>/', views.remove_lab_user, name='remove_lab_user'),

    path('late_borrow/', views.late_borrow, name='late_borrow')
]

urlpatterns += [
    path('change-password/', auth_views.PasswordChangeView.as_view(template_name='change_password.html'), name='change_password'),
    path('change-password/done/', auth_views.PasswordChangeDoneView.as_view(template_name='change_password_done.html'), name='password_change_done'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
