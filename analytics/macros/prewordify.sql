{% macro prewordify(text) -%}
{{ text | lower | replace(' ', '_')}}
{%- endmacro %}