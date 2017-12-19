import { userConstants } from '../constants';
import { userService } from '../services';

function getAll() {
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
                response => dispatch(success(response)),
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

function getLocations(user) {
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
                response => dispatch(success(response)),
                error => dispatch(failure(error))
            );
    };
}

function destroyLocation(userId, locationId) {
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
                response => dispatch(success(response)),
                error => dispatch(failure(error))
            );
    };
}

function makePrimary(userId, locationId) {
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
                response => dispatch(success(response)),
                error => dispatch(failure(error))
            );
    };
}

export const userActions = {
    getLocations,
    destroyLocation,
    makePrimary,
    getAll,
    delete: _delete
};
