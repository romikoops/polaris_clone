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

function getAvailableDestinations(routeIds, origin) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };
    let queryString = routeIds ? `?route_ids=${routeIds}` : '';
    queryString += origin ? `&origin=${origin}` : '';

    return fetch(BASE_URL + '/nexuses' + queryString, requestOptions).then(handleResponse);
}

export const nexusService = {
		getAvailableDestinations
};
