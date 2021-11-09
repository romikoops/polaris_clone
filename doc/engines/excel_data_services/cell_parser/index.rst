ExcelDataServices::V2::Files::Tables::CellParser
================================================

This is a wrapper around the cell in the XLSX. This class takes its
sanitizer and validator context from the Tables::Column as a whole.

When the \`value\` method is called the CellParser will take the
provided input and run it first through the sanitizer, then the defined
validator. If the validator fails a V2::Error will be available under
the method \`error`. If it succeeds the sanitized and validated value
will be returned. If no value is found and a fallback value is provided
in the Tables::Column options, that value will be returned.

+----------------------+----------------------+----------------------+
| Argument             | Value                | Description          |
+======================+======================+======================+
| column               | Tables::Column       | Tables::Column       |
|                      |                      | parent of the        |
|                      |                      | CellParser class.    |
|                      |                      | Provides sanitizer   |
|                      |                      | and validator        |
|                      |                      | context.             |
+----------------------+----------------------+----------------------+
| input                | String, Integer,     | Value returned from  |
|                      | NilClass, Decimal,   | Roo::ExcelxMoney     |
|                      | Boolean, Money       |                      |
+----------------------+----------------------+----------------------+
| row                  | Integer              | What row in the      |
|                      |                      | column this value    |
|                      |                      | came from            |
+----------------------+----------------------+----------------------+
