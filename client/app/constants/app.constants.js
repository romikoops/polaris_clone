export const appConstants = {
  FETCH_CURRENCIES_SUCCESS: 'FETCH_CURRENCIES_SUCCESS',
  FETCH_CURRENCIES_ERROR: 'FETCH_CURRENCIES_ERROR',
  FETCH_CURRENCIES_REQUEST: 'FETCH_CURRENCIES_REQUEST',

  FETCH_COUNTRIES_SUCCESS: 'FETCH_COUNTRIES_SUCCESS',
  FETCH_COUNTRIES_ERROR: 'FETCH_COUNTRIES_ERROR',
  FETCH_COUNTRIES_REQUEST: 'FETCH_COUNTRIES_REQUEST',

  REFRESH_CURRENCIES_SUCCESS: 'REFRESH_CURRENCIES_SUCCESS',
  REFRESH_CURRENCIES_ERROR: 'REFRESH_CURRENCIES_ERROR',
  REFRESH_CURRENCIES_REQUEST: 'REFRESH_CURRENCIES_REQUEST',

  SET_CURRENCY_SUCCESS: 'SET_CURRENCY_SUCCESS',
  SET_CURRENCY_ERROR: 'SET_CURRENCY_ERROR',
  SET_CURRENCY_REQUEST: 'SET_CURRENCY_REQUEST',

  SET_TENANT_ID_SUCCESS: 'SET_TENANT_ID_SUCCESS',
  SET_TENANT_ID_ERROR: 'SET_TENANT_ID_ERROR',
  SET_TENANT_ID_REQUEST: 'SET_TENANT_ID_REQUEST',

  SET_TENANT_SUCCESS: 'SET_TENANT_SUCCESS',
  SET_TENANT_ERROR: 'SET_TENANT_ERROR',
  SET_TENANT_REQUEST: 'SET_TENANT_REQUEST',

  SET_TENANTS_SUCCESS: 'SET_TENANTS_SUCCESS',
  SET_TENANTS_ERROR: 'SET_TENANTS_ERROR',
  SET_TENANTS_REQUEST: 'SET_TENANTS_REQUEST',

  OVERRIDE_TENANT_SUCCESS: 'OVERRIDE_TENANT_SUCCESS',
  OVERRIDE_TENANT_ERROR: 'OVERRIDE_TENANT_ERROR',
  OVERRIDE_TENANT_REQUEST: 'OVERRIDE_TENANT_REQUEST',

  REQUEST_TENANT: 'REQUEST_TENANT',
  RECEIVE_TENANT: 'RECEIVE_TENANT',
  RECEIVE_TENANTS: 'RECEIVE_TENANTS',
  RECEIVE_TENANT_ERROR: 'RECEIVE_TENANT_ERROR',
  INVALIDATE_SUBDOMAIN: 'INVALIDATE_SUBDOMAIN',
  SET_THEME: 'SET_THEME',
  FETCH_CURRENCIES_FOR_BASE_REQUEST: 'FETCH_CURRENCIES_FOR_BASE_REQUEST',
  FETCH_CURRENCIES_FOR_BASE_SUCCESS: 'FETCH_CURRENCIES_FOR_BASE_SUCCESS',
  FETCH_CURRENCIES_FOR_BASE_ERROR: 'FETCH_CURRENCIES_FOR_BASE_ERROR',
  TOGGLE_CURRENCIES_REQUEST: 'TOGGLE_CURRENCIES_REQUEST',
  TOGGLE_CURRENCIES_SUCCESS: 'TOGGLE_CURRENCIES_SUCCESS',
  TOGGLE_CURRENCIES_ERROR: 'TOGGLE_CURRENCIES_ERROR'
}

