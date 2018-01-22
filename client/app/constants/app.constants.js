export const appConstants = {
    FETCH_CURRENCIES_SUCCESS: 'FETCH_CURRENCIES_SUCCESS',
    FETCH_CURRENCIES_ERROR: 'FETCH_CURRENCIES_ERROR',
    FETCH_CURRENCIES_REQUEST: 'FETCH_CURRENCIES_REQUEST',

    SET_CURRENCY_SUCCESS: 'SET_CURRENCY_SUCCESS',
    SET_CURRENCY_ERROR: 'SET_CURRENCY_ERROR',
    SET_CURRENCY_REQUEST: 'SET_CURRENCY_REQUEST',

    REQUEST_TENANT: 'REQUEST_TENANT',
    RECEIVE_TENANT: 'RECEIVE_TENANT',
    RECEIVE_TENANT_ERROR: 'RECEIVE_TENANT_ERROR',
    INVALIDATE_SUBDOMAIN: 'INVALIDATE_SUBDOMAIN',
};

export const tooltips = {
    'pickup_location': 'Please specify the exact address of the pickup location and double-check for certainty.',
    'start_port_location': 'This is the start port of your shipment.',
    'planned_pickup_date': 'The pickup date is the date on which the good or container are ready to get picked up at the designated address provided below.',
    'shipper_name': 'Example: John Smith, ItsMyCargo IVS.',
    'shipper_street': 'Example Tranehavegaard, 15. Note the address of the shipper is not always the same as the pick up location.',
    'destination_location': 'This information is necessary for the Bill of Lading and should be identical to the address of the consignee. Note that the cargo is only shipped to the destination harbor and not the destination address.',
    'weight': 'The weight of the cargo is needed as containers have a maximum weight load. Containers are consolidated with other LCL shipments and the weight cannot exceed the maximum. Furthermore, weight also determines the price.',
    'insurance': 'Sign an insurance your shipment for the replacement of the goods shipped in case of total or partial loss or damage. Note that if you choose not to pay to insure your shipment, the goods shipped are automatically covered under legal liability standard to the transportation industry.',
    'has_pre_carriage': 'Pre-Carriage is the term given to any inland movement that takes place prior to the good or container being delivered to the port/terminal.',
    'has_on_carriage': 'On-Carriage is the term given to any inland movement that takes place after the good or container is picked up from the port/terminal.',
    'payload_in_kg': 'The gross weight is necessary to determine the chargeable weight. Gross weight is the total raw weight of the cargo + the weight of the packaging.',
    'dangerous_goods': 'Dangerous goods, often recognised as hazardous materials, may be pure chemicals, mixtures of substances, manufactured products or articles which can pose a risk to people, animals or the environment if not properly handled in use or in transport.',
    'customs_clearance': 'Customs Clearance is the documented permission to pass that a national customs authority grants to imported goods so that they can enter the country or to exported goods so that they can leave the country. The custom clearance is typically given to a shipping agent to prove that all applicable customs duties have been paid and the shipment has been approved.',
    'gross_weight': 'The gross weight is necessary to determine the chargeable weight. Gross weight is the total raw weight of the cargo + the weight of the packaging.',
    'size_class': 'Choose the type of container that best accommodates your needs. Dry containers are suitable for most types of cargo, whereas high cube containers ensure that you gain an extra foot in height compared with dry containers. In general, high cube containers are ideal for light, voluminous or bulky cargo. 45 ft Pallet Wide High Cube containers are ideal for the transport of euro-pallet goods, as these containers are slightly wider.',
    'weight_class': 'The net weight is the total weight of the cargo after it has been packed into a container – but excluding the tare weight of the container.',
    'total_price': 'Total Price includes all associated costs incl. service charges.',
    'shipper': 'Shipper (or Consignor) is the person or company who is usually the supplier or owner of commodities shipped.',
    'consignee': "Consignee is the party shown on the bill of lading or air waybill to whom the shipment is consigned. Need not always be the buyer, and in some countries will be the buyer's bank.",
    'notify_party': 'Notify Party is the person or company to be advised by the carrier upon arrival of the goods at the destination port.',
    'hs_code': 'The Harmonized System (HS) is an internationally standardized system of names and numbers to classify traded products.',
    'total_goods_value': 'The total value of goods is necessary to determine matters of insurance.',
    'cargo_notes': 'Information is needed on the amount of packages that are being shipped, and what kind of packages are being dealt with. Include a description of the goods. Alternatively, if you have a packing list, you can upload it below and leave this field blank.',
    'shipment_mots': 'You will receive results for all available modes of transport. Simply select which applies best to your shipment'
};
