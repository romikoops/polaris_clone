export const adminConstants = {
    GET_HUBS_REQUEST: 'GET_HUBS_REQUEST',
    GET_HUBS_SUCCESS: 'GET_HUBS_SUCCESS',
    GET_HUBS_FAILURE: 'GET_HUBS_FAILURE',

    GET_HUB_REQUEST: 'GET_HUB_REQUEST',
    GET_HUB_SUCCESS: 'GET_HUB_SUCCESS',
    GET_HUB_FAILURE: 'GET_HUB_FAILURE',

    GET_ROUTES_REQUEST: 'GET_ROUTES_REQUEST',
    GET_ROUTES_SUCCESS: 'GET_ROUTES_SUCCESS',
    GET_ROUTES_FAILURE: 'GET_ROUTES_FAILURE',

    GET_ROUTE_REQUEST: 'GET_ROUTE_REQUEST',
    GET_ROUTE_SUCCESS: 'GET_ROUTE_SUCCESS',
    GET_ROUTE_FAILURE: 'GET_ROUTE_FAILURE',

    GET_SHIPMENTS_REQUEST: 'GET_SHIPMENTS_REQUEST',
    GET_SHIPMENTS_SUCCESS: 'GET_SHIPMENTS_SUCCESS',
    GET_SHIPMENTS_FAILURE: 'GET_SHIPMENTS_FAILURE',

    GET_DASHBOARD_REQUEST: 'GET_DASHBOARD_REQUEST',
    GET_DASHBOARD_SUCCESS: 'GET_DASHBOARD_SUCCESS',
    GET_DASHBOARD_FAILURE: 'GET_DASHBOARD_FAILURE',

    CONFIRM_SHIPMENT_REQUEST: 'CONFIRM_SHIPMENT_REQUEST',
    CONFIRM_SHIPMENT_SUCCESS: 'CONFIRM_SHIPMENT_SUCCESS',
    CONFIRM_SHIPMENT_FAILURE: 'CONFIRM_SHIPMENT_FAILURE',

    ADMIN_GET_SHIPMENT_REQUEST: 'ADMIN_GET_SHIPMENT_REQUEST',
    ADMIN_GET_SHIPMENT_SUCCESS: 'ADMIN_GET_SHIPMENT_SUCCESS',
    ADMIN_GET_SHIPMENT_FAILURE: 'ADMIN_GET_SHIPMENT_FAILURE',

    GET_SERVICE_CHARGES_REQUEST: 'GET_SERVICE_CHARGES_REQUEST',
    GET_SERVICE_CHARGES_SUCCESS: 'GET_SERVICE_CHARGES_SUCCESS',
    GET_SERVICE_CHARGES_FAILURE: 'GET_SERVICE_CHARGES_FAILURE',

    GET_SCHEDULES_REQUEST: 'GET_SCHEDULES_REQUEST',
    GET_SCHEDULES_SUCCESS: 'GET_SCHEDULES_SUCCESS',
    GET_SCHEDULES_FAILURE: 'GET_SCHEDULES_FAILURE',

    GENERATE_SCHEDULES_REQUEST: 'GENERATE_SCHEDULES_REQUEST',
    GENERATE_SCHEDULES_SUCCESS: 'GENERATE_SCHEDULES_SUCCESS',
    GENERATE_SCHEDULES_FAILURE: 'GENERATE_SCHEDULES_FAILURE',

    GET_PRICINGS_REQUEST: 'GET_PRICINGS_REQUEST',
    GET_PRICINGS_SUCCESS: 'GET_PRICINGS_SUCCESS',
    GET_PRICINGS_FAILURE: 'GET_PRICINGS_FAILURE',

    UPDATE_PRICING_REQUEST: 'UPDATE_PRICING_REQUEST',
    UPDATE_PRICING_SUCCESS: 'UPDATE_PRICING_SUCCESS',
    UPDATE_PRICING_FAILURE: 'UPDATE_PRICING_FAILURE',

    UPDATE_SERVICE_CHARGES_REQUEST: 'UPDATE_SERVICE_CHARGES_REQUEST',
    UPDATE_SERVICE_CHARGES_SUCCESS: 'UPDATE_SERVICE_CHARGES_SUCCESS',
    UPDATE_SERVICE_CHARGES_FAILURE: 'UPDATE_SERVICE_CHARGES_FAILURE',

    GET_CLIENT_PRICINGS_REQUEST: 'GET_CLIENT_PRICINGS_REQUEST',
    GET_CLIENT_PRICINGS_SUCCESS: 'GET_CLIENT_PRICINGS_SUCCESS',
    GET_CLIENT_PRICINGS_FAILURE: 'GET_CLIENT_PRICINGS_FAILURE',

    GET_ROUTE_PRICINGS_REQUEST: 'GET_ROUTE_PRICINGS_REQUEST',
    GET_ROUTE_PRICINGS_SUCCESS: 'GET_ROUTE_PRICINGS_SUCCESS',
    GET_ROUTE_PRICINGS_FAILURE: 'GET_ROUTE_PRICINGS_FAILURE',

    GET_TRUCKING_REQUEST: 'GET_TRUCKING_REQUEST',
    GET_TRUCKING_SUCCESS: 'GET_TRUCKING_SUCCESS',
    GET_TRUCKING_FAILURE: 'GET_TRUCKING_FAILURE',

    GET_CLIENTS_REQUEST: 'GET_CLIENTS_REQUEST',
    GET_CLIENTS_SUCCESS: 'GET_CLIENTS_SUCCESS',
    GET_CLIENTS_FAILURE: 'GET_CLIENTS_FAILURE',

    GET_CLIENT_REQUEST: 'GET_CLIENT_REQUEST',
    GET_CLIENT_SUCCESS: 'GET_CLIENT_SUCCESS',
    GET_CLIENT_FAILURE: 'GET_CLIENT_FAILURE',

    GET_VEHICLE_TYPES_REQUEST: 'GET_VEHICLE_TYPES_REQUEST',
    GET_VEHICLE_TYPES_SUCCESS: 'GET_VEHICLE_TYPES_SUCCESS',
    GET_VEHICLE_TYPES_FAILURE: 'GET_VEHICLE_TYPES_FAILURE',

    FETCH_SHIPMENT_REQUEST: 'FETCH_SHIPMENT_REQUEST',
    FETCH_SHIPMENT_SUCCESS: 'FETCH_SHIPMENT_SUCCESS',
    FETCH_SHIPMENT_FAILURE: 'FETCH_SHIPMENT_FAILURE',

    WIZARD_HUBS_REQUEST: 'WIZARD_HUBS_REQUEST',
    WIZARD_HUBS_SUCCESS: 'WIZARD_HUBS_SUCCESS',
    WIZARD_HUBS_FAILURE: 'WIZARD_HUBS_FAILURE',

    WIZARD_SERVICE_CHARGE_REQUEST: 'WIZARD_SERVICE_CHARGE_REQUEST',
    WIZARD_SERVICE_CHARGE_SUCCESS: 'WIZARD_SERVICE_CHARGE_SUCCESS',
    WIZARD_SERVICE_CHARGE_FAILURE: 'WIZARD_SERVICE_CHARGE_FAILURE',

    WIZARD_PRICINGS_REQUEST: 'WIZARD_PRICINGS_REQUEST',
    WIZARD_PRICINGS_SUCCESS: 'WIZARD_PRICINGS_SUCCESS',
    WIZARD_PRICINGS_FAILURE: 'WIZARD_PRICINGS_FAILURE',

    WIZARD_OPEN_PRICINGS_REQUEST: 'WIZARD_OPEN_PRICINGS_REQUEST',
    WIZARD_OPEN_PRICINGS_SUCCESS: 'WIZARD_OPEN_PRICINGS_SUCCESS',
    WIZARD_OPEN_PRICINGS_FAILURE: 'WIZARD_OPEN_PRICINGS_FAILURE',

    WIZARD_TRUCKING_REQUEST: 'WIZARD_TRUCKING_REQUEST',
    WIZARD_TRUCKING_SUCCESS: 'WIZARD_TRUCKING_SUCCESS',
    WIZARD_TRUCKING_FAILURE: 'WIZARD_TRUCKING_FAILURE',

    NEW_CLIENT_REQUEST: 'NEW_CLIENT_REQUEST',
    NEW_CLIENT_SUCCESS: 'NEW_CLIENT_SUCCESS',
    NEW_CLIENT_FAILURE: 'NEW_CLIENT_FAILURE',

    ACTIVATE_HUB_REQUEST: 'ACTIVATE_HUB_REQUEST',
    ACTIVATE_HUB_SUCCESS: 'ACTIVATE_HUB_SUCCESS',
    ACTIVATE_HUB_FAILURE: 'ACTIVATE_HUB_FAILURE',

    DOCUMENT_ACTION_REQUEST: 'DOCUMENT_ACTION_REQUEST',
    DOCUMENT_ACTION_SUCCESS: 'DOCUMENT_ACTION_SUCCESS',
    DOCUMENT_ACTION_FAILURE: 'DOCUMENT_ACTION_FAILURE',

    VIEW_TRUCKING: 'VIEW_TRUCKING'

};

