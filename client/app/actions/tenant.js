import fetch from 'isomorphic-fetch';
import { Promise } from 'es6-promise-promise';
export const REQUEST_TENANT = 'REQUEST_TENANT';
export const RECEIVE_TENANT = 'RECEIVE_TENANT';
export const INVALIDATE_SUBDOMAIN = 'INVALIDATE_SUBDOMAIN';

const requestTenant = (subdomain) => {
    return {
        type: REQUEST_TENANT,
        subdomain
    };
};

const receiveTenant = (subdomain, json) => {
    return {
        type: RECEIVE_TENANT,
        subdomain,
        data: json,
        receivedAt: Date.now()
    };
};

export const invalidateSubdomain = (subdomain) => {
    return {
        type: INVALIDATE_SUBDOMAIN,
        subdomain
    };
};

const fetchTenant = (subdomain) => {
    return dispatch => {
        dispatch(requestTenant(subdomain));
        return fetch(`http://localhost:3000/tenants/${subdomain}`)
      .then(response => response.json())
      .then(json => dispatch(receiveTenant(subdomain, json)));
    };
};

const shouldFetchTenant = (state, subdomain) => {
    const tenant = state[subdomain];
    if (!tenant) {
        return true;
    }
    if (tenant.isFetching) {
        return false;
    }
    return tenant.didInvalidate;
};

export const fetchTenantIfNeeded = (subdomain) => {
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
};
