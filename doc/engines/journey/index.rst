Journey
================================

**In the following all models are described in function, relation to
other models, and their individual data fields.**

Please note that any state management (i.e. in which status the
currently looked at shipment actually is) will be handled by a dedicated
library (likely the "statesman" gem). The following models therefore
don't have data fields that keep track of the status
query/quotation/booking/shipment's status.

.. image:: media/image1.tmp
   :width: 2.6in
   :height: 2.6in

Query
-----

Function
~~~~~~~~

When the user has entered his/her input, the query, along with
corresponding cargo units and potentially uploaded documents, gets
persisted in the database, before performing any calculation. Note that
the creator of the query is not necessarily equal to the client. E.g. in
the internal quotation tool, the creator would be the shop owner's
employee who is using the tool.

Relations
~~~~~~~~~

+-----------------------------------+----------------------------------+
| **model name**                    | **relation**                     |
+===================================+==================================+
| CargoUnit                         | one-to-many                      |
+-----------------------------------+----------------------------------+
| Document                          | one-to-many                      |
+-----------------------------------+----------------------------------+
| ResultSet                         | one-to-many                      |
+-----------------------------------+----------------------------------+

Field descriptions
~~~~~~~~~~~~~~~~~~

+-----------------+-------+-------------------------------------------+
| **name**        | **t   | **description**                           |
|                 | ype** |                                           |
+=================+=======+===========================================+
| id              | uuid  | *primary key*                             |
+-----------------+-------+-------------------------------------------+
| source_id       | uuid  | Id of the Doorkeeper application          |
|                 |       | responsible for the Query                 |
+-----------------+-------+-------------------------------------------+
| origin          | s     | origin address (what the user selects in  |
|                 | tring | the input box)                            |
+-----------------+-------+-------------------------------------------+
| ori             | wkt-  | coordinates of origin                     |
| gin_coordinates | point |                                           |
+-----------------+-------+-------------------------------------------+
| destination     | s     | destination address (what the user        |
|                 | tring | selects in the input box)                 |
+-----------------+-------+-------------------------------------------+
| destinat        | wkt-  | coordinates of destination                |
| ion_coordinates | point |                                           |
+-----------------+-------+-------------------------------------------+
| creator_id      | uuid  | *foreign key* to creator.                 |
+-----------------+-------+-------------------------------------------+
| client_id       | uuid  | *foreign key* to client                   |
+-----------------+-------+-------------------------------------------+
| company_id      | uuid  | *foreign key* to company                  |
+-----------------+-------+-------------------------------------------+
| c               | date  | cargo ready date                          |
| argo_ready_date |       |                                           |
+-----------------+-------+-------------------------------------------+
| delivery_date   | date  | delivery date                             |
+-----------------+-------+-------------------------------------------+
| customs         | bo    | does the client want to book customs?     |
|                 | olean |                                           |
+-----------------+-------+-------------------------------------------+
| insurance       | bo    | does the client want to book insurance?   |
|                 | olean |                                           |
+-----------------+-------+-------------------------------------------+
| organization_id | uuid  | foreign key to organization               |
+-----------------+-------+-------------------------------------------+

CargoUnit
---------

.. _function-1:

Function
~~~~~~~~

Stores the information of both

-  cargo with the exact dimensions specified

-  aggregated cargo (aggregated volume and weight).

Note: When the type is aggregated_lcl, the value of the aggregated
volume will simply be saved in the width column, with length and height
having a value of 1. This way, the volume can still be calculated the
same way, avoiding extra code paths and data fields to deal with
aggregated volume.

.. _relations-1:

Relations
~~~~~~~~~

+---------------------+------------------------------------------------+
| **model name**      | **relation**                                   |
+=====================+================================================+
| CommodityInfo       | one-to-many                                    |
+---------------------+------------------------------------------------+
| LineItemCargoUnit   | one-to-many                                    |
+---------------------+------------------------------------------------+
| LineItem            | many-to-many (through LineItemCargoUnit)       |
+---------------------+------------------------------------------------+

