import json, qrcode
from django.contrib.auth.models import User
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
from io import BytesIO
from django.core.files import File
from PIL import Image, ImageDraw

class laboratory(models.Model):
    laboratory_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=45, null=True, blank=True)
    description = models.CharField(max_length=45, null=True, blank=True)
    department = models.CharField(max_length=45, null=True, blank=True)
    is_available = models.BooleanField(default=True)

class role(models.Model):
    roles_id = models.AutoField(primary_key=True)
    laboratory = models.ForeignKey(laboratory, on_delete=models.CASCADE)  # ForeignKey to Laboratory
    name = models.CharField(max_length=45, null=True, blank=True)
    permissions = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return self.name

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

# class user(AbstractBaseUser):
#     user = models.OneToOneField(User, on_delete=models.CASCADE)
#     role = models.ForeignKey(role, null=True, blank=True, on_delete=models.SET_NULL)  # ForeignKey to Role
#     is_deactivated = models.BooleanField(default=False)
#     is_guest = models.BooleanField(default=False)

#     is_active = models.BooleanField(default=True)


#     objects = UserManager()

#     USERNAME_FIELD = 'email'
#     REQUIRED_FIELDS = ['firstname', 'lastname']

#     def __str__(self):
#         return self.email

class user(AbstractBaseUser):
    user_id = models.AutoField(primary_key=True)
    firstname = models.CharField(max_length=45, null=True, blank=True)
    lastname = models.CharField(max_length=45, null=True, blank=True)
    email = models.EmailField(unique=True)
    role = models.ForeignKey(role, null=True, blank=True, on_delete=models.SET_NULL)  # ForeignKey to Role
    is_deactivated = models.BooleanField(default=False)
    is_guest = models.BooleanField(default=False)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['firstname', 'lastname']

    def __str__(self):
        return self.email

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


# class UserProfile(models.Model):
#     USER_ROLES = [
#         ('superuser', 'Superuser'),
#         ('lab_admin', 'Lab Admin'),
#         ('personnel', 'Lab Personnel'),
#         ('guest', 'Guest'),
#     ]
#     user = models.OneToOneField(User, on_delete=models.CASCADE)
#     role = models.CharField(max_length=50, choices=USER_ROLES)
#     laboratory = models.ForeignKey(laboratory, on_delete=models.CASCADE, null=True, blank=True)

#     def __str__(self):
#         return self.user.username



# inventory
class item_description(models.Model):
    item_id = models.AutoField(primary_key=True)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE, null=True, blank=True)
    item_name = models.CharField(max_length=45, null=True, blank=True)
    itemType = models.ForeignKey('item_types', on_delete=models.SET_NULL, null=True, blank=True)
    amount = models.FloatField(null=True, blank=True)
    dimension = models.CharField(max_length=10, null=True, blank=True)
    # qty = models.IntegerField()
    alert_qty = models.IntegerField(null=True, blank=True)
    add_cols = models.CharField(max_length=45, null=True, blank=True)
    rec_expiration = models.BooleanField(default=False)
    is_disabled = models.BooleanField(default=False)
    
    def __str__(self):
        return self.item_name

class item_types(models.Model):
    itemType_id = models.AutoField(primary_key=True)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)  # Implicitly creates a laboratory_id field
    itemType_name = models.CharField(max_length=45, null=True, blank=True)
    add_cols = models.TextField(default='[]')  # Stores JSON attributes

    def __str__(self):
        return self.itemType_name

class item_inventory(models.Model):
    inventory_item_id = models.AutoField(primary_key=True)
    item = models.ForeignKey('item_description', on_delete=models.CASCADE)
    supplier = models.ForeignKey('suppliers', on_delete=models.SET_NULL, null=True, blank=True)
    date_purchased = models.DateTimeField(null=True, blank=True)
    date_received = models.DateTimeField(null=True, blank=True)
    purchase_price = models.FloatField(null=True, blank=True)
    remarks = models.CharField(max_length=45, null=True, blank=True)
    qty = models.IntegerField()
    
    def __str__(self):
        return f"Inventory Item {self.inventory_item_id}"

class item_handling(models.Model):
    item_handling_id = models.AutoField(primary_key=True)
    inventory_item = models.ForeignKey('item_inventory', on_delete=models.SET_NULL, null=True, blank=True)
    updated_on = models.DateTimeField(null=True, blank=True)
    updated_by = models.ForeignKey('User', on_delete=models.SET_NULL, null=True, blank=True)
    changes = models.CharField(max_length=1) # 'A' for add, 'R' for remove
    qty = models.IntegerField()
    # action = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return f"Item Handling {self.item_handling_id}"
    
class item_expirations(models.Model):
    inventory_item = models.ForeignKey('item_inventory', on_delete=models.CASCADE)
    expired_date = models.DateField(primary_key=True)

    def __str__(self):
        return f"Expiration for Inventory Item {self.inventory_item_id}"

class suppliers(models.Model):
    suppliers_id = models.AutoField(primary_key=True)
    supplier_name = models.CharField(max_length=45)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)
    contactPerson = models.CharField(max_length=45, null=True, blank=True)
    address = models.CharField(max_length=45, null=True, blank=True)
    description = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return self.suppliername
    
# class item_remove_inventory(models.Model):
#     inventory_item_id = models.AutoField(primary_key=True)
#     remarks = models.CharField(max_length=45, null=True, blank=True)
#     end_username = models.ForeignKey('User', on_delete=models.SET_NULL, null=True, blank=True)
#     end_userreason = models.CharField(max_length=45, null=True, blank=True)

class item_transactions(models.Model): 
    transaction_id = models.AutoField(primary_key=True)
    user = models.ForeignKey('user', on_delete=models.SET_NULL, null=True, blank=True)
    timestamp = models.DateTimeField(null=True, blank=True)
    remarks = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return f"Transaction {self.transaction_id}"


# borrowing
class borrow_info(models.Model):
    borrow_id = models.AutoField(primary_key=True)
    laboratory = models.ForeignKey('Laboratory', on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='borrowed_by')
    request_date = models.DateTimeField(null=True, blank=True)
    borrow_date = models.DateField(null=True, blank=True)
    due_date = models.DateField(null=True, blank=True)
    # class_id = models.ForeignKey('Class', on_delete=models.SET_NULL, null=True, blank=True)
    # faculty_id = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='faculty')
    status = models.CharField(max_length=1, null=True, blank=True)

    def __str__(self):
        return f"Borrow Info {self.borrow_id}"

class borrowed_items(models.Model):
    borrow = models.ForeignKey('borrow_info', on_delete=models.CASCADE)
    item = models.ForeignKey('item_description', on_delete=models.CASCADE)
    qty = models.IntegerField(null=True, blank=True)

    class Meta:
        unique_together = (('borrow', 'item'),)

    def __str__(self):
        return f"Borrowed Item {self.borrow_id} - {self.item_id}"

