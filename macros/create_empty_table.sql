
{% macro create_empty_table
(table_name, columns) %}
  {%
set sql
%}
CREATE TABLE
IF NOT EXISTS {{ target.schema }}.{{ table_name }}
(
      {{ columns | join
(', ') }}
    );
  {% endset %}

  {{ run_query
(sql) }}
{% endmacro %}
