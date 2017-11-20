import { authHeader } from '../helpers';
import { Promise } from 'babel-polyfill';
import { BASE_URL } from '../constants';
function handleResponse(response) {
    if (!response.ok) {
        return Promise.reject(response.statusText);
    }

    return response.json();
}


function getStoredShipment() {
    const storedShipment = JSON.parse(localStorage.getItem('shipment'));
    return storedShipment ? storedShipment : {};
}

function getAll() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/shipments', requestOptions).then(handleResponse);
}

function getShipment(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/shipments/' + id, requestOptions).then(handleResponse);
}

function newShipment(user, type) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    };
    let url = '';
    if (type.includes('open')) {
        const _type = type.replace('open', '');
        url = BASE_URL + '/shipments/open/' + _type;
    } else {
        url = BASE_URL + '/shipments/' + type;
    }
    return fetch(url, requestOptions).then(handleResponse);
}

function setShipmentDetails(user, data, type) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    };
    let url = '';
    if (type.includes('open')) {
        const _type = type.replace('open', '');
        url = BASE_URL + '/shipments/open/' + _type + '/get_offer';
    } else {
        url = BASE_URL + '/shipments/' + type + '/get_offer';
    }
    return fetch(url, requestOptions).then(handleResponse);
}

// const fetchShipment = (subdomain) => {
//     return dispatch => {
//         dispatch(requestShipment(subdomain));
//         return fetch(`http://localhost:3000/tenants/${subdomain}`)
//       .then(response => response.json())
//       .then(json => dispatch(receiveShipment(subdomain, json)));
//     };
// };

// const shouldFetchShipment = (state) => {
//     const shipment = state.shipment;
//     if (!shipment) {
//         return true;
//     }
//     if (shipment.isFetching) {
//         return false;
//     }
//     return shipment.didInvalidate;
// };

// export const fetchShipmentIfNeeded = (subdomain) => {
//   // Note that the function also receives getState()
//   // which lets you choose what to dispatch next.

//   // This is useful for avoiding a network request if
//   // a cached value is already available.

//     return (dispatch, getState) => {
//         if (shouldFetchShipment(getState(), subdomain)) {
//       // Dispatch a thunk from thunk!
//             return dispatch(fetchShipment(subdomain));
//         }

//       // Let the calling code know there's nothing to wait for.
//         return Promise.resolve();
//     };
// };

export const shipmentService = {
    newShipment,
    getAll,
    getShipment,
    setShipmentDetails,
    getStoredShipment
};
