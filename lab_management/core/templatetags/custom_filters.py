import base64
from django import template

register = template.Library()

@register.filter(name='b64encode')
def b64encode(value):
    """Encodes image or binary data into base64 for embedding in HTML."""
    return base64.b64encode(value).decode('utf-8')

@register.filter
def add(value, arg):
    return value + arg

@register.filter
def dict_key(value, key):
    return value.get(key)
