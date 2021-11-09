ExcelDataServices::V2::Files::Section
=====================================

The `Section` class is one of the core classes involved in making the
pipeline run.

A Section is initialized with a string matching the file name of the DSL
file located in the section_data folder. This will take the schema and
parse it using the SheetParser class to build up a complete collection
of Extractors, Operations, Formatters, Validations (collectively known
as ConnectedActions)and data in the form of Tables::Sheets,
Table::Columns and Tables::CellParsers.

Using the Tables Module classes we can build our initial DataFrame that
holds our sanitized and validated data and store it under the \`data\`
class method. Specifically, one Tables::Sheet object will be created for
each sheet in the xlsx file. That Tables::Sheet object will build one
Tables::Column for each defined in the DSL, as well as any
DynamicColumns detected). Each Column produces a DataFrame with the
value, row and sheet name allowing us to combine them easily into one
large frame.

If any cells contain invalid content (as defined by the validator,
required and unique options) and error will be added to the State object
and the process will exit.

Now we have full DataFrame, the Section will iterate through the
ConnectedActions provided from the SheetParser and execute them in the
correct order (determined by examining the prerequisite relations
between the different Sections)

If any of the ConnectedActions encounters an error, for example the
Extractor fails to find an appropriate record for a row, it will append
the errors to the State and the pipeline will exit.

If a ModelImporter is defined on the DSL, the Section will trigger
import the data so that the next ConnectedAction is able to extract the
recently inserted data.

At the end of the process the Stats objects for each dependent Section
are collected, and returned along with the primary Section’s to the SheetType
class.

+----------------------+----------------------+----------------------+
| Method               | Response             | Description          |
+======================+======================+======================+
| valid?               | boolean              | A Section is valid   |
|                      |                      | if all sheets meet   |
|                      |                      | the criteria         |
|                      |                      | specified in the     |
|                      |                      | Requirements, all    |
|                      |                      | Columns marked as    |
|                      |                      | required are present |
|                      |                      | and no errors have   |
|                      |                      | been collected from  |
|                      |                      | the individual       |
|                      |                      | Tables::Sheet        |
|                      |                      | objects              |
+----------------------+----------------------+----------------------+
| errors               | V2::Error            | Hold the information |
|                      |                      | describing the Error |
|                      |                      | and the location of  |
|                      |                      | the offending data   |
+----------------------+----------------------+----------------------+