.. _field-descriptions-1:

Field descriptions
~~~~~~~~~~~~~~~~~~

+-------+------+-------------------------------------------------------+
| **n   | **ty | **description**                                       |
| ame** | pe** |                                                       |
+=======+======+=======================================================+
| id    | uuid | *primary key*                                         |
+-------+------+-------------------------------------------------------+
| que   | uuid | *foreign key* to query                                |
| ry_id |      |                                                       |
+-------+------+-------------------------------------------------------+
| type  | st   | lcl, fcl_20, fcl_40, etc. + aggregated_lcl.           |
|       | ring |                                                       |
+-------+------+-------------------------------------------------------+
| qua   | int  | how many cargo items of the same dimensions (together |
| ntity | eger | building one CargoUnit)                               |
+-------+------+-------------------------------------------------------+
| stac  | boo  | is the cargo stackable? applies only to lcl.          |
| kable | lean |                                                       |
+-------+------+-------------------------------------------------------+
| col   | uuid | *foreign key* to colli (packaging type)               |
| li_id |      |                                                       |
+-------+------+-------------------------------------------------------+
| width | f    | width of a single item within the CargoUnit in m      |
|       | loat |                                                       |
+-------+------+-------------------------------------------------------+
| l     | f    | length of a single item within the CargoUnit in m     |
| ength | loat |                                                       |
+-------+------+-------------------------------------------------------+
| h     | f    | height of a single item within the CargoUnit in m     |
| eight | loat |                                                       |
+-------+------+-------------------------------------------------------+
| w     | f    | weight of a single item within the CargoUnit in kg    |
| eight | loat |                                                       |
+-------+------+-------------------------------------------------------+

CommodityInfo
-------------

.. _function-2:

Function
~~~~~~~~

Details information about the goods shipped.

.. _relations-2:

Relations
~~~~~~~~~

+-------------------+--------------------------------------------------+
| **model name**    | **relation**                                     |
+===================+==================================================+
| CargoUnit         | one-to-many (CargoUnit has-many)                 |
+-------------------+--------------------------------------------------+

.. _field-descriptions-2:

Field descriptions
~~~~~~~~~~~~~~~~~~

+-------------+-----+-------------------------------------------------+
| **name**    | **  | **description**                                 |
|             | typ |                                                 |
|             | e** |                                                 |
+=============+=====+=================================================+
| id          | u   | *primary key*                                   |
|             | uid |                                                 |
+-------------+-----+-------------------------------------------------+
| ca          | u   | *foreign key* to cargo unit                     |
| rgo_unit_id | uid |                                                 |
+-------------+-----+-------------------------------------------------+
| hs_code     | str | Harmonized System (HS) Code                     |
|             | ing |                                                 |
+-------------+-----+-------------------------------------------------+
| imo_class   | str | IMO class                                       |
|             | ing |                                                 |
+-------------+-----+-------------------------------------------------+
| description | str | extra description and/or notes about the        |
|             | ing | commodities                                     |
+-------------+-----+-------------------------------------------------+

LineItemCargoUnit
-----------------

.. _function-3:

Function
~~~~~~~~

Join table (many-to-many) between LineItem and CargoUnit.

.. _relations-3:

Relations
~~~~~~~~~

+-------------------+--------------------------------------------------+
| **model name**    | **relation**                                     |
+===================+==================================================+
| LineItem          | one-to-many (LineItem has-many)                  |
+-------------------+--------------------------------------------------+
| CargoUnit         | one-to-many (CargoUnit has-many)                 |
+-------------------+--------------------------------------------------+

.. _field-descriptions-3:

Field descriptions
~~~~~~~~~~~~~~~~~~

