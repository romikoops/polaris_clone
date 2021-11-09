.. _table_column:

ExcelDataServices::V2::Files::Tables::Column
============================================

   Here we define a column in the data we want to work with. A Column
   will represent one column in the XLSX sheet provided.

   The purpose of this class is to identify the column on the XLSX sheet
   that matches the header (or the alternative keys) and build a
   CellParser for each cell in the table column.

   The Column class is then responsible for collating errors and the
   sanitized and validated column data from the CellParser to build a
   DataFrame.

+-----------------------+-----------------------+-----------------------+
| Key                   | Value                 | Description           |
+=======================+=======================+=======================+
| sanitizer             | string                | lowercase version of  |
|                       |                       | the Sanitizer class   |
|                       |                       | eg string.            |
|                       |                       |                       |
|                       |                       | All content is        |
|                       |                       | sanitized at the      |
|                       |                       | point of extraction   |
+-----------------------+-----------------------+-----------------------+
| validator             | string                | lowercase version of  |
|                       |                       | the Sanitizer class   |
|                       |                       | eg \`decimal\`        |
|                       |                       |                       |
|                       |                       | All content is        |
|                       |                       | validated at the      |
|                       |                       | point of extraction   |
+-----------------------+-----------------------+-----------------------+
| alternative_keys      | Array of strings      | While the Column name |
|                       |                       | is the header, the    |
|                       |                       | data could be under   |
|                       |                       | different keys in     |
|                       |                       | different sheets. eg  |
|                       |                       | FEE_CODE and CODE are |
|                       |                       | the same in different |
|                       |                       | sheets.               |
|                       |                       |                       |
|                       |                       | Makes it easier to    |
|                       |                       | upgrade sheets and    |
|                       |                       | avoid renaming        |
|                       |                       | attributes down the   |
|                       |                       | process               |
+-----------------------+-----------------------+-----------------------+
| required              | boolean               | Whether or not all    |
|                       |                       | cells must have       |
|                       |                       | content in order to   |
|                       |                       | be valid              |
+-----------------------+-----------------------+-----------------------+
| unique                | boolean               | Whether all content   |
|                       |                       | must be unique        |
+-----------------------+-----------------------+-----------------------+
| fallback              | Any valid ruby        | Usually a string but  |
|                       | expression available  | can be Organization’s |
|                       | in the context of the | slug                  |
|                       | SheetParser class     |                       |
+-----------------------+-----------------------+-----------------------+
