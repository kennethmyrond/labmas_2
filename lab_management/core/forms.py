from django import forms
from django.contrib.auth.forms import AuthenticationForm

class LoginForm(AuthenticationForm):
    username = forms.CharField(max_length=254, widget=forms.TextInput(attrs={'placeholder': 'Username'}))
    password = forms.CharField(widget=forms.PasswordInput(attrs={'placeholder': 'Password'}))



from django import forms
from .models import Laboratory, Module

class LaboratoryForm(forms.ModelForm):
    module_choices = forms.ModelMultipleChoiceField(
        queryset=Module.objects.all(),
        widget=forms.CheckboxSelectMultiple,
        required=False
    )

    class Meta:
        model = Laboratory
        fields = ['name', 'description']  # Exclude module_choices here

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Optionally, customize the labels for better display
        self.fields['module_choices'].label = 'Select Modules'



from django import forms
from .models import Module

class ModuleForm(forms.ModelForm):
    class Meta:
        model = Module
        fields = ['name', 'enabled']
        widgets = {
            'enabled': forms.CheckboxInput(attrs={'class': 'form-check-input'}),
        }

