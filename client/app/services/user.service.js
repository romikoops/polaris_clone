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


function getShipments(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/users/' + id + '/shipments', requestOptions).then(handleResponse);
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
        body: JSON.stringify(user)
    };

    return fetch(BASE_URL + '/users/' + user.id, requestOptions).then(
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
function getShipment(userId, id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/users/' + userId + '/shipments/' + id, requestOptions).then(handleResponse);
}

export const userService = {
    getLocations,
    destroyLocation,
    makePrimary,
    getShipment,
    getShipments,
    getHubs,
    getAll,
    getById,
    update,
    getStoredUser,
    delete: _delete
};
