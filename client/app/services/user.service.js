import { authHeader } from '../helpers';
import { Promise } from 'es6-promise-promise';
import { BASE_URL } from '../constants';

function handleResponse(response) {
    if (!response.ok) {
        return Promise.reject(response.statusText);
    }

    return response.json();
}

function getLocations(userId) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(
        BASE_URL + '/users/' + userId + '/locations',
        requestOptions
    ).then(handleResponse);
}

function destroyLocation(userId, locationId) {
    const requestOptions = {
        method: 'DELETE',
        headers: authHeader()
    };

    return fetch(
        BASE_URL + '/users/' + userId + '/locations/' + locationId,
        requestOptions
    ).then(handleResponse);
}

function makePrimary(userId, locationId) {
    const requestOptions = {
        method: 'PATCH',
        headers: authHeader()
    };

    return fetch(
        BASE_URL + '/users/' + userId + '/locations/' + locationId,
        requestOptions
    ).then(handleResponse);
}


function getShipments() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/shipments', requestOptions).then(handleResponse);
}


function getStoredUser() {
    const sortedUser = JSON.parse(localStorage.getItem('user'));
    return sortedUser ? sortedUser : {};
}


function getAll() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/users', requestOptions).then(handleResponse);
}

function getById(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/users/' + id, requestOptions).then(
        handleResponse
    );
}


function update(user) {
    const requestOptions = {
        method: 'PUT',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({update: user})
    };

    return fetch(BASE_URL + '/users/' + user.id + '/update', requestOptions).then(
        handleResponse
    );
}

// prefixed function name with underscore because delete is a reserved word in javascript
function _delete(id) {
    const requestOptions = {
        method: 'DELETE',
        headers: authHeader()
    };

    return fetch('/users/' + id, requestOptions).then(handleResponse);
}

function getHubs(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/users/' + id + '/hubs', requestOptions).then(handleResponse);
}
function getShipment(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/shipments/' + id, requestOptions).then(handleResponse);
}

function getDashboard(userId) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/users/' + userId + '/home', requestOptions).then(handleResponse);
}

function deleteDocument(documentId) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/documents/delete/' + documentId, requestOptions).then(handleResponse);
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

export const userService = {
    getLocations,
    destroyLocation,
    getDashboard,
    makePrimary,
    getShipment,
    getShipments,
    getHubs,
    deleteDocument,
    uploadDocument,
    getAll,
    getById,
    update,
    getStoredUser,
    delete: _delete
};
