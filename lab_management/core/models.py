import json, qrcode, random
from datetime import datetime
from django.utils.crypto import get_random_string
from django.contrib.auth.models import User
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from io import BytesIO
from django.core.files import File
from PIL import Image, ImageDraw
from django.contrib.postgres.fields import JSONField

''' 
convention for pks
 year - user

 001 - laboratory
 oo2 - rooms

 inventory
 101

 borrow
 201

 clearance
 301

 reservations
 401
'''


class Module(models.Model): 
    MODULE_CHOICES = [
        ('inventory', 'Inventory Management'),
        ('borrowing', 'Borrowing'),
        ('clearance', 'Clearance'),
        ('reservation', 'Laboratory Reservation'),
        ('reports', 'Reports'),
    ]
    name = models.CharField(max_length=50, choices=MODULE_CHOICES)
    enabled = models.BooleanField(default=False)

    def __str__(self):
        return self.name

class permissions(models.Model):
    permission_id = models.AutoField(primary_key=True)
    module = models.ForeignKey(Module, on_delete=models.CASCADE,default=0)
    codename = models.CharField(max_length=45, null=True, blank=True)
    name = models.CharField(max_length=45, null=True, blank=True)
    
    def __str__(self):
        return self.codename

class laboratory(models.Model):
    laboratory_id = models.CharField(max_length=20, unique=True, primary_key=True)
    name = models.CharField(max_length=45, null=True, blank=True)
    description = models.CharField(max_length=45, null=True, blank=True)
    department = models.CharField(max_length=45, null=True, blank=True)
    is_available = models.BooleanField(default=True)  # 1 for active, 0 for terminated
    date_created = models.DateTimeField(default=timezone.now)
    modules = models.JSONField(blank=True, default=list)

    def save(self, *args, **kwargs):
        if not self.laboratory_id:
            current_year = datetime.now().year
            while True:
                random_number = get_random_string(length=4, allowed_chars='0123456789')
                self.laboratory_id = f"901{current_year}{random_number}"
                if not laboratory.objects.filter(laboratory_id=self.laboratory_id).exists():
                    break
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    def get_status(self):
        return "Active" if self.is_available else "Deactivated"

class laboratory_roles(models.Model):
    roles_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=45, null=True, blank=True)
    laboratory = models.ForeignKey(laboratory, on_delete=models.CASCADE)

    def __str__(self):
        return self.name
    
