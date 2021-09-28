Services
=========

Background
----------

Any piece of pricing information we receive is always in the context of a "Service" and a "Carrier".

In the real world these are Line Services (Such as "Far East 1") operated by carriers (such as Maersk).
These Line Services are complete loops that traverse the world returning to their start point (though not necessarily with all the same stops)
The length of the journey, number of stops, ship capacity etc all contribute to the cost of the Line Service.

The rates we are receiving are for small slices of these Line Services and serve only an A-to-B portion.
This leads to the LineService being rebranded as Service Level, often describing which is the faster, cheaper or standard option.



Carrier
-------

Carriers are 'global' in our system and (meaning they are shared by all Organizations) and are defined by:

:NAME:
  Name of the Carrier - mostly for display purposes

:CODE:
  A unique identifier for the carrier. Usually the lowercase version of the `name`

TenantVehicle (Service)
------------------------

Our Services are Organization dependent and play a crucial role in connecting together rates in on offer.

The Service are defined by:

:NAME:
  The name of the service for display on results

:MODE_OF_TRANSPORT:
  DEPRECATED: The MOT that this service operates on. Any one of `air|ocean|rail|truck|truck_carriage`

:CARRIER:
  All services belong to a Carrier object in our database

:CARRIER_LOCK:
  Carrier lock ensures that any charges that are to be attached to the offer must be from the same Carrier.
  This is due to some carriers offering Pre/On carriage rates only for freight moved by them