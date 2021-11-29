LocalCharge
===========

Regardless of mode of transport every time cargo is loaded and unloaded, fees are incurred.
The LocalCharge upload sheet allows you to upload these fees for specific Hubs, limited by Groups,
Cargo Class, Counterpart Hub and in which direction the trade is flowing.

Sheet
-----

The Excel sheet must have following columns:

:GROUP_ID:
  **(optional)** The id of the Group you wish to attach this to. If left blank along with `GROUP_NAME`, the LocalCharge will
  be attached to the "default" Group.

:GROUP_NAME:
  **(optional)** The name of the Group you wish to attach this to. If left blank along with `GROUP_ID`, the LocalCharge will
  be attached to the "default" Group.

:EFFECTIVE_DATE:
  **(required)** The date this rate comes into effect.

:EXPIRATION_DATE:
  **(required)** The date this rate stops being valid.

:HUB:
  **(required)** The name of the Hub you wish the LocalCharge to be attached to.

:LOCODE:
  **(required)** The UN/LOCODE of the Nexus the Hub you are targeting belongs to.

:TERMINAL:
  **(required)** The `terminal` of the Hub you are targeting. The presence of the column is required but empty cells are allowed.

:COUNTRY:
  **(required)** The name of the Country the Hub you are targeting resides in.

:COUNTERPART_HUB:
  **(required)** The name of the Hub you wish the LocalCharge to be attached to as counterpart.

:COUNTERPART_LOCODE:
  **(required)** The UN/LOCODE of the Nexus the Hub you are targeting belongs to as counterpart.

:COUNTERPART_TERMINAL:
  **(required)** The `terminal` of the Hub you are targeting as counterpart. The presence of the column is required but empty cells are allowed.

:COUNTERPART_COUNTRY:
  **(required)** The name of the Country the Hub you are targeting as counterpart resides in.

:SERVICE:
  **(required)** The service of the LocalCharge.  If omitted default value of 'standard'  is used.

:CARRIER:
  **(required)** The CARRIER of the rate.  If omitted default value of the Organization's name is used.

:FEE_CODE:
  **(required)** A short code to identify the fee.

:FEE_NAME:
  **(required)** The name of the fee.

:MOT:
  **(required)** The Mode of Transport this rate applies to. Also the `hub_type` of the Hub being targeted.

:CARGO_CLASS:
  **(required)** The Cargo Class of the fee. Formerly :LOAD_TYPE:, both will work but at least one must be present.

:DIRECTION:
  **(required)** Whether this fee applies to goods entering or leaving the port. Valid inputs are "export" and "import".

:CURRENCY:
  **(required)** The three letter ISO code for the currency the fee should be charged in.

:RATE_BASIS:
  **(required)** The the type of fee it is - ie the way in which the fee total should be calculated.

:MINIMUM:
  **(required)** The minimum amount that can be charged for this fee. Will default to zero.

:MAXIMUM:
  **(required)** The maximum amount that can be charged for this fee.

:BASE:
  **(required)** The factor by to be used in rate bases that include "_X_". If a RATE_BASIS that includes "_X_" then this value is necessary.

:DANGEROUS:
  **(required)** If this fee applies to dangerous goods or not.

The remaining columns are all required but content is only necessary dependent on the Rate Basis matching.

:TON:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_TON".

:CBM:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_CBM".

:KG:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_KG".

:ITEM:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_ITEM".

:SHIPMENT:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_SHIPMENT".

:BILL:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_BILL".

:CONTAINER:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_CONTAINER".

:WM:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_WM".

:PERCENTAGE:
  **(required)** The value to be used in the fee when the RATE_BASIS is "PER_PERCENTAGE".

:RANGE_MIN:
  **(required)** The lower limit of the range to be used in determining the correct fee to apply
  Values are in the unit being calculated (eg cbm with PER_CBM_RANGE).

:RANGE_MAX:
  **(required)** The upper limit of the range to be used in determining the correct fee to apply
  Values are in the unit being calculated (eg cbm with PER_CBM_RANGE).
  Upper bounds of ranges are exclusive. E.g. if the value being compared equals the value in the cell,
  it will not match with this rate.

Uploading a sheet
-----------------

To upload the LocalCharges sheet, first log in as ad Admin then make your way to
the Hubs page. In the Upload Data box click "Upload Local charges". After the
upload completes you will receive an email with the results of the process.
