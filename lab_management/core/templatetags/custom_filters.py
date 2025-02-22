import base64, json
from django import template

register = template.Library()

@register.filter
def has_inventory_permissions(permissions):
    return (permissions.can_view_inventory or
            permissions.can_add_new_item or
            permissions.can_update_item_inventory or
            permissions.can_physical_count or
            permissions.can_manage_suppliers or
            permissions.can_configure_inventory)

@register.filter(name='b64encode')
def b64encode(value):
    """Encodes image or binary data into base64 for embedding in HTML."""
    return base64.b64encode(value).decode('utf-8')

@register.filter
def dict_lookup(dictionary, key):
    return dictionary.get(key, [])

@register.filter
def clean_label(label):
    """Split by '(' and return the stripped first part."""
    return label.split('(')[0].strip()

@register.filter
def add(value, arg):
    # Ensure both value and arg are treated as integers
    try:
        return int(value) + int(arg)
    except (ValueError, TypeError):
        return value  # Return the original value if conversion fails
    
@register.filter
def dict_key(value, key):
    return value.get(key)

@register.filter
def get_item(dictionary, key):
    return dictionary.get(key)
    

@register.filter
def get_item_report(dictionary, key):
    try:
        return json.loads(dictionary).get(key, '')
    except (ValueError, TypeError):
        return ''
    
@register.filter
def get_value(dictionary, key):
    return dictionary.get(key, '')

@register.filter
def range_filter(value):
    return range(value)

@register.filter
def has_permission(role_permissions, args):
    """
    Check if the role_permissions dictionary has (role_id, perm_codename) as a key.
    """
    role_id, perm_codename = args
    return role_permissions.get((role_id, perm_codename), False)

@register.simple_tag
def create_tuple(role_id, perm_codename):
    return (role_id, perm_codename)


@register.filter
def dict_get(dictionary, key):
    return dictionary.get(key, "No Lead Time Required")


@register.filter
def dict_get(dictionary, key):
    """
    Template filter to safely get a value from a dictionary
    """
    if dictionary is None:
        return None
    return dictionary.get(key)

