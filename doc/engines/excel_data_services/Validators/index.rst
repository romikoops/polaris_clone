.. validator:

ExcelDataServices::V2::Validator
================================

The Validator module and its classes utilise the corresponding Extractor
classes to pull the ids of the relevant models into the Data Frame then
checks each row to see if the attribute is present. The rows that lack
the id of the model in question will be used to generate an Error that
will inform the user of the sheet and row that failed to extract the record

This is necessary in order to have all required data to insert (for
example a Pricing can’t be inserted with its TenantVehicle, an Itinerary
without its origin and destination hubs)

Each class in the Validators module generally follows the pattern of
matching the name of the model being extracted, though that is more of a
guideline for clarity’s sake.

Each Validator class inherits from the base class where the shared logic
lives. Here you will have the class method \`state(state:)\` defined as
well as the standard perform structure. A list of methods defined in extractors
are listed below.

+---------------------+----------------------------------+
| Method              | Description                      |
+=====================+==================================+
|| extracted          || Uses a Extractor class to pull  |
||                    || the id into the table           |
||                    ||                                 |
||                    ||                                 |
+---------------------+----------------------------------+
|| join_arguments     || Key pairs for joining the do    |
||                    || data frames together            |
+---------------------+----------------------------------+
|| required_key       || The key of the data frame that  |
||                    || must be scanned for null values |
+---------------------+----------------------------------+
|| error_reason(row:) || Uses the row to build a useful  |
||                    || error message                   |
+---------------------+----------------------------------+

