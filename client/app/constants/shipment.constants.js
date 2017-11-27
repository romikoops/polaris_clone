export const SHIPMENT_TYPES = [
    {
        name: 'LCL Shipment',
        img: 'https://assets.itsmycargo.com/assets/images/MoT/parcel.png',
        code: 'lcl',
    },
    {
        name: 'FCL Shipment',
        img: 'https://assets.itsmycargo.com/assets/images/welcome/container.jpg',
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
        img: 'https://assets.itsmycargo.com/assets/images/welcome/container.jpg',
        code: 'openfcl',
    }
];

export const SHIPMENT_STAGES = [
    {
        step: 0,
        text: 'Choose shipment type',
        header: 'Choose shipment'
    },
    {
        step: 1,
        text: 'Shipment Details',
        header: 'Shipment Details'
    },
    {
        step: 2,
        text: 'Choose Route',
        header: 'Choose Route'
    },
    {
        step: 3,
        text: 'Booking overview & details',
        header: 'Booking Details'
    },
    {
        step: 4,
        text: 'Booking Confirmation',
        header: 'Booking Confirmation'
    }
];

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
