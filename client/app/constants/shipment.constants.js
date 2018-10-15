export const LOAD_TYPES = [
  {
    name: 'Cargo Item',
    img: 'https://assets.itsmycargo.com/assets/icons/cargo_item.svg',
    code: 'cargo_item'
  },
  {
    name: 'Container',
    img: 'https://assets.itsmycargo.com/assets/icons/container.svg',
    code: 'container'
  }
]

export const SHIPMENT_STAGES = [
  {
    step: 1,
    text: 'Choose shipment type',
    header: 'Choose shipment',
    url: '/'
  },
  {
    step: 2,
    text: 'Shipment Details',
    header: 'Shipment Details',
    url: '/shipment_details'
  },
  {
    step: 3,
    text: 'Choose Offer',
    header: 'Choose Offer',
    url: '/choose_offer'
  },
  {
    step: 4,
    text: 'Final Details',
    header: 'Final Details',
    url: '/final_details'
  },
  {
    step: 5,
    text: 'Booking Confirmation',
    header: 'Booking Confirmation',
    url: '/finish_booking'
  }
]
export const QUOTE_STAGES = [
  {
    step: 1,
    text: 'Choose shipment type',
    header: 'Choose shipment',
    url: '/'
  },
  {
    step: 2,
    text: 'Shipment Details',
    header: 'Shipment Details',
    url: '/shipment_details'
  },
  {
    step: 3,
    text: 'View Quotes',
    header: 'View Quotes',
    url: '/choose_offer'
  }
]
export const documentTypes = {
  packing_sheet: 'Packing Sheet',
  commercial_invoice: 'Commercial Invoice',
  customs_declaration: 'Customs Declaration',
  customs_value_declaration: 'Customs Value Declaration',
  eori: 'EORI',
  certificate_of_origin: 'Certificate Of Origin',
  dangerous_goods: 'Dangerous Goods',
  bill_of_lading: 'Bill of Lading',
  invoice: 'Invoice',
  miscellaneous: 'Miscellaneous'
}
export const shipmentStatii = {
  booking_process_started: 'Booking Process Started',
  finished: 'Finished',
  open: 'Open',
  rejected: 'Rejected',
  archived: 'Archived',
  requested: 'Requested'
}

