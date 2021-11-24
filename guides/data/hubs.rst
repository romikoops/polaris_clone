Hubs
=========

The Hub is a mode of transport specific location associated with a Nexus,
that operates a hub in a hub and spoke routing model. The Hub's serve as
start and end points for the Itinerary model. As such these records have
Pre and On Carriage Trucking::Trucking rates and LocalCharges attached to them.

As such having accurate information is crucial to the error free operation of the shop.
To that effect we will be sourcing all crucial data from Carta should it not be
provided by the uploader. The Hub's sheet has only 4 required columns with the remainder
only being required if you want to define anything out fo the default.

Sheet
-----

The Excel sheet must have following columns:

:STATUS:
  **(optional)** The `hub_status` of the Hub. Defaults to "active"

:TYPE:
  **(required)** The `hub_type` of the Hub. This is the Hub's primary mode of transport. Must be one of `ocean|air|truck|rail`

:NAME:
  **(required)** Name of the Hub. If the Legacy::Nexus does not yet exist for the Organization one will be created with this name.

:LOCODE:
  **(required)** The UN/LOCODE of the city. Will be persisted as the Hub's `hub_code`.
  This is used to find the Legacy::Nexus for the Hub. If the Legacy::Nexus does not yet exist for the Organization one will be created with this LOCODE.

:TERMINAL:
  **(required)** The specific Terminal name in the Port if distinguishing between them is necessary.
  Will be stored under the Hub's `terminal` attribute. The TERMINAL column is required to be present, but empty cells are considered valid.

:TERMINAL_CODE:
  **(required)** The code used to identify the Terminal.
  Will be stored under the Hub's `terminal_code` attribute. The TERMINAL_CODE column is required to be present, but empty cells are considered valid.

:LATITUDE:
  **(optional)** Latitude used in geolocation queries. If omitted this will be pulled from Carta using the LOCODE.

:LONGITUDE:
  **(optional)** Longitude used in geolocation queries. If omitted this will be pulled from Carta using the LOCODE.

:COUNTRY:
  **(optional)** The full name of the country the Hub resides in. If omitted this will be pulled from Carta using the LOCODE.

:FULL_ADDRESS:
  **(optional)** The full address of the Hub. If omitted this will be pulled from Carta using the LOCODE's lat/lngs.

:FREE_OUT:
  **(optional)** Whether or not the Hub supports Free Out and should be rendered as such. Defaults to `false`.

:IMPORT_CHARGES:
  **(optional)** Whether this Hub must charge import LocalCharges, regardless of the presence of on carriage. Defaults to `false`

:EXPORT_CHARGES:
  **(optional)** Whether this Hub must charge export LocalCharges, regardless of the presence of pre carriage. Defaults to `false`

:PRE_CARRIAGE:
  **(optional)** Whether bookings made departing from this Hub must include pre carriage. Defaults to `false`.

:ON_CARRIAGE:
  **(optional)** Whether bookings made arriving into this Hub must include on carriage. Defaults to `false`.

Uploading a sheet
-----------------

To upload the Hubs sheet, first log in as an Admin then make your way to
the Hubs page. In the Upload Data box click "Upload Hubs". After the
upload completes you will receive an email with the results of the process.
