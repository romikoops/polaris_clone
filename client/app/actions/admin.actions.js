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
    console.log(adminConstants);
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
        return { type: adminConstants.GET_HUBS_REQUEST, payload: scData };
    }
    function success(scData) {
        return { type: adminConstants.GET_HUBS_SUCCESS, payload: scData };
    }
    function failure(error) {
        return { type: adminConstants.GET_HUBS_FAILURE, error };
    }
    console.log(adminConstants);
    return dispatch => {
        dispatch(request());

        adminService.getServiceCharges().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Hubs successful')
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
    getServiceCharges
};
