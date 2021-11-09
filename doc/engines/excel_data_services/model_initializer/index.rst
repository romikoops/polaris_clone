.. _model_initializer:

ExcelDataServices::V2::ModelInitializer
=======================================

In order for our import to achieve nested insertion we have to
initialise the models prior to inserting them, with their dependent
records nested under the association keys. A good example of this is
initializing the Pricings::Fee’s and playing them under the ‘fees’
attribute of the Pricings::Pricing.

The class is triggered internally by the Import class and requires the
primary model being inserted and an array of data already formatted into
the nested shape.

The class will access the primary model and determine the available
relations and see if any attributes in the hash structure matches any of
those keys and begin a recursive call of itself, initializing all nested
attributes for each record.

+----------------------+----------------------+----------------------+
| Argument             | Value                | Description          |
+======================+======================+======================+
| model                | ActiveRecord Model   | The model of the     |
|                      |                      | record that will be  |
|                      |                      | inserted, the parent |
|                      |                      | of the nested        |
|                      |                      | relations.           |
+----------------------+----------------------+----------------------+
| data                 | Array of Hashes      | Array of records     |
|                      |                      | ready for insertion  |
|                      |                      | and already          |
|                      |                      | formatted to have    |
|                      |                      | their nested         |
|                      |                      | attributes present   |
+----------------------+----------------------+----------------------+
