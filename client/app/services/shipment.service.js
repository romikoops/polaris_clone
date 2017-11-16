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
        url = BASE_URL + '/users/' + user.id + '/shipments/open/' + _type;
    } else {
        url = BASE_URL + '/users/' + user.id + '/shipments/' + type;
    }
    return fetch(url, requestOptions).then(handleResponse);
}

function update(user) {
    const requestOptions = {
        method: 'PUT',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    };

    return fetch(BASE_URL + '/users/' + user.id, requestOptions).then(handleResponse);
}

// prefixed function name with underscore because delete is a reserved word in javascript
function _delete(id) {
    const requestOptions = {
        method: 'DELETE',
        headers: authHeader()
    };

    return fetch('/users/' + id, requestOptions).then(handleResponse);
}


export const shipmentService = {
    newShipment,
    getAll,
    getShipment,
    update,
    getStoredShipment,
    delete: _delete
};