export const shipmentConstants = {
  CLEAR_LOADING: 'CLEAR_LOADING',

  REUSE_SHIPMENT_REQUEST: 'REUSE_SHIPMENT_REQUEST',
  NEW_SHIPMENT_REQUEST: 'NEW_SHIPMENT_REQUEST',
  NEW_SHIPMENT_SUCCESS: 'NEW_SHIPMENT_SUCCESS',
  NEW_SHIPMENT_FAILURE: 'NEW_SHIPMENT_FAILURE',

  GET_OFFERS_REQUEST: 'GET_OFFERS_REQUEST',
  GET_OFFERS_SUCCESS: 'GET_OFFERS_SUCCESS',
  GET_OFFERS_FAILURE: 'GET_OFFERS_FAILURE',

  SET_SHIPMENT_CONTACTS_REQUEST: 'SET_SHIPMENT_CONTACTS_REQUEST',
  SET_SHIPMENT_CONTACTS_SUCCESS: 'SET_SHIPMENT_CONTACTS_SUCCESS',
  SET_SHIPMENT_CONTACTS_FAILURE: 'SET_SHIPMENT_CONTACTS_FAILURE',

  CHOOSE_OFFER_REQUEST: 'CHOOSE_OFFER_REQUEST',
  CHOOSE_OFFER_SUCCESS: 'CHOOSE_OFFER_SUCCESS',
  CHOOSE_OFFER_FAILURE: 'CHOOSE_OFFER_FAILURE',

  SEND_QUOTES_REQUEST: 'SEND_QUOTES_REQUEST',
  SEND_QUOTES_SUCCESS: 'SEND_QUOTES_SUCCESS',
  SEND_QUOTES_FAILURE: 'SEND_QUOTES_FAILURE',

  REQUEST_SHIPMENT_REQUEST: 'REQUEST_SHIPMENT_REQUEST',
  REQUEST_SHIPMENT_SUCCESS: 'REQUEST_SHIPMENT_SUCCESS',
  REQUEST_SHIPMENT_FAILURE: 'REQUEST_SHIPMENT_FAILURE',

  GETALL_REQUEST: 'USERS_GETALL_REQUEST',
  GETALL_SUCCESS: 'USERS_GETALL_SUCCESS',
  GETALL_FAILURE: 'USERS_GETALL_FAILURE',

  GET_SHIPMENT_REQUEST: 'GET_SHIPMENT_REQUEST',
  GET_SHIPMENT_SUCCESS: 'GET_SHIPMENT_SUCCESS',
  GET_SHIPMENT_FAILURE: 'GET_SHIPMENT_FAILURE',

  DELETE_REQUEST: 'USERS_DELETE_REQUEST',
  DELETE_SUCCESS: 'USERS_DELETE_SUCCESS',
  DELETE_FAILURE: 'USERS_DELETE_FAILURE',

  SET_ERROR: 'SET_ERROR',

  FETCH_SHIPMENT_REQUEST: 'FETCH_SHIPMENT_REQUEST',
  FETCH_SHIPMENT_SUCCESS: 'FETCH_SHIPMENT_SUCCESS',
  FETCH_SHIPMENT_FAILURE: 'FETCH_SHIPMENT_FAILURE',

  SHIPMENT_UPLOAD_DOCUMENT_REQUEST: 'SHIPMENT_UPLOAD_DOCUMENT_REQUEST',
  SHIPMENT_UPLOAD_DOCUMENT_SUCCESS: 'SHIPMENT_UPLOAD_DOCUMENT_SUCCESS',
  SHIPMENT_UPLOAD_DOCUMENT_FAILURE: 'SHIPMENT_UPLOAD_DOCUMENT_FAILURE',

  SHIPMENT_DELETE_DOCUMENT_REQUEST: 'SHIPMENT_DELETE_DOCUMENT_REQUEST',
  SHIPMENT_DELETE_DOCUMENT_SUCCESS: 'SHIPMENT_DELETE_DOCUMENT_SUCCESS',
  SHIPMENT_DELETE_DOCUMENT_FAILURE: 'SHIPMENT_DELETE_DOCUMENT_FAILURE',

  SHIPMENT_UPDATE_CURRENCY_REQUEST: 'SHIPMENT_UPDATE_CURRENCY_REQUEST',
  SHIPMENT_UPDATE_CURRENCY_SUCCESS: 'SHIPMENT_UPDATE_CURRENCY_SUCCESS',
  SHIPMENT_UPDATE_CURRENCY_FAILURE: 'SHIPMENT_UPDATE_CURRENCY_FAILURE',

  GET_NEW_DATE_OFFERS_REQUEST: 'GET_NEW_DATE_OFFERS_REQUEST',
  GET_NEW_DATE_OFFERS_SUCCESS: 'GET_NEW_DATE_OFFERS_SUCCESS',
  GET_NEW_DATE_OFFERS_FAILURE: 'GET_NEW_DATE_OFFERS_FAILURE',

  SHIPMENT_UPDATE_CONTACT_REQUEST: 'SHIPMENT_UPDATE_CONTACT_REQUEST',
  SHIPMENT_UPDATE_CONTACT_SUCCESS: 'SHIPMENT_UPDATE_CONTACT_SUCCESS',
  SHIPMENT_UPDATE_CONTACT_FAILURE: 'SHIPMENT_UPDATE_CONTACT_FAILURE',

  SHIPMENT_GET_NOTES_REQUEST: 'SHIPMENT_GET_NOTES_REQUEST',
  SHIPMENT_GET_NOTES_SUCCESS: 'SHIPMENT_GET_NOTES_SUCCESS',
  SHIPMENT_GET_NOTES_FAILURE: 'SHIPMENT_GET_NOTES_FAILURE',
  CLEAR_SHIPMENTS: 'CLEAR_SHIPMENTS',

  SHIPMENT_GET_SCHEDULES_REQUEST: 'SHIPMENT_GET_SCHEDULES_REQUEST',
  SHIPMENT_GET_SCHEDULES_SUCCESS: 'SHIPMENT_GET_SCHEDULES_SUCCESS',
  SHIPMENT_GET_SCHEDULES_FAILURE: 'SHIPMENT_GET_SCHEDULES_FAILURE'
}