export const tooltips = {
  customs_credit:
    'Customs credit is a scheme which makes it easier to pay customs duties and taxes. Your payment deadline will be deferred because customs duties and taxes which accrue during a month will fall due for payment on the 18th of the following month. Without customs credit, you will have to pay the taxes at the time of customs clearance.',
  pickup_location:
    'Please specify the exact address of the pickup location and double-check for certainty.',
  start_port_location: 'This is the start port of your shipment.',
  planned_pickup_date: 'Date states when cargo is ready for pickup. Pick-Up of Cargo will usually occur within the first 48 hours of this date.',
  planned_dropoff_date:
    'Date states when you chose to deliver cargo to appointed terminal',
  shipper_name: 'Example: John Smith, ItsMyCargo IVS.',
  shipper_street:
    'Example Tranehavegaard, 15. Note the address of the shipper is not always the same as the pick up location.',
  destination_location:
    'This information is necessary for the Bill of Lading and should be identical to the address of the consignee. Note that the cargo is only shipped to the destination harbor and not the destination address.',
  weight:
    'The weight of the cargo is needed as containers have a maximum weight load. Containers are consolidated with other LCL shipments and the weight cannot exceed the maximum. Furthermore, weight also determines the price.',
  insurance:
    'Sign an insurance for your shipment for the replacement of the goods shipped in case of total or partial loss or damage. Note that if you choose not to pay to insure your shipment, the goods shipped are automatically covered under legal liability standard to the transportation industry.',
  has_pre_carriage:
    'Pre-Carriage is the term given to any inland movement that takes place prior to the good or container being delivered to the port/terminal.',
  has_on_carriage:
    'On-Carriage is the term given to any inland movement that takes place after the good or container is picked up from the port/terminal.',
  payload_in_kg:
    'The gross weight is necessary to determine the chargeable weight. Gross weight is the total raw weight of the cargo + the weight of the packaging.',
  dangerous_goods:
    'Dangerous goods, often recognised as hazardous materials, may be pure chemicals, mixtures of substances, manufactured products or articles which can pose a risk to people, animals or the environment if not properly handled in use or in transport.',
  non_stackable:
    'Sometimes cargo comes in shapes and sizes that is impossible to stack. It may also be cargo of fragile nature. When cargo is non-stackable, additional charges incur to cover for the excess free space in the container.',
  customs_clearance:
    'Customs Clearance is the documented permission to pass that a national customs authority grants to imported goods so that they can enter the country or to exported goods so that they can leave the country. The custom clearance is typically given to a shipping agent to prove that all applicable customs duties have been paid and the shipment has been approved.',
  gross_weight:
    'The gross weight is necessary to determine the chargeable weight. Gross weight is the total raw weight of the cargo + the weight of the packaging.',
  size_class:
    'Choose the type of container that accommodates your needs. General inner dimensions for Dry Containers (Remark: Specification may vary depending on Shipping Line). \n 20’GP – 5,900m x 2,350m x 2,393m    (door width 2,342m // door height 2,280m) \n4 0’GP – 12,036m x 2,350m x 2,392m (door width 2,340m // door height 2,280m) \n40 ’HC – 12,036m x 2,350m x 2,697m (door width 2,340m // door height 2,2585m)',
  weight_class:
    'The net weight is the total weight of the cargo after it has been packed into a container – but excluding the tare weight of the container.',
  total_price: 'Total Price includes all associated costs incl. service charges.',
  sender:
    'Shipper (or Consignor) is the person or company who is usually the supplier or owner of commodities shipped.',
  receiver:
    "Consignee is the party shown on the bill of lading or air waybill to whom the shipment is consigned. Need not always be the buyer, and in some countries will be the buyer's bank.",
  notifyee:
    'Notifyee is the person or company to be advised by the carrier upon arrival of the goods at the destination port.',
  hs_code:
    'The Harmonized System (HS) is an internationally standardized system of names and numbers to classify traded products.',
  total_goods_value: 'The total value of goods is necessary to determine matters of insurance.',
  cargo_notes:
    'Information is needed on the amount of packages that are being shipped, and what kind of packages are being dealt with. Include a description of the goods. Alternatively, if you have a packing list, you can upload it below and leave this field blank.',
  shipment_mots:
    'You will receive results for all available modes of transport. Simply select which applies best to your shipment',
  side_lifter:
    'If you require the container to be lifted down on the ground for loading/unloading you order side lifter.',
  chassis:
    'If you load/unload the container from ramp you order chassis. (Container is NOT lifted down on the ground).',
  customs_pre_carriage:
    'Export Customs is not applicable for shipments without delivery to the port (pre-carriage).',
  customs_on_carriage:
    'Import Customs is not applicable for shipments without delivery from the port (on-carriage).',
  charge_icons: {
    pre_carriage: 'Pick-up',
    on_carriage: 'Delivery',
    documentation: {
      origin: 'Origin Local Charges',
      destination: 'Destination Local Charges'
    },
    freight: 'Freight'
  }
}

