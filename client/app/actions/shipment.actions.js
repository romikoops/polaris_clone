import { shipmentConstants } from '../constants';
import { shipmentService } from '../services';
import { alertActions, userActions } from './';
import { Promise } from 'es6-promise-promise';
import { push } from 'react-router-redux';
import { getSubdomain } from '../helpers/subdomain';
const subdomainKey = getSubdomain();
const cookieKey = subdomainKey + '_user';
const userData = JSON.parse(localStorage.getItem(cookieKey));
function newShipment(type) {
    function request(shipmentData) {
        return { type: shipmentConstants.NEW_SHIPMENT_REQUEST, shipmentData };
    }
    function success(shipmentData) {
        return { type: shipmentConstants.NEW_SHIPMENT_SUCCESS, shipmentData };
    }
    function failure(error) {
        return { type: shipmentConstants.NEW_SHIPMENT_FAILURE, error };
    }
    return dispatch => {
        dispatch(request(type));
        shipmentService.newShipment(type).then(
            resp => {
                const shipmentData = resp.data;
                dispatch(
                    alertActions.success('Fetching New Shipment successful')
                );
                dispatch(
                    push(
                        '/booking/' + shipmentData.shipment.id + '/shipment_details'
                    )
                );
                dispatch(success(shipmentData));
            },
            error => {
                error.then(data => {
                    dispatch(failure({ type: 'error', text: data.message }));
                });
            }
        );
    };
}

function setShipmentDetails(data) {
    function request(shipmentData) {
        return {
            type: shipmentConstants.SET_SHIPMENT_DETAILS_REQUEST,
            shipmentData
        };
    }
    function success(shipmentData) {
        return {
            type: shipmentConstants.SET_SHIPMENT_DETAILS_SUCCESS,
            shipmentData
        };
    }
    function failure(error) {
        return { type: shipmentConstants.SET_SHIPMENT_DETAILS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request(data));
        shipmentService.setShipmentDetails(data).then(
            resp => {
                const shipmentData = resp.data;
                dispatch(success(shipmentData));
                dispatch(
                    push(
                        '/booking/' + shipmentData.shipment.id + '/choose_route'
                    )
                );
                dispatch(
                    alertActions.success('Set Shipment Details successful')
                );
            },
            error => {
                error.then(data => {
                    dispatch(failure({ type: 'error', text: data.message }));
                });
            }
        );
    };
}

