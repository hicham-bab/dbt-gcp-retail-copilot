{#
    Convert an integer cents column to a dollars NUMERIC value.
    Fusion-safe: uses cast(... as numeric) rather than the :: shorthand.
#}
{% macro cents_to_dollars(column_name, scale=2) -%}
    round(cast({{ column_name }} as numeric) / 100, {{ scale }})
{%- endmacro %}