export const serviceChargeNames = {
    effective_date: 'Effective Date',
    expiration_date: 'Expiration Date',
    terminal_handling_cbm: 'Terminal handling / CBM',
    terminal_handling_ton: 'Terminal Handling /Ton',
    terminal_handling_min: 'Terminal Handling Min',
    lcl_service_cbm: 'LCL Service /CBM',
    lcl_service_ton: 'LCL Service /Ton',
    lcl_service_min: 'LCL Service Min',
    isps: 'ISPS',
    exp_declaration: 'Export Declaration',
    extra_hs_code: 'Extra HS Code',
    doc_fee: 'Document Fee',
    liner_service_fee: 'Liner Service Fee',
    vgm_fee: 'VGM Fee',
    security_fee: 'Security Fee',
    documentation_fee: 'Documentation Fee',
    handling_fee: 'Handling Fee',
    customs_clearance: 'Customs Clearance',
    cfs_terminal_charges: 'CFS Terminal Charges',
    misc_fees: 'Miscellaneous Fees'
};
export const pricingNames = {
    air: 'Air',
    wm_min: 'Weight measure (min)',
    wm_rate: 'Weight Measure (rate)',
    currency: 'Currency',
    kg_per_cbm: 'Kg per CBM',
    heavy_weight: 'Heavy Weight (rate)',
    heavy_wm_min: 'HeavyWeight (min)',
    lcl: 'LCL',
    fcl_20f: 'FCL 20ft',
    rate: 'Container Rate',
    heavy_kg_min: 'Heavy Weight (min kg)',
    fcl_40f: 'FCL 40ft',
    fcl_40f_hq: 'FCL 40ft HQ'
};
export const cargoClassOptions = [
    {value: 'lcl', label: 'LCL'},
    {value: 'fcl_20f', label: 'FCL 20ft'},
    {value: 'fcl_40f', label: 'FCL 40ft'},
    {value: 'fcl_40f_hq', label: 'FCL 40ft HQ'}
];

