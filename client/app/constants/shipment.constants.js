export const LOAD_TYPES = [
  {
    name: 'Cargo Item Shipment',
    img: 'https://assets.itsmycargo.com/assets/images/MoT/parcel.png',
    code: 'cargoItem'
  },
  {
    name: 'Full Container Shipment',
    img: 'https://assets.itsmycargo.com/assets/images/welcome/container.png',
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
    text: 'Booking overview & details',
    header: 'Booking Details',
    url: '/booking_details'
  },
  {
    step: 5,
    text: 'Booking Confirmation',
    header: 'Booking Confirmation',
    url: '/finish_booking'
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
  invoice: 'Invoice'
}

export const shipmentConstants = {
  CLEAR_LOADING: 'CLEAR_LOADING',

  NEW_SHIPMENT_REQUEST: 'NEW_SHIPMENT_REQUEST',
  NEW_SHIPMENT_SUCCESS: 'NEW_SHIPMENT_SUCCESS',
  NEW_SHIPMENT_FAILURE: 'NEW_SHIPMENT_FAILURE',

  SET_SHIPMENT_DETAILS_REQUEST: 'SET_SHIPMENT_DETAILS_REQUEST',
  SET_SHIPMENT_DETAILS_SUCCESS: 'SET_SHIPMENT_DETAILS_SUCCESS',
  SET_SHIPMENT_DETAILS_FAILURE: 'SET_SHIPMENT_DETAILS_FAILURE',

  SET_SHIPMENT_CONTACTS_REQUEST: 'SET_SHIPMENT_CONTACTS_REQUEST',
  SET_SHIPMENT_CONTACTS_SUCCESS: 'SET_SHIPMENT_CONTACTS_SUCCESS',
  SET_SHIPMENT_CONTACTS_FAILURE: 'SET_SHIPMENT_CONTACTS_FAILURE',

  SET_SHIPMENT_ROUTE_REQUEST: 'SET_SHIPMENT_ROUTE_REQUEST',
  SET_SHIPMENT_ROUTE_SUCCESS: 'SET_SHIPMENT_ROUTE_SUCCESS',
  SET_SHIPMENT_ROUTE_FAILURE: 'SET_SHIPMENT_ROUTE_FAILURE',

  GETALL_REQUEST: 'USERS_GETALL_REQUEST',
  GETALL_SUCCESS: 'USERS_GETALL_SUCCESS',
  GETALL_FAILURE: 'USERS_GETALL_FAILURE',

  GET_SHIPMENT_REQUEST: 'GET_SHIPMENT_REQUEST',
  GET_SHIPMENT_SUCCESS: 'GET_SHIPMENT_SUCCESS',
  GET_SHIPMENT_FAILURE: 'GET_SHIPMENT_FAILURE',

  DELETE_REQUEST: 'USERS_DELETE_REQUEST',
  DELETE_SUCCESS: 'USERS_DELETE_SUCCESS',
  DELETE_FAILURE: 'USERS_DELETE_FAILURE',

  FETCH_SHIPMENT_REQUEST: 'FETCH_SHIPMENT_REQUEST',
  FETCH_SHIPMENT_SUCCESS: 'FETCH_SHIPMENT_SUCCESS',
  FETCH_SHIPMENT_FAILURE: 'FETCH_SHIPMENT_FAILURE',

  SHIPMENT_UPLOAD_DOCUMENT_REQUEST: 'SHIPMENT_UPLOAD_DOCUMENT_REQUEST',
  SHIPMENT_UPLOAD_DOCUMENT_SUCCESS: 'SHIPMENT_UPLOAD_DOCUMENT_SUCCESS',
  SHIPMENT_UPLOAD_DOCUMENT_FAILURE: 'SHIPMENT_UPLOAD_DOCUMENT_FAILURE',

  SHIPMENT_DELETE_DOCUMENT_REQUEST: 'SHIPMENT_DELETE_DOCUMENT_REQUEST',
  SHIPMENT_DELETE_DOCUMENT_SUCCESS: 'SHIPMENT_DELETE_DOCUMENT_SUCCESS',
  SHIPMENT_DELETE_DOCUMENT_FAILURE: 'SHIPMENT_DELETE_DOCUMENT_FAILURE',

  ACCEPT_SHIPMENT_REQUEST: 'ACCEPT_SHIPMENT_REQUEST',
  ACCEPT_SHIPMENT_SUCCESS: 'ACCEPT_SHIPMENT_SUCCESS',
  ACCEPT_SHIPMENT_FAILURE: 'ACCEPT_SHIPMENT_FAILURE'
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
  rate_basis: 'Rate Basis',
  base_rate: 'Base Rate',
  base: 'Base',
  rate: 'Rate',
  currency: 'Currency',
  cbm: 'CBM',
  ton: 'Ton',
  kg: 'Kg',
  min: 'Minimum',
  PER_ITEM: 'Per Item',
  PER_CONTAINER: 'Per Container',
  PER_SHIPMENT: 'Per Shipment',
  PER_CBM_TON: 'Per cbm/ton',
  PER_CBM: 'Per cbm',
  FSC: 'Fuel Surcharge',
  ULT: 'Loading/Unloading Time',
  VAT: 'VAT',
  CCC: 'Congestion Charge',
  DLF: 'Delivery Fee',
  PUF: 'Pickup Fee',
  OMR: 'Over Max Rate',
  PCR: 'Per CMB Rate',
  PWF: 'Waiting Fee',
  min_value: 'Minimum Value',
  min_weight: 'Min. Weight',
  max_weight: 'Max. Weight',
  min_distance: 'Min. Distance',
  max_distance: 'Max. Distance',
  min_cbm: 'Min. CBM',
  max_cbm: 'Max. CBM',
  city: 'City',
  province: 'Province',
  value: 'Rate',
  delivery_fee: 'Delivery Fee',
  pickup_fee: 'Pickup Fee'
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
