.. _operations:

ExcelDataServices::V2::Operations
=================================

The Operations module exists for any custom logic or transformations
that need to be applied to the data frame in order for the following
classes to properly consume the frame.

The current example would be the DynamicFees class which converts the
dynamic columns of the sheet into rows with the attributes needed to
insert ChargeCategories and Pricings::Fee’s

Each Operation class inherits from the base class where the shared logic
lives. Here you will have the class method \`state(state:)\` defined as
well as the standard perform structure which

What the Operation class is, essentially, is a black box that accepts
the current data frame and returns a new one.

+----------------------------------+----------------------------------+
| Method                           | Description                      |
+==================================+==================================+
| operation_result                 | The \`operation_result\` method  |
|                                  | will return a value that         |
|                                  | overwrites the \`frame\` on the  |
|                                  | state                            |
+----------------------------------+----------------------------------+
