import { routerReducer as routing } from 'react-router-redux';
import { combineReducers } from 'redux';
// import { authStateReducer } from 'redux-auth';
import * as types from '../actions/types';
import * as tenantActions from '../actions/tenant';
import { authentication } from './authentication.reducer';
import { registration } from './registration.reducer';
import { users } from './users.reducer';
import { alert } from './alert.reducer';

const filter = (state = '', action) => {
    switch (action.type) {
        case types.FILTER:
            return action.filter;
        default:
            return state;
    }
};
const selectedSubdomain = (state = 'greencarrier', action) => {
    switch (action.type) {
        case tenantActions.SELECT_SUBDOMAIN:
            return action.subdomain;
        default:
            return state;
    }
};

const tenant = (
  state = {
      isFetching: false,
      didInvalidate: false,
      tenant: {}
  },
  action
) => {
    switch (action.type) {
        case tenantActions.INVALIDATE_SUBDOMAIN:
            return Object.assign({}, state, {
                didInvalidate: true
            });
        case tenantActions.REQUEST_TENANT:
            return Object.assign({}, state, {
                isFetching: true,
                didInvalidate: false
            });
        case tenantActions.RECEIVE_TENANT:
            return Object.assign({}, state, {
                isFetching: false,
                didInvalidate: false,
                data: action.tenant,
                lastUpdated: action.receivedAt
            });
        default:
            return state;
    }
};

const tenantBySubdomain = (state = {}, action) => {
    switch (action.type) {
        case tenantActions.INVALIDATE_SUBDOMAIN:
        case tenantActions.RECEIVE_TENANT:
        case tenantActions.REQUEST_TENANT:
            return Object.assign({}, state, {
                [action.subdomain]: tenant(state[action.subdomain], action)
            });
        default:
            return state;
    }
};

const rootReducer = combineReducers({
    authentication,
    registration,
    users,
    alert,
    filter,
    selectedSubdomain,
    tenant,
    tenantBySubdomain,
    routing
});

export default rootReducer;