+----------------------+--------+--------------------------------------+
| **name**             | **     | **description**                      |
|                      | type** |                                      |
+======================+========+======================================+
| id                   | uuid   | *primary key*                        |
+----------------------+--------+--------------------------------------+
| line_item_id         | uuid   | *foreign key* to line item           |
+----------------------+--------+--------------------------------------+
| cargo_unit_id        | uuid   | *foreign key* to cargo_unit          |
+----------------------+--------+--------------------------------------+

LineItem
--------

.. _function-4:

Function
~~~~~~~~

A LineItem describes an individual line on a "invoice-like" result that
gets presented to the user. As such it is bundled in a LineItemSet. Each
line represents the price to be paid in a certain currency, which comes
about by calculating together the corresponding fee with the cargo and
routing information of the user request. It saves information about the
particular route section that a freight rate is being applied to, as
well as a singular route point, in the case of local charges.

.. _relations-4:

Relations
~~~~~~~~~

+---------------------+------------------------------------------------+
| **model name**      | **relation**                                   |
+=====================+================================================+
| LineItemSet         | one-to-many (LineItemSet has-many)             |
+---------------------+------------------------------------------------+
| LineItemCargoUnit   | on-to-many (LineItem has-many)                 |
+---------------------+------------------------------------------------+
| CargoUnit           | many-to-many (through LineItemCargoUnit)       |
+---------------------+------------------------------------------------+
| RouteSection        | one-to-many (RouteSection has-many)            |
+---------------------+------------------------------------------------+
| RoutePoint          | one-to-many (RoutePoint has-many)              |
+---------------------+------------------------------------------------+

.. _field-descriptions-4:

Field descriptions
~~~~~~~~~~~~~~~~~~

+------------+------+--------------------------------------------------+
| **name**   | **ty | **description**                                  |
|            | pe** |                                                  |
+============+======+==================================================+
| id         | uuid | *primary key*                                    |
+------------+------+--------------------------------------------------+
| route_     | uuid | *foreign key* to route section                   |
| section_id |      |                                                  |
+------------+------+--------------------------------------------------+
| rout       | uuid | *foreign key* to route point                     |
| e_point_id |      |                                                  |
+------------+------+--------------------------------------------------+
| line_i     | uuid | *foreign key* to line item set                   |
| tem_set_id |      |                                                  |
+------------+------+--------------------------------------------------+
| note       | st   | description and/or extra conditions              |
|            | ring |                                                  |
+------------+------+--------------------------------------------------+
| order      | int  | specifies the order in which the line item       |
|            | eger | oughts to appear                                 |
+------------+------+--------------------------------------------------+
| fee_code   | st   | short code of the fee                            |
|            | ring |                                                  |
+------------+------+--------------------------------------------------+
| d          | st   | longer descriptive text for the fee              |
| escription | ring |                                                  |
+------------+------+--------------------------------------------------+
| to         | int  | total price in small unit of the currency, i.e.  |
| tal_amount | eger | cents.                                           |
+------------+------+--------------------------------------------------+
| tota       | st   | the currency of the total price                  |
| l_currency | ring |                                                  |
+------------+------+--------------------------------------------------+
| included   | boo  | is the price of the fee already included in some |
|            | lean | other fee (e.g. the BAS - Basic Ocean Freight)?  |
|            |      | Usually means that the total_amount is 0.        |
+------------+------+--------------------------------------------------+
| optional   | boo  | is the fee only to be paid in certain optional   |
|            | lean | events?                                          |
+------------+------+--------------------------------------------------+
| wm_ratio   | dec  | rate at which chargeable weight was calculated   |
|            | imal |                                                  |
+------------+------+--------------------------------------------------+

LineItemSet
-----------

.. _function-5:

Function
~~~~~~~~

Bundles multiple LineItem objects together.

.. _relations-5:

Relations
~~~~~~~~~

