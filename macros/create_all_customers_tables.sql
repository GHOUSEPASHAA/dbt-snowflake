
{% macro create_all_customers_tables
() %}
  {% for i in range
(1, 11) %}
    {% do create_empty_table
(
      'customers' ~ i,
      [
        'id INT',
        'name STRING',
        'created_at DATE'
      ]
    ) %}
  {% endfor %}
{% endmacro %}
