.. _extractor:

ExcelDataServices::V2::Extractor
================================

The Extractor module and its classes serve to pull out ids from models
in our database and insert them into the relevant rows of the data
frame.

This is necessary in order to have all required data to insert (for
example a Pricing can’t be inserted with its TenantVehicle, an Itinerary
without its origin and destination hubs)

Each class in the Extractors module generally follows the pattern of
matching the name of the model being extracted, though that is more of a
guideline for clarity’s sake.

Each Extractor class inherits from the base class where the shared logic
lives. Here you will have the class method \`state(state:)\` defined as
well as the standard perform structure. A list of methods defined in extractors
are listed below.

+----------------------------------+----------------------------------+
| Method                           | Description                      |
+==================================+==================================+
| frame_data                       | Pulls all the relevant records   |
|                                  | from the table in question and   |
|                                  | select the necessary data points |
|                                  | to identify them accurately      |
+----------------------------------+----------------------------------+
| extracted_frame                  | Takes the database records       |
|                                  | extracted in the \`frame_data\`  |
|                                  | method and puts them into a data |
|                                  | frame                            |
+----------------------------------+----------------------------------+
| join_arguments                   | Key pairs for joining the do     |
|                                  | data frames together             |
+----------------------------------+----------------------------------+


This is the basic setup of a straight forward Extractor. However,
sometimes a simple Extractor won’t work. Then you can overwrite any of
these methods and just ensure that a data frame of the correct structure
is returned so that the rest of the code can proceed.
