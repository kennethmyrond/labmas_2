from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.userlogin, name='userlogin'),
    path('', views.home, name='home'),
    path('set_lab/<int:laboratory_id>/', views.set_lab, name='set_lab'),
    path('logout/', views.logout_view, name='logout'),  # Added trailing slash
    path('error/', views.error_page, name='error_page'),

    # inventory
    path('inventory/', views.inventory_view, name='inventory_view'),
    path('inventory/addNewItem/', views.inventory_addNewItem_view, name='inventory_addNewItem'),  # Added trailing slash
    path('inventory/updateItem/', views.inventory_updateItem_view, name='inventory_updateItem'),  # Added trailing slash
    path('inventory/itemDetails/<int:item_id>/', views.inventory_itemDetails_view, name='inventory_itemDetails_view'),  # Consistent naming
    path('inventory/item/edit/<int:item_id>/', views.inventory_itemEdit_view, name='inventory_itemEdit_view'),
    path('inventory/item/delete/<int:item_id>/', views.inventory_itemDelete_view, name='inventory_itemDelete_view'),
    path('inventory/physicalCount/', views.inventory_physicalCount_view, name='inventory_physicalCount'),  # Added trailing slash
    path('inventory/config/', views.inventory_config_view, name='inventory_config'),
    path('check_item_expiration/<int:item_id>/', views.check_item_expiration, name='check_item_expiration'),
    path('suggest_items/', views.suggest_items, name='suggest_items'),
    path('suggest_suppliers/', views.suggest_suppliers, name='suggest_suppliers'),
    path('inventory/manageSuppliers/', views.inventory_manageSuppliers_view, name='inventory_manageSuppliers'),
    path('inventory/supplierDetails/<int:supplier_id>/', views.inventory_supplierDetails_view, name='inventory_supplierDetails'),
    path('inventory_config/', views.inventory_config_view, name='inventory_config'),
    path('add_category/', views.add_category, name='add_category'),
    path('add_attributes/', views.add_attributes, name='add_attributes'),
    path('delete_category/<int:category_id>/', views.delete_category, name='delete_category'),
    path('delete_attribute/<int:category_id>/<str:attribute_name>/', views.delete_attribute, name='delete_attribute'),
    path('get_fixed_choices/<int:category_id>/', views.get_fixed_choices, name='get_fixed_choices'),

    # New URL for fetching add_cols
    path('get_add_cols/<int:category_id>/', views.get_add_cols, name='get_add_cols'),

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
    
    path('borrowing/student/get-items/<int:item_type_id>/', views.get_items_by_type, name='get_items_by_type'),
    path('borrowing/student/get-quantity/<int:item_id>/', views.get_quantity_for_item, name='get_quantity_for_item'),
    
    path('borrowing/labtech/prebookrequests', views.borrowing_labtech_prebookrequests, name='borrowing_labtech_prebookrequests'),
    path('borrowing/labtech/detailedprebookrequests/<int:borrow_id>/', views.borrowing_labtech_detailedprebookrequests, name='borrowing_labtech_detailedprebookrequests'),
    path('borrowing/return-items/', views.return_borrowed_items, name='return_borrowed_items'),


    path('clearance/', views.clearance_view, name='clearance'),
    path('clearance/student/view_clearance', views.clearance_student_viewClearance, name='clearance_student_viewClearance'),
    path('clearance/student/view_clearance_detailed/<int:borrow_id>/', views.clearance_student_viewClearanceDetailed, name='clearance_student_viewClearanceDetailed'), 
    path('clearance/labtech/view_clearance', views.clearance_labtech_viewclearance, name='clearance_labtech_viewclearance'), 
    path('clearance/labtech/view_clearance_detailed/<int:report_id>/', views.clearance_labtech_viewclearanceDetailed, name='clearance_labtech_viewclearanceDetailed'),
    
    path('lab-reservation/', views.lab_reservation_view, name='lab_reservation'),
    path('lab-reservation/student/reserveLabChooseRoom', views.lab_reservation_student_reserveLabChooseRoom, name='lab_reservation_student_reserveLabChooseRoom'),
    path('lab-reservation/student/reserveLabConfirm/', views.lab_reservation_student_reserveLabConfirm, name='lab_reservation_student_reserveLabConfirm'),
    path('lab-reservation/student/reserveLabConfirmDetails/', views.lab_reservation_student_reserveLabConfirmDetails, name='lab_reservation_student_reserveLabConfirmDetails'),
    
    
    path('lab-reservation/student/reserveLabChooseTime', views.lab_reservation_student_reserveLabChooseTime, name='lab_reservation_student_reserveLabChooseTime'),
    path('lab-reservation/student/reserveLabSummary', views.lab_reservation_student_reserveLabSummary, name='lab_reservation_student_reserveLabSummary'),
    path('lab-reservation/student/reservation/<int:reservation_id>/', views.lab_reservation_detail, name='lab_reservation_detail'),
    path('lab-reservation/student/cancelReservation/<int:reservation_id>/', views.cancel_reservation, name='cancel_reservation'),
    path('lab-reservation/labcoord/configRoom', views.labres_labcoord_configroom, name='labres_labcoord_configroom'),
    path('get-room-configuration/<int:room_id>/', views.get_room_configuration, name='get_room_configuration'),


    path('lab-reservation/lab/schedule', views.labres_lab_schedule, name='labres_lab_schedule'),
    path('lab-reservation/lab/reservationRequests', views.labres_lab_reservationreqs, name='labres_lab_reservationreqs'),
    path('lab-reservation/lab/reservationRequests_detailed/<int:reservation_id>/', views.labres_lab_reservationreqsDetailed, name='labres_lab_reservationreqsDetailed'),


    path('reports/', views.reports_view, name='reports'),
    path('user-settings/', views.user_settings_view, name='user_settings'),

    # Superuser URLs
    path('login/superuser/', views.superuser_login, name='superuser_login'),  # Added trailing slash
    path('setup/logout/', views.superuser_logout, name='superuser_logout'),  # Added trailing slash
    path('setup/', views.superuser_setup, name='superuser_setup'),
    path('add-laboratory/', views.add_laboratory, name='add_laboratory'),  # New URL
]
