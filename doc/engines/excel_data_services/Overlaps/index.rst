.. _overlaps:

ExcelDataServices::V2::Overlaps
===============================

The Overlaps module contains our tools for clearing the database to make
room for new records being inserted. The way 'space is made' depends on
the type of conflict detected. Most will simply adjust the effective date
or expiration date of the existing record, while other will soft delete
the conflicting record

+----------------------------------+----------------------------------+
| Class                            | Description                      |
+==================================+==================================+
| Detector                         | Given the a set of values        |
|                                  | defining a pricing, it will      |
|                                  | query the table and returns an   |
|                                  | array of conflict types that     |
|                                  | apply to the new record          |
+----------------------------------+----------------------------------+
| Resolver                         | Iterates through each unique     |
|                                  | record in the data frame and     |
|                                  | checks for conflicts using the   |
|                                  | Detector class. If any are found |
|                                  | the relevant conflict class is   |
|                                  | triggered to make the necessary  |
|                                  | adjustments                      |
+----------------------------------+----------------------------------+
| ContainedByExisting              | The new record starts after, and |
|                                  | ends before the existing record. |
|                                  | In this case the existing record |
|                                  | is split in two with the new     |
|                                  | record to be placed in between   |
+----------------------------------+----------------------------------+
| ContainedByNew                   | The new record covers the        |
|                                  | existing record entirely. The    |
|                                  | existing record is soft deleted  |
+----------------------------------+----------------------------------+
| ExtendsBeforeExisting            | The new record starts before and |
|                                  | ends during the existing record. |
|                                  | The existing record will have    |
|                                  | its effective_date moved up to   |
|                                  | the new record’s expiration_date |
+----------------------------------+----------------------------------+
| ExtendsPastExisting              | The new record starts after the  |
|                                  | existing record begins and ends  |
|                                  | after it finishes. The existing  |
|                                  | record will have its             |
|                                  | expiration_date moved up to the  |
|                                  | new record’s effective_date      |
+----------------------------------+----------------------------------+
