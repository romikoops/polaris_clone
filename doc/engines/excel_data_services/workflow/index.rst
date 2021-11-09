============================================
Uploader Workflow
============================================

This document describes the workflow of creating an uploader for a sheet.

There are different types of sheets. Refer : :ref:`sheet_type`.

To create an uploader for the sheets, we follow the steps in order as mentioned below :

1: **Create Pipeline :** Define the pipeline file i.e create a new file with pluralised
uploader name under the path:

.. code-block::

    ../imc-react-api/engines/excel_data_services/app/services/excel_data_services/v2/files/file_data/<your-file-name>


Refer : `pricings <https://github.com/itsmycargo/imc-react-api/blob/master/engines/excel_data_services/app/services/excel_data_services/v2/files/file_data/pricings>`_



2: **Schema File :** Create a schema file with the same name as specified in the pipeline
file under the path

.. code-block::

    ../imc-react-api/engines/excel_data_services/app/services/excel_data_services/v2/files/section_data/<your-file-name>



3: **Required Columns :** Define required columns for the uploaders to fail early if the
columns are not found.

Ex USAGE:

.. code-block::

    required "1:1", "A:?", %w[MOT CARRIER SERVICE_LEVEL]

Description::

    1:1 => from the first column and first row.

    A:? => Starting from column A to infinity.

    %w[] => All the specified columns here in the array are required and is
            not case sensitive.


4: **Column Definations :** Start Defining the fixed columns which the sheet must contain.

Ex USAGE:
::

    column "service",
    sanitizer: "text",
    validator: "string",
    required: true,
    type: :object,
    alternative_keys: ["service_level"],
    fallback: "standard"

More information about defining the columns and its attributes can be found here : :ref:`table_column` .

Refer : `pricings <https://github.com/itsmycargo/imc-react-api/blob/master/engines/excel_data_services/app/services/excel_data_services/v2/files/section_data/pricings>`_

The ordering of the columns does not matter.


5: **Row Validation :** Defining row validations for the columns that accept a block through
which the business logic can be passed.

Refer :ref:`row_validation` for more info.

Ex USAGE:

.. code-block::

    row_validation %w[effective_date expiration_date], (proc { \|a, b\| a < b })

This validates if the effective_date is less than expiration_date


6: **Define Prerequisites :** Setup prerequisites for the sheet which requires association data
that need to be already present.

Ex USAGE:

.. code-block::

    prerequisite "TenantVehicle"

Refer : `prerequisite <https://itsmycargo.atlassian.net/wiki/spaces/DEV/pages/1257308161/Excel+Data+Upload+Pipeline#Prerequisite>`_


7: **Dynamic Columns :** Add dynamic columns if required in conjunction with add_operation.
The dynamic column includes all the columns which are not specified in
the schema. The column which does not need to be dynamic can be excluded,

Refer :ref:`dynamic_columns` for more info.



8: **Adding Operation :** Operations hold custom logic for transforming data. This can be turning
Dynamic Columns into the schema defined columns or just manipulating data. The operations
are written in a separate file and specified as add_operation in the schema.

Refer :ref:`operations` for more info.

An example operation used in pricings is the dynamic fee operation which
converts dynamic fees columns such as "BAS", "ISOCC", "LSS", "CDD" and
"TDD" , we need to treat these columns as fees i.e convert them to
fee_code, fee_name and the value in the column as rate.

+-------------+-------------------+---------------+----------------+--------------+---------+-----------+
| **CARRIER** | **SERVICE_LEVEL** | **LOAD_TYPE** | **RATE_BASIS** | **CURRENCY** | **BAS** | **ISOCC** |
|             |                   |               |                |              |         |           |
|             |                   |               |                |              |         |           |
+=============+===================+===============+================+==============+=========+===========+
| EVERGREEN   | STANDARD          | FCL_20        | PER_CONTAINER  | USD          | 850     | 53        |
|             |                   |               |                |              |         |           |
+-------------+-------------------+---------------+----------------+--------------+---------+-----------+
| EVERGREEN   | STANDARD          | FCL_20        | PER_CONTAINER  | USD          | 1150    | 53        |
|             |                   |               |                |              |         |           |
+-------------+-------------------+---------------+----------------+--------------+---------+-----------+

The sheet above has two dynamic columns i.e BAS and ISOCC, the data
frame would look like below:

+-----------+---------------+-----------+---------------+----------+----------+----------+------+
| CARRIER   | SERVICE_LEVEL | LOAD_TYPE | RATE_BASIS    | CURRENCY | FEE_CODE | FEE_NAME | RATE |
+===========+===============+===========+===============+==========+==========+==========+======+
| EVERGREEN | STANDARD      | FCL_20    | PER_CONTAINER | USD      | bas      | BAS      | 850  |
+-----------+---------------+-----------+---------------+----------+----------+----------+------+
| EVERGREEN | STANDARD      | FCL_20    | PER_CONTAINER | USD      | bas      | BAS      | 1150 |
+-----------+---------------+-----------+---------------+----------+----------+----------+------+
| EVERGREEN | STANDARD      | FCL_20    | PER_CONTAINER | USD      | isocc    | ISOCC    | 53   |
+-----------+---------------+-----------+---------------+----------+----------+----------+------+
| EVERGREEN | STANDARD      | FCL_20    | PER_CONTAINER | USD      | isocc    | ISOCC    | 53   |
+-----------+---------------+-----------+---------------+----------+----------+----------+------+

The mapping happens in the ruby file specified as add_operation and the
format for writing the operation files is here : :ref:`dynamic_fees` .



9: **Adding Extractors :** to extract id the models which are ActiveRecord related to
the uploader model. The easiest way to identify what extractors are
required are the ones which has a foreign key in the model.

For Ex::

    Pricings::Pricing has tenant_vehicle_id as foreign key.
    To retrieve the tenant_vehicle_id, we query the Legacy::TenantVehicle model
    with the mode_of_transport and carrier from the pricings excel.

Refer :ref:`extractor` for more info.

*Note : The order of the extractors has to be maintained.*



10: **Adding Formatters :** final step is to write the formatters which convert the data frame
into a hash which is consumed by the model to create records.

Refer :ref:`formatters` for more info.



11: Other steps include,

`Specifying the model` :ref:`model_initializer`

`Specifying overlaps if any` :ref:`overlaps`

`Specifying conflicts if any` :ref:`conflicts`

*Before writing schemas for an uploader, uploader doc has to be written and committed to the codebase after an approval.*

Existing uploaders for v2 are :

`Carrier :` :ref:`carrier_uploader`

`Charge Category :` :ref:`charge_category_uploader`

`Itinerary :` :ref:`itinerary_uploader`

`Pricings :` :ref:`pricing_uploader`

`Routing Carrier :` :ref:`routing_carrier_uploader`

`Tenant Vehicle :` :ref:`tenant_vehicle_uploader`

`Saco Pricings :` :ref:`saco_pricing_uploader`

