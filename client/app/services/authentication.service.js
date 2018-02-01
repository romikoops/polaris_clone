import { Promise } from 'es6-promise-promise';
import { BASE_URL } from '../constants';
import { authHeader, getSubdomain } from '../helpers';
const subdomainKey = getSubdomain();
const cookieKey = subdomainKey + '_user';
function logout() {
    // remove user from local storage to log user out
    localStorage.removeItem(cookieKey);
}

function login(data) {
    const requestOptions = {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: data.email, password: data.password })
    };
    return fetch(BASE_URL + '/auth/sign_in', requestOptions)
        .then(response => {
            if (!response.ok) {
                return Promise.reject(response.json());
            }
            if (response.headers.get('access-token')) {
                const accessToken = response.headers.get('access-token');
                const client = response.headers.get('client');
                const expiry = response.headers.get('expiry');
                const tokenType = response.headers.get('token-type');
                const uid = response.headers.get('uid');
                const aHeader = {
                    client: client,
                    expiry: expiry,
                    uid: uid,
                    'access-token': accessToken,
                    'token-type': tokenType
                };
                localStorage.setItem('authHeader', JSON.stringify(aHeader));
            }
            return response.json();
        })
        .then(user => {
            // login successful if there's a jwt token in the response
            if (user) {
                // store user details and jwt token in local storage to keep user logged in between page refreshes
                localStorage.setItem(cookieKey, JSON.stringify(user));
            }

            return user;
        });
}

function getStoredUser() {
    const sortedUser = JSON.parse(localStorage.getItem(cookieKey));
    return sortedUser ? sortedUser : {};
}

function register(user) {
    const requestOptions = {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    };

    return fetch(BASE_URL + '/auth/', requestOptions)
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
                const aHeader = {
                    client: client,
                    expiry: expiry,
                    uid: uid,
                    'access-token': accessToken,
                    'token-type': tokenType
                };
                localStorage.setItem('authHeader', JSON.stringify(aHeader));
            }
            return response.json();
        })
        .then(data => {
            // login successful if there's a jwt token in the response
            if (data) {
                // store user details and jwt token in local storage to keep user logged in between page refreshes
                localStorage.setItem(cookieKey, JSON.stringify(data));
                const user2 = localStorage.getItem(cookieKey);
                console.log(user2);
            }
            return data;
        });
}

function updateUser(user, req) {
    const requestOptions = {
        method: 'PUT',
        headers: { ...authHeader(), 'Content-Type': 'application/json' },
        body: JSON.stringify({update: req})
    };

    return fetch(BASE_URL + '/users/' + user.id + '/update', requestOptions)
        .then(response => {
            if (!response.ok) {
                return Promise.reject(response.statusText);
            }
            return response.json();
        })
        .then(data => {
            // login successful if there's a jwt token in the response
            let resp;
            if (data) {
                if (data.data.headers) {
                    localStorage.setItem('authHeader', JSON.stringify(data.data.headers));
                }
                resp = {data: data.data.user};
                // store user details and jwt token in local storage to keep user logged in between page refreshes
                localStorage.setItem(cookieKey, JSON.stringify(resp));
            }
            return resp;
        });
}

export const authenticationService = {
    login,
    logout,
    register,
    getStoredUser,
    updateUser
};