+----------------------+-----------------------------------------------+
| **model name**       | **relation**                                  |
+======================+===============================================+
| LineItem             | one-to-many (LineItemSet has-many)            |
+----------------------+-----------------------------------------------+
| Result               | many-to-one (Result has-many)                 |
+----------------------+-----------------------------------------------+
| ShipmentRequest      | one-to-one                                    |
+----------------------+-----------------------------------------------+

.. _field-descriptions-5:

Field descriptions
~~~~~~~~~~~~~~~~~~

+-------------------------+------+-------------------------------------+
| **name**                | **ty | **description**                     |
|                         | pe** |                                     |
+=========================+======+=====================================+
| id                      | uuid | *primary key*                       |
+-------------------------+------+-------------------------------------+
| result_id               | uuid | *foreign key* to result             |
+-------------------------+------+-------------------------------------+
| shipment_request_id     | uuid | *foreign key* to shipment request   |
+-------------------------+------+-------------------------------------+

ResultSet
---------

.. _function-6:

Function
~~~~~~~~

Bundles multiple Result objects together.

.. _relations-6:

Relations
~~~~~~~~~

+-------------------+--------------------------------------------------+
| **model name**    | **relation**                                     |
+===================+==================================================+
| Query             | one-to-many (Query has-many)                     |
+-------------------+--------------------------------------------------+
| ExchangeRate      | one-to-many (ExchangeRate has-many)              |
+-------------------+--------------------------------------------------+

.. _field-descriptions-6:

Field descriptions
~~~~~~~~~~~~~~~~~~

+---------------------+-------+----------------------------------------+
| **name**            | **t   | **description**                        |
|                     | ype** |                                        |
+=====================+=======+========================================+
| id                  | uuid  | *primary key*                          |
+---------------------+-------+----------------------------------------+
| query_id            | uuid  | *foreign key* to query                 |
+---------------------+-------+----------------------------------------+
| exchange_rate_id    | uuid  | *foreign key* to exchange rate         |
+---------------------+-------+----------------------------------------+
| status              | enum  | "queued", "running", "completed"       |
+---------------------+-------+----------------------------------------+

Result
------

.. _function-7:

Function
~~~~~~~~

A Result represents an expiring snapshot/bundle of calculated LineItems
for a collection of RouteSection objects (where all route sections
together form a full route). Moreover, when the user selects a Result
object, its information is used to form a ShipmentRequest. Furthermore,
by selecting multiple Results, an Offer can be obtained by the user.

.. _relations-7:

Relations
~~~~~~~~~

+-----------------------+----------------------------------------------+
| **model name**        | **relation**                                 |
+=======================+==============================================+
| ResultSet             | one-to-many (ResultSet has-many)             |
+-----------------------+----------------------------------------------+
| ShipmentRequest       | one-to-many (Result has-many)                |
+-----------------------+----------------------------------------------+
| RouteSection          | one-to-many (Result has-many)                |
+-----------------------+----------------------------------------------+
| LineItemSet           | one-to-many (Result has-many)                |
+-----------------------+----------------------------------------------+

.. _field-descriptions-7:

Field descriptions
~~~~~~~~~~~~~~~~~~

+----------------------+-------+---------------------------------------+
| **name**             | **t   | **description**                       |
|                      | ype** |                                       |
+======================+=======+=======================================+
| id                   | uuid  | *primary key*                         |
+----------------------+-------+---------------------------------------+
| result_set_id        | uuid  | *foreign key* to result set           |
+----------------------+-------+---------------------------------------+
| expiration_date      | date  | until when the result is valid        |
+----------------------+-------+---------------------------------------+
| issued_at            | date  | date the result was created           |
+----------------------+-------+---------------------------------------+

Error
-----

.. _function-8:

Function
~~~~~~~~

Each error object represents one out of two possible error classes:

1. Validation errors

2. Calculation errors

.

.. _relations-8:

Relations
~~~~~~~~~

