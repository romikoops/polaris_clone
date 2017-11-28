import { userConstants } from '../constants';
import { userService } from '../services';
import { alertActions } from './';
import { history } from '../helpers';

function login(username, password) {
    function request(user) { return { type: userConstants.LOGIN_REQUEST, user }; }
    function success(user) { return { type: userConstants.LOGIN_SUCCESS, user }; }
    function failure(error) { return { type: userConstants.LOGIN_FAILURE, error }; }
    return dispatch => {
        dispatch(request({ username }));
        userService.login(username, password)
            .then(
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
    userService.logout();
    return { type: userConstants.LOGOUT };
}

function register(user) {
    function request(user) { return { type: userConstants.REGISTER_REQUEST, user }; }
    function success(user) { return { type: userConstants.REGISTER_SUCCESS, user }; }
    function failure(error) { return { type: userConstants.REGISTER_FAILURE, error }; }
    return dispatch => {
        dispatch(request(user));

        userService.register(user)
            .then(
                userData => {
                    dispatch(success(userData));
                    history.push('/login');
                    dispatch(alertActions.success('Registration successful'));
                },
                error => {
                    dispatch(failure(error));
                    dispatch(alertActions.error(error));
                }
            );
    };
}

function getLocations() {
    function request() { return { type: userConstants. }; }
    function success(users) { return { type: userConstants., users }; }
    function failure(error) { return { type: userConstants., error }; }
    return dispatch => {
        dispatch(request());

        userService.getLocations()
            .then(
                users => dispatch(success(users)),
                error => dispatch(failure(error))
           
}

function getAll() {
    function request() { return { type: userConstants.GETALL_REQUEST }; }
    function success(users) { return { type: userConstants.GETALL_SUCCESS, users }; }
    function failure(error) { return { type: userConstants.GETALL_FAILURE, error }; }
    return dispatch => {
        dispatch(request());

        userService.getAll()
            .then(
                users => dispatch(success(users)),
                error => dispatch(failure(error))
            );
    };
}

// prefixed function name with underscore because delete is a reserved word in javascript
function _delete(id) {
    function request(id) { return { type: userConstants.DELETE_REQUEST, id }; }
    function success(id) { return { type: userConstants.DELETE_SUCCESS, id }; }
    function failure(id, error) { return { type: userConstants.DELETE_FAILURE, id, error }; }
    return dispatch => {
        dispatch(request(id));
        userService.delete(id)
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
export const userActions = {
    login,
    logout,
    register,
    getAll,
    delete: _delete
};

