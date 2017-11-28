import { authHeader } from '../helpers';
import { Promise } from 'babel-polyfill';
import { BASE_URL } from '../constants';

function handleResponse(response) {
    if (!response.ok) {
        return Promise.reject(response.statusText);
    }

    return response.json();
}

function getLocations(user) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(
        BASE_URL + '/users/' + user.id + '/locations',
        requestOptions
    ).then(handleResponse);
}

function login(username, password) {
    const requestOptions = {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: username, password })
    };
    return fetch(BASE_URL + '/auth/sign_in', requestOptions)
        .then(response => {
            if (!response.ok) {
                return Promise.reject(response.statusText);
            }
            if (response.headers.get('access-token')) {
                const accessToken = response.headers.get('access-token');
                const client = response.headers.get('client');
                const expiry = response.headers.get('expiry');
                const tokenType = response.headers.get('token-type');
                const uid = response.headers.get('uid');
                const authHeader = {
                    client: client,
                    expiry: expiry,
                    uid: uid,
                    'access-token': accessToken,
                    'token-type': tokenType
                };
                localStorage.setItem('authHeader', JSON.stringify(authHeader));
            }
            return response.json();
        })
        .then(user => {
            // login successful if there's a jwt token in the response
            if (user) {
                // store user details and jwt token in local storage to keep user logged in between page refreshes
                localStorage.setItem('user', JSON.stringify(user));
            }

            return user;
        });
}

function getStoredUser() {
    const sortedUser = JSON.parse(localStorage.getItem('user'));
    return sortedUser ? sortedUser : {};
}

function logout() {
    // remove user from local storage to log user out
    localStorage.removeItem('user');
}

function getAll() {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/users', requestOptions).then(handleResponse);
}

function getById(id) {
    const requestOptions = {
        method: 'GET',
        headers: authHeader()
    };

    return fetch(BASE_URL + '/users/' + id, requestOptions).then(
        handleResponse
    );
}

function register(user) {
    const requestOptions = {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    };

    return fetch(BASE_URL + '/auth/sign_up', requestOptions).then(
        handleResponse
    );
}

function update(user) {
    const requestOptions = {
        method: 'PUT',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    };

    return fetch(BASE_URL + '/users/' + user.id, requestOptions).then(
        handleResponse
    );
}

// prefixed function name with underscore because delete is a reserved word in javascript
function _delete(id) {
    const requestOptions = {
        method: 'DELETE',
        headers: authHeader()
    };

    return fetch('/users/' + id, requestOptions).then(handleResponse);
}

export const userService = {
    getLocations,
    login,
    logout,
    register,
    getAll,
    getById,
    update,
    getStoredUser,
    delete: _delete
};
