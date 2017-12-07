export const adminConstants = {
    GET_HUBS_REQUEST: 'GET_HUBS_REQUEST',
    GET_HUBS_SUCCESS: 'GET_HUBS_SUCCESS',
    GET_HUBS_FAILURE: 'GET_HUBS_FAILURE',

    GET_SHIPMENTS_REQUEST: 'GET_SHIPMENTS_REQUEST',
    GET_SHIPMENTS_SUCCESS: 'GET_SHIPMENTS_SUCCESS',
    GET_SHIPMENTS_FAILURE: 'GET_SHIPMENTS_FAILURE',

    GET_SERVICE_CHARGES_REQUEST: 'GET_SERVICE_CHARGES_REQUEST',
    GET_SERVICE_CHARGES_SUCCESS: 'GET_SERVICE_CHARGES_SUCCESS',
    GET_SERVICE_CHARGES_FAILURE: 'GET_SERVICE_CHARGES_FAILURE',

    GET_SCHEDULES_REQUEST: 'GET_SCHEDULES_REQUEST',
    GET_SCHEDULES_SUCCESS: 'GET_SCHEDULES_SUCCESS',
    GET_SCHEDULES_FAILURE: 'GET_SCHEDULES_FAILURE',

    GET_PRICINGS_REQUEST: 'GET_PRICINGS_REQUEST',
    GET_PRICINGS_SUCCESS: 'GET_PRICINGS_SUCCESS',
    GET_PRICINGS_FAILURE: 'GET_PRICINGS_FAILURE',

    GET_TRUCKING_REQUEST: 'GET_TRUCKING_REQUEST',
    GET_TRUCKING_SUCCESS: 'GET_TRUCKING_SUCCESS',
    GET_TRUCKING_FAILURE: 'GET_TRUCKING_FAILURE',

    FETCH_SHIPMENT_REQUEST: 'FETCH_SHIPMENT_REQUEST',
    FETCH_SHIPMENT_SUCCESS: 'FETCH_SHIPMENT_SUCCESS',
    FETCH_SHIPMENT_FAILURE: 'FETCH_SHIPMENT_FAILURE'
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
