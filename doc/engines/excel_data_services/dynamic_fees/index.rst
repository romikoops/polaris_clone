.. _dynamic_fees:

ExcelDataServices::V2::Operations::DynamicFees
==============================================

Multiple pricing formats allow for the first half of each row to be used
for identification of routing and services level while the second half
of the row flips the table in order to fit multiple fees, an entire
pricing, on the same row.

The "dynamic columns" IMC pricing format has a very simple
implementation of this where each DynamicColumn’s header represents the
fee_code and name, while the cell represents the rate value.

Then we come to the format known as the "SACO" format. In this format
the column headers hold a lot more information. This information lets us
store data in multiple columns that combine together to form multiple
fees, covering multiple validity periods.

The DynamicFees class serves to turn the values Dynamic marked Columns
into usable data structures later in the upload pipeline.

For example it will turn this:

.. image:: media/image1.png
   :width: 3.17708in
   :height: 0.88542in

into:|image1|

This is achieved by building a class around the Column that parses the
necessary information from the header to determine the function of the
column and how to handle the data within it. Now we are able to connect
related columns together we will combine the data from their cells to
create a table with the attributes we need to continue with the regular
pricings upload process (ie. fee_code, fee_name, rate, currency etc)

Sub Classes:
------------

The process is broken down into sub classes that each manage a certain
step, resulting in a complete DataFrame.

DataColumn:
~~~~~~~~~~~

The data column is a wrapper around the column as you see it in the
Spreadsheet that parses the header to extract context about the cell
data and its relations to the columns around it.

The header is parsed by splitting the text by \`/\` and the pattern is
defined (in order) as:

-  OPERATOR:

   -  CURR_MONTH: Indicates what month the "CURR" fee applies to

   -  NEXT_MONTH: Indicates what month the "NEXT" fee applies to

   -  CURR_FEE: Indicates this is the value for the "CURR" month

   -  NEXT_FEE: Indicates this is the value for the "NEXT" month

   -  INT: Column is for internal use only and should not be persisted

   -  NOTE: Column header is to be used as Note body if cell has a ‘x’ >
      in it

-  CARGO_CLASS: As we are primarily targeting 3 cargo classes we can >
   target different "Pricings" and set different values for the same >
   fee

   -  20: Maps to \`fcl_20\`

   -  40: Maps to both \`fcl_40\` and \`fcl_40_hq\`

-  FEE CODE: The name and code of the fee.

   -  The text is converted to lowercase and used as the code

   -  The text is humanized (swap underscores for spaces and >
      capitalize first letter) to become the fee name (if no >
      ChargeCategroy exists for that fee code already)

These methods are exposed to make grouping easier

+----------------------+----------------------+----------------------+
| Method               | Result Type          | Description          |
+======================+======================+======================+
| fee_code             | string               | Returns the fee_code |
|                      |                      | parsed from the      |
|                      |                      | header               |
+----------------------+----------------------+----------------------+
| fee?                 | boolean              | Column category is   |
|                      |                      | either :month or     |
|                      |                      | :fee                 |
+----------------------+----------------------+----------------------+
| fee_data             | Rover::DataFrame     | Runs each cell in    |
|                      |                      | the Column through   |
|                      |                      | the RowDataExtractor |
|                      |                      | and returns result   |
|                      |                      | in Rover::DataFrame  |
+----------------------+----------------------+----------------------+
| current?             | boolean              | If the category is   |
|                      |                      | :month, does the     |
|                      |                      | header include the   |
|                      |                      | pattern /curr_/?     |
+----------------------+----------------------+----------------------+

RowDataExtractor
~~~~~~~~~~~~~~~~

Each column operates in a one of a few distinct ways and we need to
infer which way to format the result based on inputs from the DataColumn
as well as the cell values themselves.

There are three main formats of responses:

1. Month

   a. .. image:: media/image5.png
         :width: 6.5in
         :height: 0.25in

   b. If the month derived from the cell value lies outside the main >
      effective and expiration dates defined in the sheet the values >
      will be nil allowing for easy filtering out in a later step

2. | Note:
   | > |image2|

3. | Rate
   | > |image3|\ {width="4.854166666666667in" > height="1.3125in"}

FeeFromColumns
~~~~~~~~~~~~~~

Finally once we have our DataColumns grouped by fee_code and period we
can put together the data from the related DataColumns into a useful
format. This class takes an array of DataColumns as an argument and
returns a DataFrame looking like this

.. image:: media/image2.png
   :width: 6.5in
   :height: 0.65278in

To do so we first identify the column containing the month data, if
there is any. Then for each remaining column we concatenate the result
of joining each DataColumn’s \`fee_data\` frame with the \`fee_data\`
frame of the period DataColumn (if it exists).

This will result in each rate, one for each cargo class, being connected
with the correct period. If there are rows with empty effective_date
cells we remove those as they are considered invalid (the dates provided
lie outside the given validity period for the row, set in the
EFFECTIVE_DATE and EXPIRATION_DATE columns.)

ValidityFrame
-------------

In order to sort the fees generated by the dynamic rows into the multiple
pricing periods without sacrificing too much speed, we need to create a
DataFrame populated with the validity for each row (ExpandedDateFrame).
Due to the set up of the sheet we can know that any fee column that is
not paired with a CURR/NEXT_MONTH column will be valid for the entirety
of the effective period defined in the EFFECTIVE_DATE and EXPIRATION_DATE columns.
Therefore the rates matching the initial effective and expiration date will be
duplicated for each of the ExpandedDateFrame validities.


ExpandedDateFrame
-----------------

At this point the DataColumns have been combined into a denormalised tables
with one row per fee/validity period combination. The validities should be
the one defined on the sheet and one for each month defined in the row.
This class takes a single row of the spreadsheet and all data frame rows
that originated from it. It will then pull together all the defined
validity and sort out the discrete validities that
exist in the collection. The result is a data frame that has the original
effective and expiration dates as well as one of the discrete validity
periods in each row.


Process
-------

1. Build a DataColumn for each column in the DataFrame prefixed with >
   "Dynamic:"

2. Group DataColumns by \`fee_code\` and \`current?\` and build a >
   FeeFromColumns class with the groupings of DataColumn’s

3. The FeeFromColumns class will pull the validity period info from the
   > DataColumn with the :month category and join it with each >
   remaining DataColumn’s \`fee_data\` frame.

4. Concatenate the results of all FeeFromColumns classes into a data >
   frame and join on the \`row\` number and sheet name to expand > fully
   to have one row per ‘fee’

5. Join in all Note DataColumns based on row number and sheet

.. |image1| image:: media/image2.png
   :width: 6.5in
   :height: 0.65278in
.. |image2| image:: media/image3.png
   :width: 3.875in
   :height: 0.25in
.. |image3| image:: media/image4.png
