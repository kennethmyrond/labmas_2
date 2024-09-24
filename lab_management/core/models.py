import json
from django.contrib.auth.models import User
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

class laboratory(models.Model):
    laboratory_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=45, null=True, blank=True)
    description = models.CharField(max_length=45, null=True, blank=True)
    department = models.CharField(max_length=45, null=True, blank=True)
    is_available = models.BooleanField(default=True)

from django.db import models
from django.contrib.auth.models import User

# class laboratory(models.Model):
#     name = models.CharField(max_length=100)
#     description = models.TextField()
#     modules = models.ManyToManyField('Module')  # Use Many-to-Many relationship for modules

#     def __str__(self):
#         return self.name

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
    add_cols = models.CharField(max_length=45, null=True, blank=True)
    alert_Qty = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return self.item_name

class item_handling(models.Model):
    item_handling_id = models.AutoField(primary_key=True)
    inventory_item = models.ForeignKey('item_inventory', on_delete=models.SET_NULL, null=True, blank=True)
    updatedon = models.DateTimeField(null=True, blank=True)
    updatedby = models.ForeignKey('User', on_delete=models.SET_NULL, null=True, blank=True)
    changes = models.CharField(max_length=1, null=True, blank=True)
    qty = models.IntegerField(null=True, blank=True)
    action = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return f"Item Handling {self.item_handling_id}"

class item_transactions(models.Model):
    transaction_id = models.AutoField(primary_key=True)
    user = models.ForeignKey('User', on_delete=models.SET_NULL, null=True, blank=True)
    timestamp = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Transaction {self.transaction_id}"

class item_types(models.Model):
    itemType_id = models.AutoField(primary_key=True)
    laboratory_id = models.CharField(max_length=45, null=True, blank=True)  # Since it's a VARCHAR
    itemType_name = models.CharField(max_length=45, null=True, blank=True)
    add_cols = models.CharField(max_length=45, null=True, blank=True)

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
    transaction = models.ForeignKey('item_transactions', on_delete=models.SET_NULL, null=True, blank=True)
    qty = models.IntegerField()  # Quantity; required field
    
    def __str__(self):
        return f"Inventory Item {self.inventory_item_id}"

class suppliers(models.Model):
    suppliers_id = models.AutoField(primary_key=True)
    suppliername = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return self.suppliername


