Scope
=============

Scopes are how we configure and customise behaviour on our web shops.

local_charges_required_with_trucking
-------------------------------------

When this value is set to `true` the system will mark any offer that involves pre or on carriage
as invalid if there are no local charges included. When `false` The offer will be returned as valid.
Value type: `boolean`
Default value: `true`

Consolidation
#############
consolidations refers to the decision whether or not to bundle all cargo groups together and treat them
as one during calculation. This has direct effects on the charged rate, for example many smaller packages triggering minimums on the rates
would be more expensive that treating them as one consolidated package.

Cargo backend
*************

When this value is set to `true` the system will consider combined weight of cargo items for pricing calculation instead of considering minimum weight price for each cargo item.
Value type: `boolean`
Default value: `false`

Cargo frontend
**************

When this value is set to `true` the system especially the front end will consider weight as `gross weight per group` instead of `gross weight per item`.
Value type: `boolean`
Default value: `false`

Trucking calculation
********************

The weights of the units are combined for all parts of the trucking calculation.
Value type: `boolean`
Default value: `false`

Trucking load_meterage_only
***************************

The system will consolidate the cargo details only to see whether the specified `load_meterage_limit` has been breached.
Beyond that items are calculated individually.

When this value is set to `true` the system will add load meterage only changes if valid.

Value type: `boolean`
Default value: `false`

Trucking comparative
********************

When set to `true` the system will take each item group and sum up their volume, weight and load_meterage weigths separately
and take the largest of the three as the weight value for calculation.

When this value is set to `true` the system will compute sum of all the weights, volume, and load meter weight of cargo items and uses the highest value for pricing calculation.
Value type: `boolean`
Default value: `false`



Voyage Info
#############
This section allows Ops to enable/disable the display of certain pieces of information on the result cards and pdf.


Carrier
*************

When this value is set to `true` the system will display the Carrier name on results.
Value type: `boolean`
Default value: `true`

Service Level
*************

When this value is set to `true` the system will display the TenantVehicle (Service) name on results.
Value type: `boolean`
Default value: `true`

Transshipment Via
*****************

When this value is set to `true` the system will display the transshipment information if present.
Value type: `boolean`
Default value: `true`

Transit Time
*************

When this value is set to `true` the system will display the transit time of the journey, if present.
Value type: `boolean`
Default value: `false`

Pre Carriage Carrier
********************

When this value is set to `true` the system will display the Carrier name of the Pre Carriage service.
Value type: `boolean`
Default value: `false`

Pre Carriage Service
********************

When this value is set to `true` the system will display the TenantVehicle name of the Pre Carriage service.
Value type: `boolean`
Default value: `false`

On Carriage Carrier
*******************

When this value is set to `true` the system will display the Carrier name of the On Carriage service.
Value type: `boolean`
Default value: `false`

On Carriage Service
*******************

When this value is set to `true` the system will display the TenantVehicle name of the On Carriage service.
Value type: `boolean`
Default value: `false`