+-------------------+--------------------------------------------------+
| **model name**    | **relation**                                     |
+===================+==================================================+
| ResultSet         | one-to-many (ResultSet has-many)                 |
+-------------------+--------------------------------------------------+
| Query             | one-to-many (Query has-many)                 |
+------------------+----------+----------------------------------------+

.. _field-descriptions-8:

Field descriptions
~~~~~~~~~~~~~~~~~~

+---------------+----+------------------------------------------------+
| **name**      | ** | **description**                                |
|               | ty |                                                |
|               | pe |                                                |
|               | ** |                                                |
+===============+====+================================================+
| id            | uu | *primary key*                                  |
|               | id |                                                |
+---------------+----+------------------------------------------------+
| result_set_id | uu | *foreign key* to result_set                    |
|               | id |                                                |
+---------------+----+------------------------------------------------+
| code          | i  | an IMC internal code                           |
|               | nt |                                                |
+---------------+----+------------------------------------------------+
| service       | st | the specific service used in the current       |
|               | ri | calculation                                    |
|               | ng |                                                |
+---------------+----+------------------------------------------------+
| carrier       | st | the specific carrier used in the current       |
|               | ri | calculation                                    |
|               | ng |                                                |
+---------------+----+------------------------------------------------+
| mode          | st | the mode of transport                          |
| _of_transport | ri |                                                |
|               | ng |                                                |
+---------------+----+------------------------------------------------+
| attribute     | st | e.g. "width", "cargo_class"                    |
|               | ri |                                                |
|               | ng |                                                |
+---------------+----+------------------------------------------------+
| value         | st | e.g. "999 m" (meters for width)                |
|               | ri |                                                |
|               | ng | → the "m" is included as it comes from a       |
|               |    | measured object.                               |
+---------------+----+------------------------------------------------+
| value_limit   | st | e.g. "10 m" (meters for width)                 |
|               | ri |                                                |
|               | ng |                                                |
+---------------+----+------------------------------------------------+
| query_id      |uuid| *foreign key* to query                         |
+---------------+----+------------------------------------------------+

RoutePoint
----------

.. _function-9:

Function
~~~~~~~~

Represents a single point within a route section (which in turn can be
combined to form full routes).

.. _relations-9:

Relations
~~~~~~~~~

+-------------+--------------------------------------------------------+
| **model     | **relation**                                           |
| name**      |                                                        |
+=============+========================================================+
| R           | one-to-many (RoutePoint has-many, *foreign key*        |
| outeSection | "from_id")                                             |
+-------------+--------------------------------------------------------+
| R           | one-to-many (RoutePoint has-many, *foreign key*        |
| outeSection | "to_id")                                               |
+-------------+--------------------------------------------------------+
| LineItem    | one-to-many (RoutePoint has-many)                      |
+-------------+--------------------------------------------------------+

.. _field-descriptions-9:

Field descriptions
~~~~~~~~~~~~~~~~~~

+----------------+--------------+--------------------------------------+
| **name**       | **type**     | **description**                      |
+================+==============+======================================+
| id             | uuid         | *primary key*                        |
+----------------+--------------+--------------------------------------+
| function       | string       | ocean port, air port, etc.           |
+----------------+--------------+--------------------------------------+
| name           | string       | the name of the place                |
+----------------+--------------+--------------------------------------+
| coordinates    | wkt-point    | the coordinates of the place         |
+----------------+--------------+--------------------------------------+

RouteSection
------------

.. _function-10:

Function
~~~~~~~~

By combining together two RoutePoint objects, a RouteSection is
obtained. One ore more RouteSection objects together represent a full
route, as offered by a particular carrier for a particular mode of
transport and a particular service level.

.. _relations-10:

Relations
~~~~~~~~~

