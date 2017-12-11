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
function getShipments() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/shipments', requestOptions).then(handleResponse);
}

function getShipment(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/shipments/' + id, requestOptions).then(handleResponse);
}

function confirmShipment(id, action) {
    const requestOptions = {
        method: 'PUT',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({ shipment_action: action })
    };
    const url = BASE_URL + '/admin/shipments/' + id;
    return fetch(url, requestOptions).then(handleResponse);
}

function getPricings() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/pricings', requestOptions).then(handleResponse);
}

function getClients() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/clients', requestOptions).then(handleResponse);
}

function getSchedules() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/schedules', requestOptions).then(handleResponse);
}

function getTrucking() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/trucking', requestOptions).then(handleResponse);
}

function getVehicleTypes() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/vehicle_types', requestOptions).then(handleResponse);
}

function autoGenSchedules(data) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    };

    return fetch(BASE_URL + '/admin/schedules/auto_generate', requestOptions).then(handleResponse);
}

export const adminService = {
    getHubs,
    getServiceCharges,
    getPricings,
    getShipment,
    getSchedules,
    getTrucking,
    autoGenSchedules,
    confirmShipment,
    getVehicleTypes,
    getShipments,
    getClients
};
