import { adminConstants } from '../constants';
import merge from 'lodash/merge';
export function admin(state = {}, action) {
    switch (action.type) {
        case adminConstants.GET_HUBS_REQUEST:
            return {
                loading: true
            };
        case adminConstants.GET_HUBS_SUCCESS:
            return {
                hubs: action.payload,
                loading: false
            };
        case adminConstants.GET_HUBS_FAILURE:
            const errHubs = merge({}, state, {
                error: { hubs: action.error }
            });
            return errHubs;
        case adminConstants.GET_SHIPMENTS_REQUEST:
            return {
                loading: true
            };
        case adminConstants.GET_SHIPMENTS_SUCCESS:
            return {
                shipments: action.payload,
                loading: false
            };
        case adminConstants.GET_SHIPMENTS_FAILURE:
            const errShip = merge({}, state, {
                error: { shipments: action.error }
            });
            return errShip;
        case adminConstants.GET_SCHEDULES_REQUEST:
            return {
                loading: true
            };
        case adminConstants.GET_SCHEDULES_SUCCESS:
            return {
                schedules: action.payload,
                loading: false
            };
        case adminConstants.GET_SCHEDULES_FAILURE:
            const errSched = merge({}, state, {
                error: { schedules: action.error }
            });
            return errSched;
        case adminConstants.GET_TRUCKING_REQUEST:
            return {
                loading: true
            };
        case adminConstants.GET_TRUCKING_SUCCESS:
            return {
                trucking: action.payload,
                loading: false
            };
        case adminConstants.GET_TRUCKING_FAILURE:
            const errTruck = merge({}, state, {
                error: { trucking: action.error }
            });
            return errTruck;

        case adminConstants.GET_PRICINGS_REQUEST:
            return {
                loading: true
            };
        case adminConstants.GET_PRICINGS_SUCCESS:
            return {
                pricings: action.payload,
                loading: false
            };
        case adminConstants.GET_PRICINGS_FAILURE:
            const errPric = merge({}, state, {
                error: { pricings: action.error }
            });
            return errPric;
        case adminConstants.GET_SERVICE_CHARGES_REQUEST:
            return {
                loading: true
            };
        case adminConstants.GET_SERVICE_CHARGES_SUCCESS:
            return {
                serviceCharges: action.payload,
                loading: false
            };
        case adminConstants.GET_SERVICE_CHARGES_FAILURE:
            const errSC = merge({}, state, {
                error: { serviceCharges: action.error }
            });
            return errSC;
        default:
            return state;
    }
}
