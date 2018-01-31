import { appConstants } from '../constants';
import { appService } from '../services';
import { authenticationActions } from '../actions';
import { alertActions, shipmentActions, userActions, adminActions } from './';
import { BASE_URL } from '../constants';
import { Promise } from 'es6-promise-promise';
// import { Promise } from 'es6-promise-promise';
// import { push } from 'react-router-redux';

function fetchCurrencies(type) {
    function request(currencyReq) {
        return { type: appConstants.FETCH_CURRENCIES_REQUEST, payload: currencyReq };
    }
    function success(currencyData) {
        return { type: appConstants.FETCH_CURRENCIES_SUCCESS, payload: currencyData };
    }
    function failure(error) {
        return { type: appConstants.FETCH_CURRENCIES_ERROR, error };
    }
    return dispatch => {
        dispatch(request(type));
        appService.fetchCurrencies(type).then(
            resp => {
                const currData = resp.data;
                dispatch(
                    alertActions.success('Fetching Currency successful')
                );
                dispatch(success(currData));
            },
            error => {
                error.then(data => {
                    dispatch(failure({ type: 'error', text: data.message }));
                });
            }
        );
    };
}

function setCurrency(type) {
    function request(currencyReq) {
        return { type: appConstants.SET_CURRENCY_REQUEST, payload: currencyReq };
    }
    function success(currencyData) {
        return { type: appConstants.SET_CURRENCY_SUCCESS, payload: currencyData };
    }
    function failure(error) {
        return { type: appConstants.SET_CURRENCY_ERROR, error };
    }
    return dispatch => {
        dispatch(request(type));
        appService.setCurrency(type).then(
            resp => {
                dispatch(
                    alertActions.success('Fetching Currency successful')
                );
                dispatch(success(resp.data.rates));
                dispatch(authenticationActions.setUser({data: resp.data.user}));
            },
            error => {
                error.then(data => {
                    dispatch(failure({ type: 'error', text: data.message }));
                });
            }
        );
    };
}

function requestTenant(subdomain) {
    return {
        type: appConstants.REQUEST_TENANT,
        subdomain
    };
}

function receiveTenant(subdomain, json) {
    return {
        type: appConstants.RECEIVE_TENANT,
        subdomain,
        data: json,
        receivedAt: Date.now()
    };
}

function invalidateSubdomain(subdomain) {
    return {
        type: appConstants.INVALIDATE_SUBDOMAIN,
        subdomain
    };
}

function fetchTenant(subdomain) {
    function failure(error) {
        return { type: appConstants.RECEIVE_TENANT_ERROR, error };
    }
    console.log(BASE_URL);
    return dispatch => {
        dispatch(requestTenant(subdomain));
        return fetch(`${BASE_URL}/tenants/${subdomain}`)
            .then(response => response.json())
            .then(
                json => dispatch(receiveTenant(subdomain, json)),
                err => dispatch(failure(err))
            );
    };
}


function shouldFetchTenant(state, subdomain) {
    const tenant = state[subdomain];
    if (!tenant) {
        return true;
    }
    if (tenant.isFetching) {
        return false;
    }
    return tenant.didInvalidate;
}

function fetchTenantIfNeeded(subdomain) {
    // Note that the function also receives getState()
    // which lets you choose what to dispatch next.

    // This is useful for avoiding a network request if
    // a cached value is already available.

    return (dispatch, getState) => {
        if (shouldFetchTenant(getState(), subdomain)) {
            // Dispatch a thunk from thunk!
            return dispatch(fetchTenant(subdomain));
        }

        // Let the calling code know there's nothing to wait for.
        return Promise.resolve();
    };
}

function clearLoading() {
    return dispatch => {
        dispatch(shipmentActions.clearLoading());
        dispatch(userActions.clearLoading());
        dispatch(adminActions.clearLoading());
    };
}


export const appActions = {
    fetchCurrencies,
    shouldFetchTenant,
    fetchTenantIfNeeded,
    invalidateSubdomain,
    setCurrency,
    clearLoading
};