class laboratory_permissions(models.Model):
    role = models.ForeignKey(laboratory_roles, on_delete=models.CASCADE)
    laboratory = models.ForeignKey(laboratory, on_delete=models.CASCADE)
    permissions = models.ForeignKey(permissions, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('role', 'laboratory', 'permissions')

    def __str__(self):
        return f"{self.role} - {self.laboratory}"



class UserManager(BaseUserManager):
    def create_user(self, email, firstname, lastname, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, firstname=firstname, lastname=lastname, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, firstname, lastname, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, firstname, lastname, password, **extra_fields)

class user(AbstractBaseUser):
    user_id = models.CharField(max_length=20, unique=True, primary_key=True)
    firstname = models.CharField(max_length=45)
    lastname = models.CharField(max_length=45)
    username = models.CharField(max_length=45, unique=True)
    email = models.EmailField(unique=True)
    personal_id = models.CharField(max_length=45, null=True, blank=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    is_deactivated = models.BooleanField(default=False)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['firstname', 'lastname']

    def save(self, *args, **kwargs):
        if not self.user_id:
            current_year = datetime.now().year
            while True:
                random_number = get_random_string(length=4, allowed_chars='0123456789')
                self.user_id = f"{current_year}{random_number}"
                if not user.objects.filter(user_id=self.user_id).exists():
                    break
        super().save(*args, **kwargs)

    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perms(self, app_label):
        return self.is_superuser

    def __str__(self):
        return f"{self.firstname} {self.lastname}"
    
    def get_fullname(self):
        return f"{self.firstname} {self.lastname}"

class laboratory_users(models.Model):
    user = models.ForeignKey(user, on_delete=models.CASCADE)
    laboratory = models.ForeignKey(laboratory, on_delete=models.CASCADE)
    role = models.ForeignKey(laboratory_roles, on_delete=models.CASCADE, related_name='users')
    is_active = models.BooleanField(default=True)
    status = models.CharField(max_length=1, default='A') # A - Active, I - inactive, R - request access pending
    timestamp = models.DateTimeField(null=True, blank=True, auto_now_add=True)

class rooms(models.Model):
    room_id = models.CharField(max_length=20, unique=True, primary_key=True)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)
    name = models.CharField(max_length=45, null=True, blank=True)
    capacity = models.IntegerField(default=0)
    description = models.CharField(max_length=45, null=True, blank=True)
    is_disabled = models.BooleanField(default=False)
    is_reservable = models.BooleanField(default=True)
    blocked_time = models.CharField(max_length=45, null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.room_id:
            current_year = datetime.now().year
            while True:
                random_number = get_random_string(length=4, allowed_chars='0123456789')
                self.room_id = f"002{current_year}{random_number}"
                if not rooms.objects.filter(room_id=self.room_id).exists():
                    break
        super().save(*args, **kwargs)
    
    def __str__(self):
        return self.name

# inventory
class item_description(models.Model):
    item_id = models.CharField(max_length=20, unique=True, primary_key=True)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE, null=True, blank=True)
    item_name = models.CharField(max_length=45, null=True, blank=True)
    itemType = models.ForeignKey('item_types', on_delete=models.SET_NULL, null=True, blank=True)
    alert_qty = models.IntegerField(null=True, blank=True)
    add_cols = models.CharField(max_length=45, null=True, blank=True)
    rec_expiration = models.BooleanField(default=False)
    is_disabled = models.BooleanField(default=False)
    allow_borrow = models.BooleanField(default=False)
    is_consumable = models.BooleanField(default=False)
    qty_limit = models.IntegerField(null=True, blank=True) #for the borrowing_config, to set qty limit to each item.
    
    def save(self, *args, **kwargs):
        if not self.item_id:
            current_year = datetime.now().year
            while True:
                random_number = get_random_string(length=4, allowed_chars='0123456789')
                self.item_id = f"101{current_year}{random_number}"
                if not item_description.objects.filter(item_id=self.item_id).exists():
                    break
        super().save(*args, **kwargs)

    def __str__(self):
        return self.item_name

class item_types(models.Model):
    itemType_id = models.AutoField(primary_key=True)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)  # Implicitly creates a laboratory_id field
    itemType_name = models.CharField(max_length=45, null=True, blank=True)
    add_cols = models.TextField(default='[]')  # Stores JSON attributes
    is_consumable = models.BooleanField(default=False)

    def __str__(self):
        return self.itemType_name

class item_inventory(models.Model):
    inventory_item_id = models.CharField(max_length=20, primary_key=True, editable=False)
    item = models.ForeignKey('item_description', on_delete=models.CASCADE)
    supplier = models.ForeignKey('suppliers', on_delete=models.SET_NULL, null=True, blank=True)
    date_purchased = models.DateTimeField(null=True, blank=True)
    date_received = models.DateTimeField(null=True, blank=True)
    purchase_price = models.FloatField(null=True, blank=True)
    remarks = models.CharField(max_length=45, null=True, blank=True)
    qty = models.IntegerField()

    def save(self, *args, **kwargs):
        if not self.inventory_item_id:
            item_id = self.item.item_id  # Use the item_id from item_description
            prefix = f"102{item_id}"
            last_item = item_inventory.objects.filter(inventory_item_id__startswith=prefix).order_by('inventory_item_id').last()
            if last_item:
                last_id = int(last_item.inventory_item_id[len(prefix):])
                new_id = f"{prefix}{last_id + 1:04d}"
            else:
                new_id = f"{prefix}0001"
            self.inventory_item_id = new_id
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Inventory Item {self.inventory_item_id}"

class item_handling(models.Model):
    item_handling_id = models.AutoField(primary_key=True)
    inventory_item = models.ForeignKey('item_inventory', on_delete=models.SET_NULL, null=True, blank=True)
    timestamp = models.DateTimeField(null=True, blank=True, auto_now_add=True)
    updated_by = models.ForeignKey('User', on_delete=models.SET_NULL, null=True, blank=True)
    changes = models.CharField(max_length=1) # 'A' for add, 'R' for remove
    qty = models.IntegerField()
    remarks = models.CharField(max_length=45, null=True, blank=True)
    # action = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return f"Item Handling {self.item_handling_id}"
    
