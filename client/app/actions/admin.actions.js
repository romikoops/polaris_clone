import { adminConstants } from '../constants/admin.constants';
import { adminService } from '../services/admin.service';
import { alertActions } from './';
// import { Promise } from 'es6-promise-promise';
import { push } from 'react-router-redux';

function getHubs() {
    function request(hubData) {
        return { type: adminConstants.GET_HUBS_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: adminConstants.GET_HUBS_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: adminConstants.GET_HUBS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getHubs().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Hubs successful')
                );
                dispatch(
                    push('/admin/hubs')
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
function getServiceCharges() {
    function request(scData) {
        return { type: adminConstants.GET_SERVICE_CHARGES_REQUEST, payload: scData };
    }
    function success(scData) {
        return { type: adminConstants.GET_SERVICE_CHARGES_SUCCESS, payload: scData };
    }
    function failure(error) {
        return { type: adminConstants.GET_SERVICE_CHARGES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getServiceCharges().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Service Charges successful')
                );
                dispatch(
                    push('/admin/service_charges')
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
function getPricings() {
    function request(prData) {
        return { type: adminConstants.GET_PRICINGS_REQUEST, payload: prData };
    }
    function success(prData) {
        // debugger;
        return { type: adminConstants.GET_PRICINGS_SUCCESS, payload: prData };
    }
    function failure(error) {
        return { type: adminConstants.GET_PRICINGS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getPricings().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Prices successful')
                );
                dispatch(
                    push('/admin/pricings')
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
function getSchedules() {
    function request(schedData) {
        return { type: adminConstants.GET_SCHEDULES_REQUEST, payload: schedData };
    }
    function success(schedData) {
        return { type: adminConstants.GET_SCHEDULES_SUCCESS, payload: schedData };
    }
    function failure(error) {
        return { type: adminConstants.GET_SCHEDULES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getSchedules().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Schedules successful')
                );
                dispatch(
                    push('/admin/schedules')
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

function getTrucking() {
    function request(truckData) {
        return { type: adminConstants.GET_TRUCKING_REQUEST, payload: truckData };
    }
    function success(truckData) {
        return { type: adminConstants.GET_TRUCKING_SUCCESS, payload: truckData };
    }
    function failure(error) {
        return { type: adminConstants.GET_TRUCKING_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getTrucking().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Trucking successful')
                );
                dispatch(
                    push('/admin/trucking')
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

function getVehicleTypes() {
    function request(vehicleData) {
        return { type: adminConstants.GET_VEHICLE_TYPES_REQUEST, payload: vehicleData };
    }
    function success(vehicleData) {
        return { type: adminConstants.GET_VEHICLE_TYPES_SUCCESS, payload: vehicleData };
    }
    function failure(error) {
        return { type: adminConstants.GET_VEHICLE_TYPES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getVehicleTypes().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Vehicle Types successful')
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


function autoGenSchedules(data) {
    function request(schedData) {
        return { type: adminConstants.GENERATE_SCHEDULES_REQUEST, payload: schedData };
    }
    function success(schedData) {
        return { type: adminConstants.GENERATE_SCHEDULES_SUCCESS, payload: schedData };
    }
    function failure(error) {
        return { type: adminConstants.GENERATE_SCHEDULES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.autoGenSchedules(data).then(
            data => {
                dispatch(
                    alertActions.success('Generating Schedules successful')
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

// function shouldFetchShipment(state, id) {
//     const shipment = state.shipment.data;
//     if (!shipment) {
//         return true;
//     }
//     if (shipment && shipment.id !== id) {
//         return true;
//     }
//     if (shipment.isFetching) {
//         return false;
//     }
//     return shipment.didInvalidate;
// }
// function fetchShipmentIfNeeded(id) {
//     // Note that the function also receives getState()
//     // which lets you choose what to dispatch next.

//     // This is useful for avoiding a network request if
//     // a cached value is already available.

//     return (dispatch, getState) => {
//         if (shouldFetchShipment(getState(), id)) {
//             // Dispatch a thunk from thunk!
//             return dispatch(getShipment(id));
//         }

//         // Let the calling code know there's nothing to wait for.
//         return Promise.resolve();
//     };
// }
export const adminActions = {
    getHubs,
    getServiceCharges,
    getPricings,
    getTrucking,
    getSchedules,
    autoGenSchedules,
    getVehicleTypes
};
