import { authenticationConstants } from '../constants';
import { authenticationService } from '../services';
import { shipmentActions } from './';
import { alertActions } from './';
import { push } from 'react-router-redux';
import { getSubdomain } from '../helpers/subdomain';
const subdomainKey = getSubdomain();
const cookieKey = subdomainKey + '_user';
console.log(cookieKey);
function logout() {
    authenticationService.logout();
    return { type: authenticationConstants.LOGOUT };
}

function login(data) {
    function request(user) {
        return { type: authenticationConstants.LOGIN_REQUEST, user };
    }
    function success(user) {
        return { type: authenticationConstants.LOGIN_SUCCESS, user };
    }
    function failure(loginFailure) {
        return { type: authenticationConstants.LOGIN_FAILURE, loginFailure };
    }
    return dispatch => {
        dispatch(request({ email: data.email, password: data.password }));
        authenticationService.login(data).then(
            user => {
                dispatch(success(user));
                if (data.shipmentReq) {
                    data.shipmentReq.shipment.shipper_id = user.data.id;
                    dispatch(shipmentActions.setShipmentRoute(data.shipmentReq));
                } else if (user.data.role_id === 1 && !data.noRedirect) {
                    dispatch(push('/admin/dashboard'));
                } else if (user.data.role_id === 2 && !data.noRedirect) {
                    dispatch(push('/account'));
                }
            },
            error => {
                error.then(errorData => {
                    dispatch(failure({
                        error: errorData,
                        loginAttempt: true,
                        loggingIn: false
                    }));
                });
                // dispatch(alertActions.error(error));
            }
        );
    };
}

function register(user, redirect) {
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
                if (redirect) {
                    dispatch(push('/booking'));
                } else if (response.data.role_id === 1) {
                    dispatch(push('/admin'));
                } else if (response.data.role_id === 2) {
                    dispatch(push('/account'));
                }
            },
            error => {
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}
function setUser(user) {
    localStorage.setItem(cookieKey, JSON.stringify(user));
    return {type: authenticationConstants.SET_USER, user};
}

function updateUser(user, req, shipmentReq) {
    function request(response) {
        return { type: authenticationConstants.UPDATE_USER_REQUEST, user: response };
    }
    function success(response) {
        return { type: authenticationConstants.UPDATE_USER_SUCCESS, user: response };
    }
    function failure(error) {
        return { type: authenticationConstants.UPDATE_USER_FAILURE, error };
    }

    return dispatch => {
        dispatch(request(user));

        authenticationService.updateUser(user, req).then(
            response => {
                dispatch(success(response));
                if (shipmentReq) {
                    dispatch(shipmentActions.setShipmentRoute(shipmentReq));
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
    updateUser,
    setUser
};