class item_expirations(models.Model):
    inventory_item = models.ForeignKey('item_inventory', on_delete=models.CASCADE, primary_key=True)
    expired_date = models.DateField()

    def __str__(self):
        return f"Expiration for Inventory Item {self.inventory_item_id}"

class suppliers(models.Model):
    suppliers_id = models.CharField(max_length=20, unique=True, primary_key=True)
    supplier_name = models.CharField(max_length=45)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)
    contact_person = models.CharField(max_length=45, null=True, blank=True)
    contact_number = models.IntegerField(null=True, blank=True)
    email = models.EmailField(null=True, blank=True, unique=True)
    description = models.CharField(max_length=45, null=True, blank=True)
    is_disabled = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        if not self.suppliers_id:
            current_year = datetime.now().year
            while True:
                random_number = get_random_string(length=4, allowed_chars='0123456789')
                self.suppliers_id = f"102{current_year}{random_number}"
                if not suppliers.objects.filter(suppliers_id=self.suppliers_id).exists():
                    break
        super().save(*args, **kwargs)

    def __str__(self):
        return self.suppliername
    

# borrowing & Clearance
class borrowing_config(models.Model):
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE, primary_key=True)
    
    allow_walkin = models.BooleanField(default=False)
    allow_prebook = models.BooleanField(default=False)
    prebook_lead_time = models.IntegerField(default=0)
    allow_shortterm = models.BooleanField(default=True)
    allow_longterm = models.BooleanField(default=True)
    
    # Questions config as JSON
    questions_config = models.JSONField(default=list)  # Should always be a list

    def add_question(self, question_text, input_type, borrowing_mode, dropdown_choices=None):
        # Ensure that questions_config is a list
        if not isinstance(self.questions_config, list):
            self.questions_config = []

        new_question = {
            'question_text': question_text,
            'input_type': input_type,
            'borrowing_mode': borrowing_mode,
            'choices': dropdown_choices if dropdown_choices else []
        }
        self.questions_config.append(new_question)
        self.save()

    def update_question(self, index, question_text, input_type, borrowing_mode, dropdown_choices=None):
        if not isinstance(self.questions_config, list):
            self.questions_config = []

        if 0 <= index < len(self.questions_config):
            self.questions_config[index] = {
                'question_text': question_text,
                'input_type': input_type,
                'borrowing_mode': borrowing_mode,
                'choices': dropdown_choices if dropdown_choices else []
            }
            self.save()

    def remove_question(self, index):
        if not isinstance(self.questions_config, list):
            self.questions_config = []

        if 0 <= index < len(self.questions_config):
            del self.questions_config[index]
            self.save()

    def get_questions(self, mode=None):
        if not isinstance(self.questions_config, list):
            self.questions_config = []

        if mode:
            return [q for q in self.questions_config if q['borrowing_mode'] == mode or q['borrowing_mode'] == 'both']
        return self.questions_config

    def __str__(self):
        return str(self.laboratory)
    