+-----------+----------------------------------------------------------+
| **model   | **relation**                                             |
| name**    |                                                          |
+===========+==========================================================+
| Result    | one-to-many (Result has-many)                            |
+-----------+----------------------------------------------------------+
| LineItem  | one-to-many (RouteSection has-many)                      |
+-----------+----------------------------------------------------------+
| R         | one-to-many (RoutePoint has-many, with *foreign key*     |
| outePoint | "from_id")                                               |
+-----------+----------------------------------------------------------+
| R         | one-to-many (RoutePoint has-many, with *foreign key*     |
| outePoint | "to_id")                                                 |
+-----------+----------------------------------------------------------+

.. _field-descriptions-10:

Field descriptions
~~~~~~~~~~~~~~~~~~

+--------------+-----+-------------------------------------------------+
| **name**     | **  | **description**                                 |
|              | typ |                                                 |
|              | e** |                                                 |
+==============+=====+=================================================+
| id           | u   | *primary key*                                   |
|              | uid |                                                 |
+--------------+-----+-------------------------------------------------+
| result_id    | u   | *foreign key* to result                         |
|              | uid |                                                 |
+--------------+-----+-------------------------------------------------+
| from_id      | u   | *foreign key* to the starting route point of    |
|              | uid | the section                                     |
+--------------+-----+-------------------------------------------------+
| to_id        | u   | *foreign key* to the ending route point of the  |
|              | uid | section                                         |
+--------------+-----+-------------------------------------------------+
| mode_        | str | mode of transport                               |
| of_transport | ing |                                                 |
+--------------+-----+-------------------------------------------------+
| carrier      | str | *SCAC* code of the carrier                      |
|              | ing |                                                 |
+--------------+-----+-------------------------------------------------+
| service      | str | the service level name                          |
|              | ing |                                                 |
+--------------+-----+-------------------------------------------------+
| order        | i   | specifies which part of the offered route is    |
|              | nte | represented by this particular section          |
|              | ger |                                                 |
+--------------+-----+-------------------------------------------------+
| t            | str | Details the transshipments (if any) on this     |
| ransshipment | ing | part of the Journey                             |
+--------------+-----+-------------------------------------------------+

OfferLineItemSet
----------------

.. _function-11:

Function
~~~~~~~~

Join table (many-to-many) between Offer and LineItemSets.

.. _relations-11:

Relations
~~~~~~~~~

+------------------+---------------------------------------------------+
| **model name**   | **relation**                                      |
+==================+===================================================+
| Offer            | one-to-many (Offer has-many)                      |
+------------------+---------------------------------------------------+
| LineItemSet      | one-to-many (LineItemSet has-many)                |
+------------------+---------------------------------------------------+

.. _field-descriptions-11:

Field descriptions
~~~~~~~~~~~~~~~~~~

+-----------------------+-------+--------------------------------------+
| **name**              | **t   | **description**                      |
|                       | ype** |                                      |
+=======================+=======+======================================+
| id                    | uuid  | *primary key*                        |
+-----------------------+-------+--------------------------------------+
| offer_id              | uuid  | *foreign key* to offer               |
+-----------------------+-------+--------------------------------------+
| line_item_set_id      | uuid  | *foreign key* to line_item_set       |
+-----------------------+-------+--------------------------------------+

Offer
-----

.. _function-12:

Function
~~~~~~~~

When the user select one or more Result objects, these get bundled
together and downloaded as an Offer (usually with an attached PDF).

.. _relations-12:

Relations
~~~~~~~~~

