import json
from django.db import models
from django.contrib.auth.models import User

class Laboratory(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    modules = models.ManyToManyField('Module')  # Use Many-to-Many relationship for modules

    def __str__(self):
        return self.name

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
    laboratory = models.ForeignKey(Laboratory, on_delete=models.CASCADE, null=True, blank=True)

    def __str__(self):
        return self.user.username

