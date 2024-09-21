import json
from django.contrib.auth.models import User
from django.db import models

class laboratory(models.Model):
    laboratory_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=45, null=True, blank=True)
    description = models.CharField(max_length=45, null=True, blank=True)
    department = models.CharField(max_length=45, null=True, blank=True)
    is_available = models.BooleanField(default=True)

from django.db import models
from django.contrib.auth.models import User

class laboratory(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    modules = models.ManyToManyField('Module')  # Use Many-to-Many relationship for modules

    def __str__(self):
        return self.name

class role(models.Model):
    roles_id = models.AutoField(primary_key=True)
    laboratory = models.ForeignKey(laboratory, on_delete=models.CASCADE)  # ForeignKey to Laboratory
    name = models.CharField(max_length=45, null=True, blank=True)
    permissions = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return self.name


from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

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


class UserProfile(models.Model):
    USER_ROLES = [
        ('superuser', 'Superuser'),
        ('lab_admin', 'Lab Admin'),
        ('personnel', 'Lab Personnel'),
        ('guest', 'Guest'),
    ]
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=50, choices=USER_ROLES)
    laboratory = models.ForeignKey(laboratory, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.user.username

