import { authenticationConstants } from '../constants';
import { authenticationService } from '../services';
import { shipmentActions } from './';
import { alertActions } from './';
import { history } from '../helpers';

function login(data) {
    function request(user) {
        return { type: authenticationConstants.LOGIN_REQUEST, user };
    }
    function success(user) {
        return { type: authenticationConstants.LOGIN_SUCCESS, user };
    }
    function failure(error) {
        return { type: authenticationConstants.LOGIN_FAILURE, error };
    }
    return dispatch => {
        dispatch(request({ username: data.username }));
        authenticationService.login(data).then(
            user => {
                dispatch(success(user));
                history.push('/');
            },
            error => {
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function logout() {
    authenticationService.logout();
    return { type: authenticationConstants.LOGOUT };
}

function register(user, req) {
    function request(response) {
        return { type: authenticationConstants.REGISTRATION_REQUEST, user: response };
    }
    function success(response) {
        return { type: authenticationConstants.REGISTRATION_SUCCESS, user: response };
    }
    function failure(error) {
        return { type: authenticationConstants.REGISTRATION_FAILURE, error };
    }

    return dispatch => {
        dispatch(request(user));

        authenticationService.register(user).then(
            response => {
                dispatch(success(response));
                dispatch(alertActions.success('Registration successful'));
                if (req) dispatch(shipmentActions.setShipmentRoute(req));
            },
            error => {
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function update(user, req) {
    function request(response) {
        return { type: authenticationConstants.UPDATE_REQUEST, user: response };
    }
    function success(response) {
        return { type: authenticationConstants.UPDATE_SUCCESS, user: response };
    }
    function failure(error) {
        return { type: authenticationConstants.UPDATE_FAILURE, error };
    }

    return dispatch => {
        dispatch(request(user));

        authenticationService.update(user).then(
            response => {
                dispatch(success(response));
                if (req) {
                    dispatch(shipmentActions.setShipmentRoute(req));
                    dispatch(alertActions.success('Registration successful'));
                } else {
                    dispatch(alertActions.success('Update successful'));
                }
            },
            error => {
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

export const authenticationActions = {
    login,
    logout,
    register,
    update
};
