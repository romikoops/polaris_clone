.. _carrier_uploader:

==========================================
Carrier uploader
==========================================

Technical document to build the carrier uploader.

Target Model:
=============

Legacy::Carrier

Columns:
========

+--------------+-----------+--------------+----------+--------+--------+------------------+---------------------+----------+
| Header       | sanitizer | validations  | required | type   | unique | alternative_keys | fallback            | Sections |
|              |           |              |          |        |        |                  |                     |          |
|              |           |              |          |        |        |                  |                     |          |
+==============+===========+==============+==========+========+========+==================+=====================+==========+
| carrier      | text      | string       |  false   | object |        |                  | organization.slug   |          |
|              |           |              |          |        |        |                  |                     |          |
|              |           |              |          |        |        |                  |                     |          |
+--------------+-----------+--------------+----------+--------+--------+------------------+---------------------+----------+
| carrier_code | downcase  | string       | false    | object |        | carrier          | organization.slug   |          |
|              |           |              |          |        |        |                  |                     |          |
|              |           |              |          |        |        |                  |                     |          |
+--------------+-----------+--------------+----------+--------+--------+------------------+---------------------+----------+

Row Validations:
================

+---------------+
| Columns Logic |
+---------------+

--------------

Prerequisite:
=============

-  "RoutingCarrier"

Dynamic Columns:
================

+--------------------------------+
| Including Excluding Header_row |
+--------------------------------+

--------------

Extractors:
===========

-  

Operations:
===========

-  

Conflicts
=========

+---------------------+
| Model Conflict keys |
+---------------------+

--------------

Model Importer:
===============

+----------------------------------+----------------------------------+
| Model                            | options                          |
+==================================+==================================+
| Legacy::Carrier                  |                                  |
+----------------------------------+----------------------------------+

