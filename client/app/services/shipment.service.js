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

function uploadDocument(doc, type, url) {
    const formData = new FormData();
    formData.append('file', doc);
    formData.append('type', type);
    const requestOptions = {
        method: 'POST',
        headers: authHeader(),
        body: formData
    };

    return fetch(BASE_URL + url, requestOptions).then(handleResponse);
}
function deleteDocument(documentId) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/documents/delete/' + documentId, requestOptions).then(handleResponse);
}

export const shipmentService = {
    newShipment,
    getAll,
    getShipment,
    setShipmentRoute,
    deleteDocument,
    setShipmentDetails,
    getStoredShipment,
    setShipmentContacts,
    uploadDocument
};
