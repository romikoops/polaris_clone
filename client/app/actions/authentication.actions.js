import { authenticationConstants } from '../constants';
import { authenticationService } from '../services';
import { alertActions } from './';
import { history } from '../helpers';

function login(username, password) {
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
        dispatch(request({ username }));
        authenticationService.login(username, password).then(
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

function register(user) {
    function request(response) {
        return { type: authenticationConstants.REGISTRATION_REQUEST, user: response.data };
    }
    function success(response) {
        return { type: authenticationConstants.REGISTRATION_SUCCESS, user: response.data };
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
};
