export const SHIPMENT_TYPES = [
    {
        name: 'LCL Shipment',
        img: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/MoT/parcel.png',
        code: 'lcl',
    },
    {
        name: 'FCL Shipment',
        img: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/welcome/containers.jpg',
        code: 'fcl',
    }
];

export const OPEN_SHIPMENT_TYPES = [
    {
        name: 'LCL Shipment',
        img: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/MoT/parcel.png',
        code: 'openlcl',
    },
    {
        name: 'FCL Shipment',
        img: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/welcome/containers.jpg',
        code: 'openfcl',
    }
];

export const SHIPMENT_STAGES = [
    {
        step: 1,
        text: 'Choose shipment type',
        header: 'Choose shipment'
    },
    {
        step: 2,
        text: '',
        header: 'Choose Route'
    },
    {
        step: 3,
        text: '',
        header: 'Booking Details'
    },
    {
        step: 4,
        text: '',
        header: 'Booking Confirmation'
    }
];

export const shipmentConstants = {
    NEW_SHIPMENT_REQUEST: 'NEW_SHIPMENT_REQUEST',
    NEW_SHIPMENT_SUCCESS: 'NEW_SHIPMENT_SUCCESS',
    NEW_SHIPMENT_FAILURE: 'NEW_SHIPMENT_FAILURE',

    GETALL_REQUEST: 'USERS_GETALL_REQUEST',
    GETALL_SUCCESS: 'USERS_GETALL_SUCCESS',
    GETALL_FAILURE: 'USERS_GETALL_FAILURE',

    DELETE_REQUEST: 'USERS_DELETE_REQUEST',
    DELETE_SUCCESS: 'USERS_DELETE_SUCCESS',
    DELETE_FAILURE: 'USERS_DELETE_FAILURE'
};
