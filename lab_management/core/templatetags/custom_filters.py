import base64
from django import template

register = template.Library()

@register.filter(name='b64encode')
def b64encode(value):
    """Encodes image or binary data into base64 for embedding in HTML."""
    return base64.b64encode(value).decode('utf-8')

@register.filter
def add(value, arg):
    if value is None:
        value = 0  # Set a default value if value is None
    return value + arg

@register.filter
def dict_key(value, key):
    return value.get(key)

@register.filter
def get_item(dictionary, key):
    return dictionary.get(key)

@register.filter
def range_filter(value):
    return range(value)