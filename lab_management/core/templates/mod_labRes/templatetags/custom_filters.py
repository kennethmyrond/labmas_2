# your_app/templatetags/custom_filters.py
from django import template

register = template.Library()

@register.filter
def add(value, arg):
    return value + arg

@register.filter
def dict_key(value, key):
    return value.get(key)
