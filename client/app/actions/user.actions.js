import { userConstants } from '../constants';
import { userService } from '../services';

import { alertActions } from './';

import { push } from 'react-router-redux';


function getAll(redirect) {
    function request() {
        return { type: userConstants.GETALL_REQUEST };
    }
    function success(response) {
        const payload = response.data;
        return { type: userConstants.GETALL_SUCCESS, payload };
    }
    function failure(error) {
        return { type: userConstants.GETALL_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        userService
            .getAll()
            .then(
                response => {
                    if (redirect) {
                        dispatch(
                            push('/account/users')
                        );
                    }
                    dispatch(success(response));
                },
                error => dispatch(failure(error))
            );
    };
}

// prefixed function name with underscore because delete is a reserved word in javascript
function _delete(id) {
    function request(reqId) {
        return { type: userConstants.DELETE_REQUEST, reqId };
    }
    function success(respId) {
        return { type: userConstants.DELETE_SUCCESS, respId };
    }
    function failure(failId, error) {
        return { type: userConstants.DELETE_FAILURE, failId, error };
    }

    return dispatch => {
        dispatch(request(id));
        userService.delete(id).then(
            userData => {
                dispatch(success(userData.id));
            },
            error => {
                dispatch(failure(id, error));
            }
        );
    };
}

function getLocations(user, redirect) {
    function request() {
        return { type: userConstants.GETLOCATIONS_REQUEST };
    }
    function success(response) {
        const payload = response.data;
        return { type: userConstants.GETLOCATIONS_SUCCESS, payload };
    }
    function failure(error) {
        return { type: userConstants.GETLOCATIONS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        userService
            .getLocations(user)
            .then(
                response => {
                    if (redirect) {
                        dispatch(
                            push('/account/locations')
                        );
                    }
                    dispatch(success(response));
                },
                error => dispatch(failure(error))
            );
    };
}

function destroyLocation(userId, locationId, redirect) {
    function request() {
        return { type: userConstants.DESTROYLOCATION_REQUEST };
    }
    function success(response) {
        const payload = response.data;
        return { type: userConstants.DESTROYLOCATION_SUCCESS, payload };
    }
    function failure(error) {
        return { type: userConstants.DESTROYLOCATION_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        userService
            .destroyLocation(userId, locationId)
            .then(
                response => {
                    if (redirect) {
                        dispatch(
                            push('/account/locations')
                        );
                    }
                    dispatch(success(response));
                },
                error => dispatch(failure(error))
            );
    };
}

function makePrimary(userId, locationId, redirect) {
    function request() {
        return { type: userConstants.MAKEPRIMARY_REQUEST };
    }
    function success(response) {
        const payload = response.data;
        return { type: userConstants.MAKEPRIMARY_SUCCESS, payload };
    }
    function failure(error) {
        return { type: userConstants.MAKEPRIMARY_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        userService
            .makePrimary(userId, locationId)
            .then(
                response =>{
                    if (redirect) {
                        dispatch(
                            push('/account/shipments')
                        );
                    }
                    dispatch(success(response));
                },
                error => dispatch(failure(error))
            );
    };
}

function getShipments(id, redirect) {
    function request(shipmentData) {
        return { type: userConstants.GET_SHIPMENTS_REQUEST, payload: shipmentData };
    }
    function success(shipmentData) {
        return { type: userConstants.GET_SHIPMENTS_SUCCESS, payload: shipmentData };
    }
    function failure(error) {
        return { type: userConstants.GET_SHIPMENTS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        userService.getShipments(id).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Shipments successful')
                );
                if (redirect) {
                    dispatch(
                        push('/account/shipments')
                    );
                }

                dispatch(success(data));
            },
            error => {
                // debugger;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function getHubs() {
    function request(hubData) {
        return { type: userConstants.GET_HUBS_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: userConstants.GET_HUBS_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: userConstants.GET_HUBS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        userService.getHubs().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Hubs successful')
                );

                dispatch(success(data));
            },
            error => {
                // debugger;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function getShipment(userId, id, redirect) {
    function request(shipmentData) {
        return { type: userConstants.USER_GET_SHIPMENT_REQUEST, payload: shipmentData };
    }
    function success(shipmentData) {
        return { type: userConstants.USER_GET_SHIPMENT_SUCCESS, payload: shipmentData };
    }
    function failure(error) {
        return { type: userConstants.USER_GET_SHIPMENT_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        userService.getShipment(userId, id).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Shipment successful')
                );
                if (redirect) {
                    dispatch(
                        push('/account/shipments/' + id)
                    );
                }
                dispatch(success(data));
            },
            error => {
                // debugger;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function getDashboard(id, redirect) {
    function request(dashData) {
        return { type: userConstants.GET_DASHBOARD_REQUEST, payload: dashData };
    }
    function success(dashData) {
        return { type: userConstants.GET_DASHBOARD_SUCCESS, payload: dashData };
    }
    function failure(error) {
        return { type: userConstants.GET_DASHBOARD_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        userService.getDashboard().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Dashboard successful')
                );
                if (redirect) {
                    dispatch(
                        push('/account')
                    );
                }
                dispatch(success(data));
            },
            error => {
                // debugger;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function goTo(path) {
    return dispatch => {
        dispatch(push(path));
    };
}

export const userActions = {
    getLocations,
    destroyLocation,
    makePrimary,
    getDashboard,
    getHubs,
    getShipments,
    getShipment,
    goTo,
    getAll,
    delete: _delete
};
