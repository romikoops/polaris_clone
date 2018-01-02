export const SHIPMENT_TYPES = [
    {
        name: 'LCL Shipment',
        img: 'https://assets.itsmycargo.com/assets/images/MoT/parcel.png',
        code: 'lcl',
    },
    {
        name: 'FCL Shipment',
        img: 'https://assets.itsmycargo.com/assets/images/welcome/container.png',
        code: 'fcl',
    }
];

export const OPEN_SHIPMENT_TYPES = [
    {
        name: 'LCL Shipment',
        img: 'https://assets.itsmycargo.com/assets/images/MoT/parcel.png',
        code: 'openlcl',
    },
    {
        name: 'FCL Shipment',
        img: 'https://assets.itsmycargo.com/assets/images/welcome/container.png',
        code: 'openfcl',
    }
];

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
        text: 'Choose Route',
        header: 'Choose Route',
        url: '/choose_route'
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
];
export const documentTypes = {
    packing_sheet: 'Packing Sheet',
    commercial_invoice: 'Commercial Invoice',
    customs_declaration: 'Customs Declaration',
    customs_value_declaration: 'Customs Value Declaration',
    eori: 'EORI',
    certificate_of_origin: 'Certificate Of Origin',
    dangerous_goods: 'Dangerous Goods'
};

export const shipmentConstants = {
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
    FETCH_SHIPMENT_FAILURE: 'FETCH_SHIPMENT_FAILURE'
};

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
];
