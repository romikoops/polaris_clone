import { Promise } from 'es6-promise-promise';
import { BASE_URL } from '../constants';
import { authHeader } from '../helpers';

function handleResponse(response) {
    const promise = Promise;
    const respJSON = response.json();
    if (!response.ok) {
        return promise.reject(respJSON);
    }

    return respJSON;
}

function getUserConversations() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };
    return fetch(BASE_URL + '/messaging/get', requestOptions).then(handleResponse);
}

function getAdminConversations() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };
    return fetch(BASE_URL + '/messaging/get_admin', requestOptions).then(handleResponse);
}

function sendUserMessage(message) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({ message })
    };
    const url = BASE_URL + '/messaging/send';
    return fetch(url, requestOptions).then(handleResponse);
}

function getShipmentData(ref) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({ ref })
    };
    const url = BASE_URL + '/messaging/data';
    return fetch(url, requestOptions).then(handleResponse);
}

function markAsRead(shipmentRef) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({ shipmentRef })
    };
    const url = BASE_URL + '/messaging/mark';
    return fetch(url, requestOptions).then(handleResponse);
}

export const messagingService = {
    getUserConversations,
    sendUserMessage,
    getShipmentData,
    markAsRead,
    getAdminConversations
};
