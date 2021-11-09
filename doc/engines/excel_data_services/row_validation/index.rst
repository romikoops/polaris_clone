.. _row_validation:

ExcelDataServices::V2::Files::RowValidation
===========================================

While the pipelines are built around columns, there are times when we
need to validate info in the context of the row. This class allows
simple validations to be executed on the data frame after we have built
it.

The class takes arguments of the keys (under which the values we are
looking for can be found in the row), a proc to handle the comparison
logic and an optional message to be returned in case of the validation
failing.

+----------------------+----------------------+----------------------+
| Argument             | Value                | Description          |
+======================+======================+======================+
| keys                 | Array of strings     | The values we want   |
|                      |                      | to pluck from the    |
|                      |                      | row for use in the   |
|                      |                      | Proc                 |
+----------------------+----------------------+----------------------+
| comparator           | Proc                 | Proc that takes the  |
|                      |                      | same number of       |
|                      |                      | arguments as strings |
|                      |                      | defined in the keys  |
|                      |                      | argument. Must       |
|                      |                      | return a boolean     |
|                      |                      | value.               |
+----------------------+----------------------+----------------------+
| message              | String               | Optional: Override   |
|                      |                      | default generated    |
|                      |                      | message if           |
|                      |                      | validation fails     |
+----------------------+----------------------+----------------------+
