import { routerReducer as routing } from 'react-router-redux';
import { combineReducers } from 'redux';
// import { authStateReducer } from 'redux-auth';
import * as types from '../actions/types';
import { authentication } from './authentication.reducer';
import { registration } from './registration.reducer';
import { shipment } from './shipment.reducer';
import { users } from './users.reducer';
import { alert } from './alert.reducer';
import { tenant, selectedSubdomain } from './tenant.reducer';

const filter = (state = '', action) => {
    switch (action.type) {
        case types.FILTER:
            return action.filter;
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
    bookingData: shipment,
    selectedSubdomain,
    tenant,
    routing
});

export default rootReducer;