export const activeRoutesData = [
  {
    header: 'New York',
    subheader: 'USA',

    image: 'https://assets.itsmycargo.com/assets/cityimages/NY_sm.jpg'
  },
  {
    header: 'Shanghai',
    subheader: 'China',
    image: 'https://assets.itsmycargo.com/assets/cityimages/shanghai_sm.jpg'
  },
  {
    header: 'Singapore',
    subheader: 'Singapore',

    image: 'https://assets.itsmycargo.com/assets/cityimages/Singapore_sm.jpg'
  },
  {
    header: 'Seoul',
    subheader: 'South Korea',

    image: 'https://assets.itsmycargo.com/assets/cityimages/seoul_sm.jpg'
  },
  {
    header: 'Hanoi',
    subheader: 'Vietnam',

    image: 'https://assets.itsmycargo.com/assets/cityimages/Hanoi_sm.jpg'
  },
  {
    header: 'Shenzhen',
    subheader: 'China',

    image: 'https://assets.itsmycargo.com/assets/cityimages/Shenzhen_sm.jpg'
  }
]

export const fclChargeGlossary = {
  BAS: 'Basic Ocean Freight',
  CFD: 'Congestion Fee Destination',
  CFO: 'Congestion Fee Origin',
  DDF: 'Documentation fee - Destination',
  DHC: 'Terminal Handling Service - Destination',
  DPA: 'Arbitrary - Destination',
  ERS: 'Emergency Risk Surcharge',
  EXP: 'Export Service',
  IHE: 'Inland Haulage Export',
  IMP: 'Import Service',
  LSS: 'Low Sulphur Surcharge',
  ODF: 'Documentation Fee Origin',
  OHC: 'Terminal Handling Service - Origin',
  OPA: 'Arbitrary - Origin',
  PSS: 'Peak Season Surcharge',
  SBF: 'Standard Bunker Adjustment Factor',
  SOC: 'Shipper Owned container',
  NOR: 'Non Operating Refer container',
  EMPTY: 'Empty Container',
  CY: 'Container Yard',
  SD: 'Store Door',
  VGM: 'Verified Gross Mass',
  '20DRY': '20 Dry container',
  '40DRY': '40 Dry container',
  '40HDRY': '40 High Cube Dry Container',
  '45HDRY': '45 High Cube Dry Container',
  ENS: 'Entry Summary Declaration',
  STF: 'Stuffing Fee',
  HBD: 'Harbour Duties'
}