class borrow_info(models.Model):
    borrow_id = models.CharField(max_length=20, unique=True, primary_key=True)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)
    user = models.ForeignKey('user', on_delete=models.SET_NULL, null=True, blank=True, related_name='borrowed_by')
    request_date = models.DateTimeField(null=True, blank=True)
    borrow_date = models.DateField(null=True, blank=True)
    due_date = models.DateField(null=True, blank=True)
    # class_id = models.ForeignKey('Class', on_delete=models.SET_NULL, null=True, blank=True)
    # faculty_id = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='faculty')
    status = models.CharField(max_length=1, null=True, blank=True)
    approved_by = models.ForeignKey('user', on_delete=models.SET_NULL, null=True, blank=True)
    questions_responses = models.JSONField(default=dict, blank=True)
    remarks = models.CharField(max_length=45, null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.borrow_id:
            current_year = datetime.now().year
            while True:
                random_number = get_random_string(length=4, allowed_chars='0123456789')
                self.borrow_id = f"201{current_year}{random_number}"
                if not borrow_info.objects.filter(borrow_id=self.borrow_id).exists():
                    break
        super().save(*args, **kwargs)
    
    def __str__(self):
        return f"Borrow Info {self.borrow_id}"
    
    def get_status_display(self):
        status_mapping = {
            'P': 'Pending',
            'A': 'Approved',
            'D': 'Declined',
            'B': 'Borrowed',
            'C': 'Cancelled',
            'L': 'Cancelled', #cancelled by lab tech
            'X': 'Completed',
            'Y': 'Clearance On-hold'
        }
        return status_mapping.get(self.status, 'Unknown')

class borrowed_items(models.Model):
    borrow = models.ForeignKey('borrow_info', on_delete=models.CASCADE)
    item = models.ForeignKey('item_description', on_delete=models.CASCADE)
    qty = models.IntegerField(null=True, blank=True)
    unit = models.CharField(max_length=20, null=True, blank=True)
    returned_qty = models.IntegerField(default=0)
    remarks = models.CharField(max_length=1, null=True, blank=True)

    class Meta:
        unique_together = (('borrow', 'item'),)

    def __str__(self):
        return f"Borrowed Item {self.borrow_id} - {self.item_id}"

class reported_items(models.Model): 
    report_id = models.CharField(max_length=20, unique=True, primary_key=True)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)
    borrow = models.ForeignKey('borrow_info', on_delete=models.CASCADE, null=True, blank=True)
    user = models.ForeignKey('user', on_delete=models.CASCADE, null=True, blank=True)  # Add this line
    item = models.ForeignKey('item_description', on_delete=models.CASCADE, null=True, blank=True)
    qty_reported = models.IntegerField(null=False, blank=False)
    report_reason = models.CharField(max_length=255)
    amount_to_pay = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    reported_date = models.DateTimeField(auto_now_add=True)
    remarks = models.TextField(null=True, blank=True)

    def save(self, *args, **kwargs):
            if not self.report_id:
                last_report = reported_items.objects.all().order_by('report_id').last()
                new_report_id = int(last_report.report_id) + 1 if last_report else 1001
                self.report_id = str(new_report_id)
            super().save(*args, **kwargs)

    # Add a status field with choices for Pending (1) and Cleared (0)
    STATUS_CHOICES = [
        (1, 'Pending'),
        (0, 'Cleared'),
    ]
    status = models.IntegerField(choices=STATUS_CHOICES, default=1)  # Default to Pending

    def __str__(self):
        return f"Reported {self.item.item_name} for Borrow {self.borrow.borrow_id}"


# Lab Reservation
class laboratory_reservations(models.Model):
    reservation_id = models.CharField(max_length=20, unique=True, primary_key=True)
    user = models.ForeignKey('User', on_delete=models.SET_NULL, null=True, blank=True, related_name='user')
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)
    room = models.ForeignKey('rooms', on_delete=models.SET_NULL, null=True, blank=True, related_name='reservations')
    request_date = models.DateTimeField(auto_now_add=True)
    start_date = models.DateField(null=True, blank=True)
    start_time = models.TimeField(null=True, blank=True)
    end_time = models.TimeField(null=True, blank=True)
    status = models.CharField(max_length=1, default='P')  # Pending by default
    purpose = models.CharField(max_length=255, null=True, blank=True)
    num_people = models.IntegerField(null=True, blank=True)
    contact_email = models.EmailField(null=True, blank=True)
    contact_name = models.CharField(max_length=255, null=True, blank=True)
    filled_approval_form = models.FileField(upload_to='filled_approval_forms/', null=True, blank=True)

    def save(self, *args, **kwargs):
        if not self.reservation_id:
            current_year = datetime.now().year
            while True:
                random_number = get_random_string(length=4, allowed_chars='0123456789')
                self.reservation_id = f"401{current_year}{random_number}"
                if not laboratory_reservations.objects.filter(reservation_id=self.reservation_id).exists():
                    break
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Reservation {self.reservation_id}"
    
    def get_status_display(self):
        status_mapping = {
            'P': 'Pending',
            'A': 'Approved',
            'D': 'Declined',
            'R': 'Reserved',
            'C': 'Cancelled',
        }
        return status_mapping.get(self.status, 'Unknown')

class reservation_config(models.Model):
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)
    reservation_type = models.CharField(max_length=10, choices=[('class', 'Class Time'), ('hourly', 'Hourly')], default='class')
    start_time = models.TimeField(null=True, blank=True)  # For hourly reservation
    end_time = models.TimeField(null=True, blank=True)  # For hourly reservation
    require_approval = models.BooleanField(default=False)
    require_payment = models.BooleanField(default=False)
    approval_form = models.FileField(upload_to='approval_forms/', null=True, blank=True)  # Optional PDF upload
    tc_description = models.TextField(null=True, blank=True)  # Description for terms and conditions
    leadtime = models.PositiveIntegerField(default=0)
