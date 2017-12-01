import { authHeader } from '../helpers';
import { Promise } from 'es6-promise-promise';
import { BASE_URL } from '../constants';

function handleResponse(response) {
    const promise = Promise;
    const respJSON = response.json();
    if (!response.ok) {
        return promise.reject(respJSON);
    }

    return respJSON;
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

    return fetch(BASE_URL + '/shipments/' + id, requestOptions).then(
        handleResponse
    );
}

function newShipment(type) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: type })
    };
    const url = BASE_URL + '/shipments';
    return fetch(url, requestOptions).then(handleResponse);
}

function setShipmentDetails(data) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    };
    const url = BASE_URL + '/shipments/' + data.shipment.id + '/get_offer';
    return fetch(url, requestOptions).then(handleResponse);
}

function setShipmentRoute(data) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    };
    const url = BASE_URL + '/shipments/' + data.shipment.id + '/finish_booking';
    return fetch(url, requestOptions).then(handleResponse);
}

function setShipmentContacts(data) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    };
    const url = BASE_URL + '/shipments/' + data.shipment.id + '/update';
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
    setShipmentRoute,
    setShipmentDetails,
    getStoredShipment,
    setShipmentContacts
};
