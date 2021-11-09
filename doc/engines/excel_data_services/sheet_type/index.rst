.. _sheet_type:

ExcelDataServices::V2::Files::SheetType
=======================================

The SheetType class serves to represent one of the main types of uploads
that we receive.

In the DSL file we define all the "pipelines" we need to run to achieve
all the inserts necessary. A pipeline is an
ExcelDataServices::V2::Files::Section initialised with the XLSX file.
For most uploaders a single pipeline will suffice as Sections
recursively call all the other Sections required to make a successful
insert.

As each Pipeline is run the resulting Stats objects are collected and
returned to the Upload class that called the SheetType.

The SheetType class is initialised with the following arguments:

+----------------------+----------------------+----------------------+
| file                 | The XLSX sheet being |                      |
|                      | uploaded             |                      |
+======================+======================+======================+
| type                 | The type of upload   | Eg Pricings          |
|                      | it is - must match   |                      |
|                      | one of the defined   |                      |
|                      | schemas in file_data |                      |
+----------------------+----------------------+----------------------+
| arguments            | Extra data provided  | { group_id: xxxxxx } |
|                      | to the uploader      |                      |
+----------------------+----------------------+----------------------+

