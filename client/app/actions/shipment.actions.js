import { shipmentConstants } from '../constants';
import { shipmentService } from '../services';
import { alertActions } from './';

function newShipment(user, type) {
    function request(shipmentData) { return { type: shipmentConstants.NEW_SHIPMENT_REQUEST, shipmentData }; }
    function success(shipmentData) { return { type: shipmentConstants.NEW_SHIPMENT_SUCCESS, shipmentData }; }
    function failure(error) { return { type: shipmentConstants.NEW_SHIPMENT_FAILURE, error }; }
    return dispatch => {
        dispatch(request(user));

        shipmentService.newShipment(user, type)
            .then(
                shipmentData => {
                    dispatch(success(shipmentData));
                    // history.push('/login');
                    dispatch(alertActions.success('Fetching New Shipment successful'));
                },
                error => {
                    dispatch(failure(error));
                    dispatch(alertActions.error(error));
                }
            );
    };
}

function setShipmentDetails(data, type) {
    function request(shipmentData) { return { type: shipmentConstants.SET_SHIPMENT_DETAILS_REQUEST, shipmentData }; }
    function success(shipmentData) { return { type: shipmentConstants.SET_SHIPMENT_DETAILS_SUCCESS, shipmentData }; }
    function failure(error) { return { type: shipmentConstants.SET_SHIPMENT_DETAILS_FAILURE, error }; }
    return dispatch => {
        dispatch(request(data));

        shipmentService.setShipmentDetails(data, type)
            .then(
                shipmentData => {
                    dispatch(success(shipmentData));
                    // history.push('/login');
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
export const shipmentActions = {
    newShipment,
    setShipmentDetails,
    getAll,
    delete: _delete
};

