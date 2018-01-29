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

function getHub(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/hubs/' + id, requestOptions).then(handleResponse);
}

function wizardHubs(file) {
    const formData = new FormData();
    formData.append('file', file);
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader()},
        body: formData
    };
    const uploadUrl = BASE_URL + '/admin/hubs/process_csv';
    return fetch(uploadUrl, requestOptions).then(handleResponse);
}

function wizardSCharge(file) {
    const formData = new FormData();
    formData.append('file', file);
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader()},
        body: formData
    };
    const uploadUrl = BASE_URL + '/admin/service_charges/process_csv';
    return fetch(uploadUrl, requestOptions).then(handleResponse);
}

function wizardPricings(file) {
    const formData = new FormData();
    formData.append('file', file);
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader()},
        body: formData
    };
    const uploadUrl = BASE_URL + '/admin/pricings/train_and_ocean_pricings/process_csv';
    return fetch(uploadUrl, requestOptions).then(handleResponse);
}

function wizardTrucking(type, file) {
    const formData = new FormData();
    formData.append('file', file);
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader()},
        body: formData
    };
    let uploadUrl;
    if (type === 'zipcode') {
        uploadUrl = BASE_URL + '/admin/trucking/trucking_zip_pricings';
    } else if (type === 'city') {
        uploadUrl = BASE_URL + '/admin/trucking/trucking_city_pricings';
    }
    return fetch(uploadUrl, requestOptions).then(handleResponse);
}

function wizardOpenPricings(file) {
    const formData = new FormData();
    formData.append('file', file);
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader()},
        body: formData
    };
    const uploadUrl = BASE_URL + '/admin/open_pricings/train_and_ocean_pricings/process_csv';
    return fetch(uploadUrl, requestOptions).then(handleResponse);
}

function getRoutes() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/routes', requestOptions).then(handleResponse);
}

function getRoute(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/routes/' + id, requestOptions).then(handleResponse);
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

function getDashboard() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/dashboard', requestOptions).then(handleResponse);
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
    console.log(url);
    return fetch(url, requestOptions).then(handleResponse);
}

function getPricings() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/pricings', requestOptions).then(handleResponse);
}

function getClientPricings(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/client_pricings/' + id, requestOptions).then(handleResponse);
}

function getRoutePricings(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/route_pricings/' + id, requestOptions).then(handleResponse);
}

function getClients() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/clients', requestOptions).then(handleResponse);
}

function getClient(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/admin/clients/' + id, requestOptions).then(handleResponse);
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

function updatePricing(id, data) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    };

    return fetch(BASE_URL + '/admin/pricings/update/' + id, requestOptions).then(handleResponse);
}

function updateServiceCharge(id, data) {
    const requestOptions = {
        method: 'PUT',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({data})
    };

    return fetch(BASE_URL + '/admin/service_charges/' + id, requestOptions).then(handleResponse);
}

function newClient(data) {
    const formData = new FormData();
    formData.append('new_client', JSON.stringify(data));
    const requestOptions = {
        method: 'POST',
        headers: authHeader(),
        body: formData
    };
    return fetch(BASE_URL + '/admin/clients', requestOptions).then(handleResponse);
}

function activateHub(hubId) {
    const requestOptions = {
        method: 'PATCH',
        headers: authHeader()
    };
    return fetch(BASE_URL + '/admin/hubs/' + hubId + '/set_status', requestOptions).then(handleResponse);
}

function documentAction(docId, action) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(action)
    };
    return fetch(BASE_URL + '/admin/documents/action/' + docId, requestOptions).then(handleResponse);
}

function saveNewHub(hub, location) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({hub, location})
    };
    return fetch(BASE_URL + '/admin/hubs', requestOptions).then(handleResponse);
}
function newRoute(route) {
    const requestOptions = {
        method: 'POST',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({route})
    };
    return fetch(BASE_URL + '/admin/routes', requestOptions).then(handleResponse);
}

export const adminService = {
    getHubs,
    getHub,
    getRoutes,
    getRoute,
    getClient,
    updatePricing,
    getServiceCharges,
    getPricings,
    getShipment,
    getSchedules,
    getTrucking,
    getClientPricings,
    getDashboard,
    autoGenSchedules,
    confirmShipment,
    getVehicleTypes,
    getShipments,
    getClients,
    getRoutePricings,
    wizardHubs,
    wizardSCharge,
    wizardPricings,
    wizardOpenPricings,
    wizardTrucking,
    updateServiceCharge,
    newClient,
    activateHub,
    documentAction,
    saveNewHub,
    newRoute
};
