
ExcelDataServices::V2::Files::Tables::Matrix
============================================

   Matrix's exist to extract grids of data from a sheet in order for a Framer class to consume.
   Each cell is extracted with its Sheet, row and column coordinates. The class takes all the
   options that a Column accepts and every value parsed is sanitized and validated.

   The class is initialised with a `header` a set of `rows` and `columns`.

+-------------------+------------------------+-------------------------+
| Key               | Value                  | Description             |
+===================+========================+=========================+
|| header           || string                || The header used to     |
||                  ||                       || identify the value     |
||                  ||                       || in the resulting table |
+-------------------+------------------------+-------------------------+
|| rows             || string                || The rows to be parsed. |
||                  ||                       || Format: "Start:End"    |
||                  ||                       || eg: "1:4", "1", "1:?"  |
+-------------------+------------------------+-------------------------+
|| columns          || string                || The columns to be read |
||                  ||                       || Format: "Start:End"    |
||                  ||                       || eg: "1:4", "1", "1:?"  |
+-------------------+------------------------+-------------------------+
|| sanitizer        || string                || lowercase version of   |
||                  ||                       || the Sanitizer class    |
||                  ||                       || eg string.             |
||                  ||                       ||                        |
||                  ||                       || All content is         |
||                  ||                       || sanitized at the       |
||                  ||                       || point of extraction    |
+-------------------+------------------------+-------------------------+
|| validator        || string                || lowercase version of   |
||                  ||                       || the Sanitizer class    |
||                  ||                       || eg \`decimal\`         |
||                  ||                       ||                        |
||                  ||                       || All content is         |
||                  ||                       || validated at the       |
||                  ||                       || point of extraction    |
+-------------------+------------------------+-------------------------+
|| alternative_keys || Array of strings      || While the Column name  |
||                  ||                       || is the header, the     |
||                  ||                       || data could be under    |
||                  ||                       || different keys in      |
||                  ||                       || different sheets. eg   |
||                  ||                       || FEE_CODE and CODE are  |
||                  ||                       || the same in different  |
||                  ||                       || sheets.                |
||                  ||                       ||                        |
||                  ||                       || Makes it easier to     |
||                  ||                       || upgrade sheets and     |
||                  ||                       || avoid renaming         |
||                  ||                       || attributes down the    |
||                  ||                       || process                |
+-------------------+------------------------+-------------------------+
|| required         || boolean               || Whether or not all     |
||                  ||                       || cells must have        |
||                  ||                       || content in order to    |
||                  ||                       || be valid               |
+-------------------+------------------------+-------------------------+
|| unique           || boolean               || Whether all content    |
||                  ||                       || must be unique         |
+-------------------+------------------------+-------------------------+
|| fallback         || Any valid ruby        || Usually a string but   |
||                  || expression available  || can be Organization’s  |
||                  || in the context of the || slug                   |
||                  || SheetParser class     ||                        |
+-------------------+------------------------+-------------------------+
