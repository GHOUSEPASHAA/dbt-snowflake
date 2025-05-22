
{% for i in range
(1, 11) %}
  {% do create_empty_table
(
    'new_customers' ~ i,
    [
      'id INT',
      'name STRING',
      'created_at DATE'
    ]
  ) %}
{% endfor %}

-- Required dummy SELECT to make the model valid
SELECT 'created customers1 to customers10 tables' AS result
