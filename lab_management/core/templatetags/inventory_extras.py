from django import template
import json

register = template.Library()

@register.filter
def get_col_value(add_cols_json, col_name):
    try:
        add_cols = json.loads(add_cols_json)
        return add_cols.get(col_name, "")
    except (ValueError, TypeError):
        return ""