+--------------------+-------------------------------------------------+
| **model name**     | **relation**                                    |
+====================+=================================================+
| OfferLineItemSet   | one-to-many (Offer has-many)                    |
+--------------------+-------------------------------------------------+
| LineItemSet        | many-to-many (through OfferLineItemSet)         |
+--------------------+-------------------------------------------------+
| Query              | one-to-many (Query has-many)                    |
+--------------------+-------------------------------------------------+
| File               | has-many (Rails' "has-one-attached")            |
+--------------------+-------------------------------------------------+

.. _field-descriptions-12:

Field descriptions
~~~~~~~~~~~~~~~~~~

+------------------+----------+---------------------------------------+
| **name**         | **type** | **description**                       |
+==================+==========+=======================================+
| id               | uuid     | *primary key*                         |
+------------------+----------+---------------------------------------+
| query_id         | uuid     | *foreign key* to query                |
+------------------+----------+---------------------------------------+

ShipmentRequest
---------------

.. _function-13:

Function
~~~~~~~~

Once the user selects a Result object that he/she wants to give an
actual order for starting the shipping process, the information that's
available through the Result object is used to make a ShipmentRequest.

.. _relations-13:

Relations
~~~~~~~~~

+------------------+---------------------------------------------------+
| **model name**   | **relation**                                      |
+==================+===================================================+
| Result           | one-to-many (result has-many)                     |
+------------------+---------------------------------------------------+
| LineItemSet      | one-to-one                                        |
+------------------+---------------------------------------------------+
| Document         | one-to-many (ShipmentRequest has-many)            |
+------------------+---------------------------------------------------+
| Shipment         | one-to-one                                        |
+------------------+---------------------------------------------------+
| Shipme           | one-to-many (ShipmentRequest has-many)            |
| ntRequestContact |                                                   |
+------------------+---------------------------------------------------+
| (Contact)        | many-to-many (this relation should not be         |
|                  | actively used, as the contact information for the |
|                  | specific ShipmentRequest should always be saved   |
|                  | directly on the ShipmentRequestContact, and only  |
|                  | be used there).                                   |
+------------------+---------------------------------------------------+

.. _field-descriptions-13:

Field descriptions
~~~~~~~~~~~~~~~~~~

+----------------------+------+----------------------------------------+
| **name**             | **ty | **description**                        |
|                      | pe** |                                        |
+======================+======+========================================+
| id                   | uuid | *primary key*                          |
+----------------------+------+----------------------------------------+
| result_id            | uuid | *foreign key* to result                |
+----------------------+------+----------------------------------------+
| client_id            | uuid | *foreign key* to client                |
+----------------------+------+----------------------------------------+
| preferred_voyage     | date | voyage code of preferred voyage        |
+----------------------+------+----------------------------------------+

Contact
-------

.. _function-14:

Function
~~~~~~~~

Every shipment will involve zero or more consignees, consignors and
notifyees. This model saves the information of these contacts (and which
of the aforementioned types they are). They also link to the normal
Concat model. As such, information from Contact can be duplicated in the
ShipmentRequestContact (for example when choosing a contact from an
address book), but the Contact is only dedicated to a particular
ShipmentRequest.

.. _relations-14:

Relations
~~~~~~~~~

+--------------------+-------------------------------------------------+
| **model name**     | **relation**                                    |
+====================+=================================================+
| ShipmentRequest    | one-to-many (ShipmentRequest has-many)          |
+--------------------+-------------------------------------------------+
| Contact            | one-to-many (Contact has-many)                  |
+--------------------+-------------------------------------------------+

.. _field-descriptions-14:

Field descriptions
~~~~~~~~~~~~~~~~~~

+------------------------+-------+-------------------------------------+
| **name**               | **t   | **description**                     |
|                        | ype** |                                     |
+========================+=======+=====================================+
| id                     | uuid  | *primary key*                       |
+------------------------+-------+-------------------------------------+
| shipment_request_id    | uuid  | *foreign key* to shipment request   |
+------------------------+-------+-------------------------------------+
| original_id            | uuid  | id of the original contact          |
+------------------------+-------+-------------------------------------+
| function               | s     | consignee, consignor or notifyee    |
|                        | tring |                                     |
+------------------------+-------+-------------------------------------+
| + Contact attributes   | ...   | ...                                 |
+------------------------+-------+-------------------------------------+

Shipment
--------

.. _function-15:

Function
~~~~~~~~

A ShipmentRequest is be turned into a full shipment, once the shop owner
confirms to fulfill the request.

.. _relations-15:

Relations
~~~~~~~~~

+-------------------+--------------------------------------------------+
| **model name**    | **relation**                                     |
+===================+==================================================+
| ShipmentRequest   | one-to-one (ShipmentRequest may have zero)       |
+-------------------+--------------------------------------------------+

.. _field-descriptions-15:

Field descriptions
~~~~~~~~~~~~~~~~~~

+-------------------------+------+-------------------------------------+
| **name**                | **ty | **description**                     |
|                         | pe** |                                     |
+=========================+======+=====================================+
| id                      | uuid | *primary key*                       |
+-------------------------+------+-------------------------------------+
| shipment_request_id     | uuid | *foreign key* to shipment request   |
+-------------------------+------+-------------------------------------+
| creator_id              | uuid | *foreign key* to creator            |
+-------------------------+------+-------------------------------------+
| ...                     | ...  | ...                                 |
+-------------------------+------+-------------------------------------+

Document
--------

.. _function-16:

Function
~~~~~~~~

Documents can either be uploaded when querying for results, or later,
when making a ShipmentRequest (which can require some documents to be
uploaded).

.. _relations-16:

Relations
~~~~~~~~~

+--------------------+-------------------------------------------------+
| **model name**     | **relation**                                    |
+====================+=================================================+
| ShipmentRequest    | one-to-many (ShipmentRequest has-many)          |
+--------------------+-------------------------------------------------+
| Query              | one-to-many (Query has-many)                    |
+--------------------+-------------------------------------------------+

.. _field-descriptions-16:

Field descriptions
~~~~~~~~~~~~~~~~~~

+------------------------+-------+------------------------------------+
| **name**               | **t   | **description**                    |
|                        | ype** |                                    |
+========================+=======+====================================+
| id                     | uuid  | *primary key*                      |
+------------------------+-------+------------------------------------+
| shipment_request_id    | uuid  | *foreign key* to shipment request  |
+------------------------+-------+------------------------------------+
| query_id               | uuid  | *foreign key* to query             |
+------------------------+-------+------------------------------------+
| kind                   | enum  | the kind of the file               |
+------------------------+-------+------------------------------------+
| file                   | s     | url to the document                |
|                        | tring |                                    |
+------------------------+-------+------------------------------------+

RequestForQuotation (RFQ)
--------

.. _function-16:

Function
~~~~~~~~

Users clients or guests can request for quotation when an automated quotation cannot be created.

.. _relations-16:

Relations
~~~~~~~~~

+--------------------+-------------------------------------------------+
| **model name**     | **relation**                                    |
+====================+=================================================+
| Organization       | one-to-many (Organization has-many)             |
+--------------------+-------------------------------------------------+
| Query              | one-to-many (Query has-many)                    |
+--------------------+-------------------------------------------------+

.. _field-descriptions-16:

Field descriptions
~~~~~~~~~~~~~~~~~~

+-----------------+-----------+-------------------------------------------------------------------------------+
|    **name**     | **type**  |                                **description**                                |
+=================+===========+===============================================================================+
| id              | uuid      | *primary key*                                                                 |
+-----------------+-----------+-------------------------------------------------------------------------------+
| organization_id | uuid      | *foreign key* to organization                                                 |
+-----------------+-----------+-------------------------------------------------------------------------------+
| query_id        | uuid      | *foreign key* to query                                                        |
+-----------------+-----------+-------------------------------------------------------------------------------+
| full_name       | string    | full_name of the client (mandatory field)                                     |
+-----------------+-----------+-------------------------------------------------------------------------------+
| email           | string    | client's email with email validation (mandatory field)                        |
+-----------------+-----------+-------------------------------------------------------------------------------+
| phone           | string    | phone number of the client, can be with or without ISD code (mandatory field) |
+-----------------+-----------+-------------------------------------------------------------------------------+
| company_name    | string    | name of the company for which the client belongs to (optional field)          |
+-----------------+-----------+-------------------------------------------------------------------------------+