// Tool tips menu admin
export const adminMenutooltip = {
  shipments:
    'Effectively manage your shipments. Get an overview of requested, open & finished shipments. In addition, it is possible to accept, edit & decline shipments',
  hubs:
    'Manage your hubs as well as activating/deactivating them. Effectively, it decides whether or not cargo is accepted in these locations',
  pricing:
    'Manage everything that has to with prices, service charges, fees etc. Open prices & dedicated prices can be changed and reflected in the shop immediately',
  schedules: 'Administrate sailing schedules by a simple upload',
  trucking:
    'Update prices, fees, charges for trucking. Here zip code & city sheets can be uploaded',
  clients: 'Manage negotiated routes, prices and fees for your existing clients',
  routes: 'Configure all the routes displayed in the shop',
  setup:
    'This option is only for the very first configuration of the shop or if you want to reset the shop system with new data. IMPORTANT: this will overwrite all existing data',
  settings:
    'Adjust your account settings here.'
}

// Dashboard
export const adminDashboard = {
  dashboard: 'Get a quick glance of shipments, hubs, sailing schedules and clients',
  requested:
    'Shipments requested from the open or client shop. Investigate the shipment data and evaluate whether to accept, edit or decline the shipment',
  open:
    'Shipments that have been accepted or edited. Shipments in this category requires transportation',
  finished: 'Shipments that have been processed and will be saved as history',
  routes:
    'Configure all the routes displayed in the shop. Add & delete routes to be up to date about what you offer in the shop',
  schedules: 'Administrate sailing schedules by a simple upload',
  hubs:
    'Manage your hubs as well as activating/deactivating them. Effectively, it decides whether or not cargo is accepted in these locations',
  clients: 'Manage negotiated routes, prices and fees for your existing clients'
}

// Hubs
export const adminHubs = {
  manage:
    'Manage your hubs as well as activating/deactivating them. Effectively, it decides whether or not cargo is accepted in these locations',
  upload: 'configure all operated hubs with an Excel upload',
  overview: 'Overview of all hubs activated in the shop and where you accept shipments'
}

// Hub is clicked
export const adminClicked = {
  related: 'A glance of all the Hubs that are related to the chosen Hub',
  routes: 'Routes where the chosen Hub is involved',
  schedules: 'Overview of departures with the chosen Hub involved'
}

// Pricings
export const adminPricing = {
  pricing:
    'Manage everything that has to with prices, service charges, fees etc. Open prices & dedicated prices can be changed and reflected in the shop immediately',
  upload_lcl: 'By using the Excel template you can update all your LCL rates with one upload',
  upload_fcl: 'by using the Excel template you can update all your FCL rates with one upload',
  routes:
    'Adjust prices, fees and charges on the go. Find the relevant route and update the pricing data',
  clients: 'Manage negotiated routes, prices and fees for your existing clients'
}

// Schedules
export const adminSchedules = {
  upload_excel: 'Upload the Excel template to update schedules for train, air, ocean & trucking',
  auto_generate:
    'This feature makes it possible to have schedules for all modes of transport to run in a loop to avoid Excel upload. Essentially, the schedules can run in a loop if tendencies can be spotted in your sailing schedules'
}

// Trucking
export const adminTrucking = {
  manage: 'Manage prices for pre & on carriage from zip codes or cities',
  upload_city:
    'In some places zip codes are not available hence prices are based on cities instead. Upload the Excel template here',
  upload_zip: 'If prices are calculated on zip codes the Excel template can be uploaded here',
  hubs: 'Hubs are consolidation points for line haul'
}

// Clients
export const adminClientsTooltips = {
  manage: 'Manage negotiated routes, prices and fees for your existing clients',
  upload: 'Upload the Excel template in order to adjust all your clients prices',
  change: 'Change prices, fees, charges for an individual client and manage negotiated routes'
}

// Routes
export const adminRoutesTooltips = {
  upload: 'Upload Excel template to update routes',
  new: 'Add another route to the system',
  related: 'See related Hubs and sailing schedules and configure all routes displayed in the shop'
}

export const adminRoutesClickedTooltips = {
  // Route clicked

  // 1. Related hubs:
  1: 'A glance of all the Hubs that are related to the chosen route',
  // 2. Routes:
  2: 'The chosen route for all modes of transport',
  // 3. Schedules:
  3: 'Relevant overview of sailing schedules of the chosen route'
}
