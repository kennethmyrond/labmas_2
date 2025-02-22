from django import forms
from django.contrib.auth.forms import AuthenticationForm
from .models import ShoppingItem

class LoginForm(AuthenticationForm):
    username = forms.CharField(max_length=254, widget=forms.TextInput(attrs={'placeholder': 'Username'}))
    password = forms.CharField(widget=forms.PasswordInput(attrs={'placeholder': 'Password'}))


from .models import laboratory, Module

class LaboratoryForm(forms.ModelForm):
    module_choices = forms.ModelMultipleChoiceField(
        queryset=Module.objects.all(),
        widget=forms.CheckboxSelectMultiple,
        required=False
    )

    class Meta:
        model = laboratory
        fields = ['name', 'description']  # Exclude module_choices here

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Optionally, customize the labels for better display
        self.fields['module_choices'].label = 'Select Modules'


from .models import Module

class ModuleForm(forms.ModelForm):
    class Meta:
        model = Module
        fields = ['name', 'enabled']
        widgets = {
            'enabled': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }

class InventoryItemForm(forms.Form):
    item_name = forms.CharField(max_length=45, required=True)
    item_type = forms.CharField(max_length=45, required=True)
    amount = forms.FloatField(required=True)
    dimension = forms.CharField(max_length=10, required=True)
    nature = forms.CharField(max_length=45, required=True)
    grade = forms.CharField(max_length=45, required=True)
    location = forms.CharField(max_length=45, required=True)
    kind = forms.CharField(max_length=45, required=True)

class ShoppingItemForm(forms.ModelForm):
    class Meta:
        model = ShoppingItem
        fields = ['name', 'description', 'quantity']