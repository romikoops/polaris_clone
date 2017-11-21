import { shipmentConstants } from '../constants';
import { shipmentService } from '../services';
import { alertActions } from './';
import { Promise } from 'babel-polyfill';
import { push } from 'react-router-redux';


function newShipment(user, type) {
    function request(shipmentData) { return { type: shipmentConstants.NEW_SHIPMENT_REQUEST, shipmentData }; }
    function success(shipmentData) { return { type: shipmentConstants.NEW_SHIPMENT_SUCCESS, shipmentData }; }
    function failure(error) { return { type: shipmentConstants.NEW_SHIPMENT_FAILURE, error }; }
    return dispatch => {
        dispatch(request(user));

        shipmentService.newShipment(user, type)
            .then(
                shipmentData => {
                    dispatch(alertActions.success('Fetching New Shipment successful'));
                    dispatch(push('open/' + shipmentData.data.id + '/shipment_details'));
                    dispatch(success(shipmentData));
                },
                error => {
                    dispatch(failure(error));
                    dispatch(alertActions.error(error));
                }
            );
    };
}

function setShipmentDetails(data) {
    function request(shipmentData) { return { type: shipmentConstants.SET_SHIPMENT_DETAILS_REQUEST, shipmentData }; }
    function success(shipmentData) { return { type: shipmentConstants.SET_SHIPMENT_DETAILS_SUCCESS, shipmentData }; }
    function failure(error) { return { type: shipmentConstants.SET_SHIPMENT_DETAILS_FAILURE, error }; }
    return dispatch => {
        dispatch(request(data));

        shipmentService.setShipmentDetails(data)
            .then(
                shipmentData => {
                    dispatch(success(shipmentData));
                    // dispatch(push('open/' + shipmentData.shipment.id + '/choose_route'));
                    dispatch(alertActions.success('Fetching New Shipment successful'));
                },
                error => {
                    dispatch(failure(error));
                    dispatch(alertActions.error(error));
                }
            );
    };
}

function getAll() {
    function request() { return { type: shipmentConstants.GETALL_REQUEST }; }
    function success(shipments) { return { type: shipmentConstants.GETALL_SUCCESS, shipments }; }
    function failure(error) { return { type: shipmentConstants.GETALL_FAILURE, error }; }
    return dispatch => {
        dispatch(request());

        shipmentService.getAll()
            .then(
                shipments => dispatch(success(shipments)),
                error => dispatch(failure(error))
            );
    };
}

function getShipments() {
    function request() { return { type: shipmentConstants.GETALL_REQUEST }; }
    function success(shipments) { return { type: shipmentConstants.GETALL_SUCCESS, shipments }; }
    function failure(error) { return { type: shipmentConstants.GETALL_FAILURE, error }; }
    return dispatch => {
        dispatch(request());

        shipmentService.getAll()
            .then(
                shipments => dispatch(success(shipments)),
                error => dispatch(failure(error))
            );
    };
}

function getShipment(id) {
    function request(id) { return { type: shipmentConstants.GET_SHIPMENT_REQUEST, id }; }
    function success(shipment) { return { type: shipmentConstants.GET_SHIPMENT_SUCCESS, shipment }; }
    function failure(error) { return { type: shipmentConstants.GET_SHIPMENT_FAILURE, error }; }
    return dispatch => {
        dispatch(request());

        shipmentService.getShipment(id)
            .then(
                shipment => dispatch(success(shipment)),
                error => dispatch(failure(error))
            );
    };
}

// prefixed function name with underscore because delete is a reserved word in javascript
function _delete(id) {
    function request(id) { return { type: shipmentConstants.DELETE_REQUEST, id }; }
    function success(id) { return { type: shipmentConstants.DELETE_SUCCESS, id }; }
    function failure(id, error) { return { type: shipmentConstants.DELETE_FAILURE, id, error }; }
    return dispatch => {
        dispatch(request(id));
        shipmentService.delete(id)
            .then(
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
    function request(shipId) { return { type: shipmentConstants.FETCH_SHIPMENT_REQUEST, shipId }; }
    function success(shipId, data) { return { type: shipmentConstants.FETCH_SHIPMENT_SUCCESS, shipId, data }; }
    function failure(shipId, error) { return { type: shipmentConstants.FETCH_SHIPMENT_FAILURE, shipId, error }; }
    return dispatch => {
        dispatch(request(id));
        return fetch(`http://localhost:3000/shipments/${id}`)
      .then(response => response.json())
      .then(
        json => dispatch(success(id, json)),
        error => {
            dispatch(failure(id, error));
        });
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
export const shipmentActions = {
    newShipment,
    setShipmentDetails,
    fetchShipment,
    getShipments,
    getShipment,
    shouldFetchShipment,
    fetchShipmentIfNeeded,
    getAll,
    delete: _delete
};

