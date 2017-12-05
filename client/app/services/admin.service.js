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
function getPricings() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/pricings', requestOptions).then(handleResponse);
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

export const adminService = {
    getHubs,
    getServiceCharges,
    getPricings,
    getSchedules,
    getTrucking
};