export const moTOptions = [
    {value: 'rail_default', label: 'Rail'},
    {value: 'air_default', label: 'Air'},
    {value: 'ocean_default', label: 'Ocean'}
];

export const cargoOptions = [
    {value: 'any', label: 'Any'},
    {value: 'dry_goods', label: 'Dry Goods'},
    {value: 'liquid_bulk', label: 'Liquid Bulk'},
    {value: 'gas_bulk', label: 'Gas Bulk'}
];
export const currencyOptions = [
    {value: 'EUR', label: 'EUR'}, {value: 'AUD', label: 'AUD'}, {value: 'BGN', label: 'BGN'}, {value: 'BRL', label: 'BRL'}, {value: 'CAD', label: 'CAD'}, {value: 'CHF', label: 'CHF'}, {value: 'CNY', label: 'CNY'},
    {value: 'CZK', label: 'CZK'}, {value: 'DKK', label: 'DKK'}, {value: 'GBP', label: 'GBP'}, {value: 'HKD', label: 'HKD'}, {value: 'HRK', label: 'HRK'}, {value: 'HUF', label: 'HUF'}, {value: 'IDR', label: 'IDR'},
    {value: 'ILS', label: 'ILS'}, {value: 'INR', label: 'INR'}, {value: 'JPY', label: 'JPY'}, {value: 'KRW', label: 'KRW'}, {value: 'MXN', label: 'MXN'}, {value: 'MYR', label: 'MYR'}, {value: 'NOK', label: 'NOK'},
    {value: 'NZD', label: 'NZD'}, {value: 'PHP', label: 'PHP'}, {value: 'PLN', label: 'PLN'}, {value: 'RON', label: 'RON'}, {value: 'RUB', label: 'RUB'}, {value: 'SEK', label: 'SEK'}, {value: 'SGD', label: 'SGD'},
    {value: 'THB', label: 'THB'}, {value: 'TRY', label: 'TRY'}, {value: 'USD', label: 'USD'}, {value: 'ZAR', label: 'ZAR'},
];

export const rateBasises = [
    {value: 'PER_ITEM', label: 'Per Item'},
    {value: 'PER_CONTAINER', label: 'Per Container'},
    {value: 'PER_SHIPMENT', label: 'Per Shipment'},
    {value: 'PER_CBM_TON', label: 'Per cbm/ton'},
    {value: 'PER_CBM', label: 'Per cbm'}
];

