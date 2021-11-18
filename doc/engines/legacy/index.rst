Legacy
================================

**In the following, all models' data fields are described**

LocalCharge
-----------

Function
~~~~~~~~

These are the charges that are applied at the Hubs. When the LocalCharge is
deleted, it is soft deleted, instead of being really deleted.

Field descriptions
~~~~~~~~~~~~~~~~~~

+------------+----------+------------------------------------+
|  **name**  | **type** |          **description**           |
|            |          |                                    |
+============+==========+====================================+
| id         | uuid     | *primary key*                      |
+------------+----------+------------------------------------+
| deleted_at | date     | Contains a datetime stamp, if soft |
|            | time     | deleted                            |
+------------+----------+------------------------------------+

Hubs
-----

Hubs represent a warehouse or an area where companies can perform a full range of operations to process freights.
In our hub-and-spoke style routing system Hubs acts as the Hub where the itinerary acts as the spoke connecting two Hub's together. 
A hub is mode of transport specific and this is stored as the 'hub_type' enum. A Hub is identified by its 'name', 'nexus_id', 'terminal' and 'hub_type'.
Only one Hub can exists per Organization for each combination of these attributes.

+----------+----------------------------------+---------------------------------------------------------------------------------------------------+
| **name** |             **type**             |                                          **description**                                          |
|          |                                  |                                                                                                   |
+==========+==================================+===================================================================================================+
| id       | uuid                             | *primary key*                                                                                     |
+----------+----------------------------------+---------------------------------------------------------------------------------------------------+
| hub_type | hub_type_mode_of_transport(enum) | Specifies the hub type for the hub which can be one of the type `ocean`, `rail`, `air` or `truck` |
|          |                                  |                                                                                                   |
+----------+----------------------------------+---------------------------------------------------------------------------------------------------+