function setShipmentRoute(data) {
    function request(shipmentData) {
        return {
            type: shipmentConstants.SET_SHIPMENT_ROUTE_REQUEST,
            shipmentData
        };
    }
    function success(shipmentData) {
        return {
            type: shipmentConstants.SET_SHIPMENT_ROUTE_SUCCESS,
            shipmentData
        };
    }
    function failure(error) {
        return { type: shipmentConstants.SET_SHIPMENT_ROUTE_FAILURE, error };
    }
    return dispatch => {
        dispatch(request(data));

        shipmentService.setShipmentRoute(data).then(
            resp => {
                const shipmentData = resp.data;
                dispatch(success(shipmentData));
                dispatch(
                    push(
                        '/booking/' +
                            shipmentData.shipment.id +
                            '/booking_details'
                    )
                );
                dispatch(alertActions.success('Set Shipment Route successful'));
            },
            error => {
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function setShipmentContacts(data) {
    function request(shipmentData) {
        return {
            type: shipmentConstants.SET_SHIPMENT_CONTACTS_REQUEST,
            shipmentData
        };
    }
    function success(shipmentData) {
        return {
            type: shipmentConstants.SET_SHIPMENT_CONTACTS_SUCCESS,
            shipmentData
        };
    }
    function failure(error) {
        return { type: shipmentConstants.SET_SHIPMENT_CONTACTS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request(data));

        shipmentService.setShipmentContacts(data).then(
            resp => {
                const shipmentData = resp.data;
                dispatch(success(shipmentData));
                dispatch(
                    push(
                        '/booking/' +
                            shipmentData.shipment.id +
                            '/finish_booking'
                    )
                );
                dispatch(
                    alertActions.success('Set Shipment Contacts successful')
                );
            },
            error => {
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function getAll() {
    function request() {
        return { type: shipmentConstants.GETALL_REQUEST };
    }
    function success(shipments) {
        return { type: shipmentConstants.GETALL_SUCCESS, shipments };
    }
    function failure(error) {
        return { type: shipmentConstants.GETALL_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        shipmentService
            .getAll()
            .then(
                shipments => dispatch(success(shipments)),
                error => dispatch(failure(error))
            );
    };
}

function getShipments() {
    function request() {
        return { type: shipmentConstants.GETALL_REQUEST };
    }
    function success(shipments) {
        return { type: shipmentConstants.GETALL_SUCCESS, shipments };
    }
    function failure(error) {
        return { type: shipmentConstants.GETALL_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        shipmentService
            .getAll()
            .then(
                shipments => dispatch(success(shipments)),
                error => dispatch(failure(error))
            );
    };
}

function getShipment(id) {
    function request(reqId) {
        return { type: shipmentConstants.GET_SHIPMENT_REQUEST, reqId };
    }
    function success(shipment) {
        return { type: shipmentConstants.GET_SHIPMENT_SUCCESS, shipment };
    }
    function failure(error) {
        return { type: shipmentConstants.GET_SHIPMENT_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        shipmentService
            .getShipment(id)
            .then(
                shipment => dispatch(success(shipment)),
                error => dispatch(failure(error))
            );
    };
}

// prefixed function name with underscore because delete is a reserved word in javascript
function _delete(id) {
    function request(reqId) {
        return { type: shipmentConstants.DELETE_REQUEST, reqId };
    }
    function success(respId) {
        return { type: shipmentConstants.DELETE_SUCCESS, respId };
    }
    function failure(id, error) {
        return { type: shipmentConstants.DELETE_FAILURE, id, error };
    }
    return dispatch => {
        dispatch(request(id));
        shipmentService.delete(id).then(
            userData => {
                dispatch(success(userData.id));
            },
            error => {
                dispatch(failure(id, error));
            }
        );
    };
}

function fetchShipment(id) {
    function request(shipId) {
        return { type: shipmentConstants.FETCH_SHIPMENT_REQUEST, shipId };
    }
    function success(shipId, data) {
        return { type: shipmentConstants.FETCH_SHIPMENT_SUCCESS, shipId, data };
    }
    function failure(shipId, error) {
        return {
            type: shipmentConstants.FETCH_SHIPMENT_FAILURE,
            shipId,
            error
        };
    }
    return dispatch => {
        dispatch(request(id));
        return fetch(`http://localhost:3000/shipments/${id}`)
            .then(response => response.json())
            .then(
                json => dispatch(success(id, json)),
                error => {
                    dispatch(failure(id, error));
                }
            );
    };
}

function shouldFetchShipment(state, id) {
    const shipment = state.shipment.data;
    if (!shipment) {
        return true;
    }
    if (shipment && shipment.id !== id) {
        return true;
    }
    if (shipment.isFetching) {
        return false;
    }
    return shipment.didInvalidate;
}
function fetchShipmentIfNeeded(id) {
    // Note that the function also receives getState()
    // which lets you choose what to dispatch next.

    // This is useful for avoiding a network request if
    // a cached value is already available.

    return (dispatch, getState) => {
        if (shouldFetchShipment(getState(), id)) {
            // Dispatch a thunk from thunk!
            return dispatch(getShipment(id));
        }

        // Let the calling code know there's nothing to wait for.
        return Promise.resolve();
    };
}

function uploadDocument(doc, type, url) {
    function request(file) {
        return { type: shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_REQUEST, payload: file };
    }
    function success(file) {
        return { type: shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_SUCCESS, payload: file.data };
    }
    function failure(error) {
        return { type: shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        shipmentService.uploadDocument(doc, type, url).then(
            data => {
                dispatch(
                    alertActions.success('Uploading Document successful')
                );
                console.log(data);
                dispatch(success(data));
            },
            error => {
                // ;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}
function deleteDocument(id) {
    function request(deleteId) {
        return { type: shipmentConstants.SHIPMENT_DELETE_DOCUMENT_REQUEST, payload: deleteId };
    }
    function success(deleteId) {
        return { type: shipmentConstants.SHIPMENT_DELETE_DOCUMENT_SUCCESS, payload: deleteId };
    }
    function failure(error) {
        return { type: shipmentConstants.SHIPMENT_DELETE_DOCUMENT_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        shipmentService.deleteDocument(id).then(
            data => {
                dispatch(
                    alertActions.success('Deleting Document successful')
                );
                console.log(data);
                dispatch(success(id));
            },
            error => {
                // ;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function toDashboard() {
    return dispatch => {
        dispatch(userActions.getDashboard(userData.data.id, true));
    };
}

function goTo(path) {
    return dispatch => {
        dispatch(push(path));
    };
}


export const shipmentActions = {
    newShipment,
    setShipmentRoute,
    setShipmentDetails,
    setShipmentContacts,
    fetchShipment,
    getShipments,
    uploadDocument,
    getShipment,
    deleteDocument,
    shouldFetchShipment,
    fetchShipmentIfNeeded,
    getAll,
    goTo,
    toDashboard,
    delete: _delete
};