export const lclChargeGlossary = {
  BAS: 'Basic Freight',
  HAS: 'Heavy Weight Freight',
  OHC: 'Origin Handling Costs',
  DHC: 'Destination Handling Costs',
  CUSTOMS: 'Customs Fee',
  CFS: 'CFS Handling',
  LS: 'Liner Service Fee',
  LCLS: 'LCL Handling Fee',
  ISPS: 'ISPS Fee',
  DDF: 'Destination Document Fee',
  ODF: 'Origin Document Fee',
  EXP: 'Export Fee',
  VGM: 'Verified Gross Mass',
  ENS: 'Entry Summary Declaration',
  TRF: 'Telex Release Fee'
}
export const chargeGlossary = {
  BAS: 'Basic Freight',
  HAS: 'Heavy Weight Freight',
  effective_date: 'Effective Date',
  expiration_date: 'Expiration Date',
  rate_basis: 'Rate Basis',
  hw_rate_basis: 'Heavy Weight Rate Basis',
  base_rate: 'Base Rate',
  base: 'Base',
  congestion: 'Congestion Charge',
  rate: 'Rate',
  currency: 'Currency',
  cbm: 'CBM',
  ton: 'Ton',
  kg: 'Kg',
  fee: 'Fee',
  limit: 'Limit',
  extra: 'Extra',
  min: 'Minimum',
  max: 'Maximum',
  PER_ITEM: 'Per Item',
  PER_CONTAINER: 'Per Container',
  PER_SHIPMENT: 'Per Shipment',
  PER_CBM_TON: 'Per cbm/ton',
  PER_BILL: 'Per B/L',
  PER_CBM: 'Per cbm',
  PER_WM: 'Per W/M',
  PER_KG: 'Per kg',
  PER_KG_RANGE: 'Per kg range',
  PER_TON: 'Per ton',
  PERCENTAGE: 'Percentage',
  FSC: 'Fuel Surcharge',
  ULT: 'Loading/Unloading Time',
  VAT: 'VAT',
  vat: 'VAT',
  CCC: 'Congestion Charge',
  DLF: 'Delivery Fee',
  PUF: 'Pickup Fee',
  OHC: 'Origin Handling Costs',
  DHC: 'Destination Handling Costs',
  ISPS: 'ISPS Fee',
  DDF: 'Destination Document Fee',
  ODF: 'Origin Document Fee',
  ENS: 'Entry Summary Declaration',
  TRF: 'Telex Release Fee',
  OMR: 'Over Max Rate',
  PCR: 'Per CMB Rate',
  PWF: 'Waiting Fee',
  min_value: 'Minimum Value',
  min_weight: 'Min. Weight',
  max_weight: 'Max. Weight',
  min_distance: 'Min. Distance',
  max_distance: 'Max. Distance',
  city: 'City',
  province: 'Province',
  value: 'Rate',
  delivery_fee: 'Delivery Fee',
  pickup_fee: 'Pickup Fee',
  THC: 'Terminal Handling Fee',
  DOC: 'Documentation Fee',
  SC: 'Service Charge',
  HDL: 'Handling Fee',
  HDF: 'Harbour Dues',
  CGT: 'Congestion Tax',
  FDC: 'Fairways Due Charge',
  VGM: 'Verified Gross Mass',
  CUST: 'Customs Fee',
  max_kg: 'Max. Kg',
  min_kg: 'Min. Kg',
  min_cbm: 'Min. Cbm',
  max_cbm: 'Max. Cbm',
  min_km: 'Min. Km',
  max_km: 'Max. Km'
}

export const incoterms = [
  { value: 'EXW', label: 'EXW - Ex Works (named place of delivery)', type: 'any' },
  { value: 'FCA', label: 'FCA - Free Carrier (named place of delivery)', type: 'any' },
  { value: 'CPT', label: 'CPT - Carriage Paid To (named place of destination)', type: 'any' },
  {
    value: 'CIP',
    label: 'CIP - Carriage and Insurance Paid to (named place of destination)',
    type: 'any'
  },
  {
    value: 'DAT',
    label: 'DAT - Delivered at Terminal (named terminal at port or place of destination)',
    type: 'any'
  },
  { value: 'DAP', label: 'DAP - Delivered at Place (named place of destination)', type: 'any' },
  { value: 'DDP', label: 'DDP - Delivered Duty Paid (named place of destination)', type: 'any' },
  { value: 'FAS', label: 'FAS - Free Alongside Ship (named port of shipment)' },
  { value: 'FOB', label: 'FOB - Free on Board (named port of shipment)' },
  { value: 'CFR', label: 'CFR - Cost and Freight (named port of destination)' },
  { value: 'CIF', label: 'CIF - Cost, Insurance and Freight (named port of destination)' }
]

export const colliTypes = [
  {
    x: 1016,
    y: 1219,
    key: '1016 × 1219',
    label: '1016 × 1219 Pallet: North America'
  },
  {
    x: 1000,
    y: 1200,
    key: '1000 × 1200',
    label: '1000 × 1200 Pallet: Europe, Asia'
  },
  {
    x: 1165,
    y: 1165,
    key: '1165 × 1165',
    label: '1165 × 1165 Pallet: Australia'
  },
  {
    x: 1067,
    y: 1067,
    key: '1067 × 1067',
    label: '1067 × 1067 Pallet: North America, Europe, Asia'
  },
  {
    x: 1100,
    y: 1100,
    key: '1100 × 1100',
    label: '1100 × 1100 Pallet: Asia'
  },
  {
    x: 800,
    y: 1200,
    key: '800 × 1200',
    label: '800 × 1200 Pallet: Europe'
  },
  { key: 'Cartons', label: 'Cartons' },
  { key: 'Crates', label: 'Crates' },
  { key: 'Rolls', label: 'Rolls' }
]
