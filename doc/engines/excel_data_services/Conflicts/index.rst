.. _overlaps:

ExcelDataServices::V2::Files::Conflict
======================================

Many tables have unique constraints that are determined by validity
periods and have safeguards to prevent any overlapping, otherwise
identical, rates can be inserted. To achieve this we have the Conflict
class. This class is called from the DSL with the model in question and the
keys that are used to determine the unique constraint (excluding the
date keys, EFFECTIVE_DATE and EXPIRATION_DATE)

The Conflict class will trigger the V2::Overlaps::Resolver class to
detect and adjust the existing data using SQL executions

+----------------------+----------------------+----------------------+
| Argument             | Value                | Description          |
+======================+======================+======================+
| model                | ActiveRecord Model   | The model of the     |
|                      |                      | record that will be  |
|                      |                      | inserted, the parent |
|                      |                      | of the nested        |
|                      |                      | relations.           |
+----------------------+----------------------+----------------------+
| keys                 | Array of Hashes      | Array of records     |
|                      |                      | ready for insertion  |
|                      |                      | and already          |
|                      |                      | formatted to have    |
|                      |                      | their nested         |
|                      |                      | attributes present   |
+----------------------+----------------------+----------------------+
