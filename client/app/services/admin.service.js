import { authHeader } from '../helpers';
import { Promise } from 'es6-promise-promise';
import { BASE_URL } from '../constants';

function handleResponse(response) {
    const promise = Promise;
    if (!response.ok) {
        return promise.reject(response.statusText);
    }

    return response.json();
}

function getHubs() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/hubs', requestOptions).then(handleResponse);
}

function getServiceCharges() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/service_charges', requestOptions).then(handleResponse);
}

// function getShipment(id) {
//     const requestOptions = {
//         method: 'GET',
//         headers: authHeader()
//     };

//     return fetch(BASE_URL + '/shipments/' + id, requestOptions).then(
//         handleResponse
//     );
// }

// function newShipment(type) {
//     const requestOptions = {
//         method: 'POST',
//         headers: { ...authHeader(), 'Content-Type': 'application/json' },
//         body: JSON.stringify({ type: type })
//     };
//     const url = BASE_URL + '/shipments';
//     return fetch(url, requestOptions).then(handleResponse);
// }

// function setShipmentDetails(data) {
//     const requestOptions = {
//         method: 'POST',
//         headers: { ...authHeader(), 'Content-Type': 'application/json' },
//         body: JSON.stringify(data)
//     };
//     const url = BASE_URL + '/shipments/' + data.shipment.id + '/get_offer';
//     return fetch(url, requestOptions).then(handleResponse);
// }

// function setShipmentRoute(data) {
//     const requestOptions = {
//         method: 'POST',
//         headers: { ...authHeader(), 'Content-Type': 'application/json' },
//         body: JSON.stringify(data)
//     };
//     const url = BASE_URL + '/shipments/' + data.shipment.id + '/finish_booking';
//     return fetch(url, requestOptions).then(handleResponse);
// }

// function setShipmentContacts(data) {
//     const requestOptions = {
//         method: 'POST',
//         headers: { ...authHeader(), 'Content-Type': 'application/json' },
//         body: JSON.stringify(data)
//     };
//     const url = BASE_URL + '/shipments/' + data.shipment.id + '/update';
//     return fetch(url, requestOptions).then(handleResponse);
// }


export const adminService = {
    getHubs,
    getServiceCharges
};
