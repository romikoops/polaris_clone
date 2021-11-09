.. _formatters:

ExcelDataServices::V2::Formatters
=================================

The Formatters module holds a class for each model that we want to
insert into the database. In each class we have model specific logic to
take data from the data frame and assign to the State objects
\`insertable_data\` attribute an array of properly formatted hashes
adhering to the schema of the model.

Each Formatter class inherits from the base class where the shared logic
lives. Here you will have the class method \`state(state:)\` defined as
well as the standard perform structure which

+----------------------------------+----------------------------------+
| Method                           | Description                      |
+==================================+==================================+
| insertable_data                  | The \`insertable_data\` method   |
|                                  | will return an array of objects  |
|                                  | that are formatted for insertion |
|                                  | into the database. This array    |
|                                  | will be assigned to              |
|                                  | \`insertable_data\` on the State |
|                                  | object                           |
+----------------------------------+----------------------------------+
