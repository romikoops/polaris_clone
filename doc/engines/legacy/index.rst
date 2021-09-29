Legacy
================================

**In the following, all models' data fields are described**

LocalCharge
-----

Function
~~~~~~~~

These are the charges that are applied at the Hubs. When the LocalCharge is
deleted, it is soft deleted, instead of being really deleted.

Field descriptions
~~~~~~~~~~~~~~~~~~

+-----------------+-------+-------------------------------------------+
| **name**        | **t   | **description**                           |
|                 | ype** |                                           |
+=================+=======+===========================================+
| id              | uuid  | *primary key*                             |
+-----------------+-------+-------------------------------------------+
| deleted_at      | date  | Contains a datetime stamp, if soft        |
|                 | time  | deleted                                   |
+-----------------+-------+-------------------------------------------+
