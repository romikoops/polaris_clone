import { adminConstants } from '../constants';
import merge from 'lodash/merge';
export function admin(state = {}, action) {
    switch (action.type) {
        case adminConstants.GET_HUBS_REQUEST:
            const reqHubs = merge({}, state, {
                loading: true
            });
            return reqHubs;
        case adminConstants.GET_HUBS_SUCCESS:
            const succHubs = merge({}, state, {
                hubs: action.payload.data,
                loading: false
            });
            return succHubs;
        case adminConstants.GET_HUBS_FAILURE:
            const errHubs = merge({}, state, {
                error: { hubs: action.error }
            });
            return errHubs;
        case adminConstants.GET_SHIPMENTS_REQUEST:
             const reqShips = merge({}, state, {
                loading: true
            });
            return reqShips;
        case adminConstants.GET_SHIPMENTS_SUCCESS:
            const succShip = merge({}, state, {
                shipments: action.payload.data,
                loading: false
            });
            return succShip;
        case adminConstants.GET_SHIPMENTS_FAILURE:
            const errShip = merge({}, state, {
                error: { shipments: action.error }
            });
            return errShip;
        case adminConstants.GET_SCHEDULES_REQUEST:
             const reqSched = merge({}, state, {
                loading: true
            });
            return reqSched;
        case adminConstants.GET_SCHEDULES_SUCCESS:
            const succSched = merge({}, state, {
                schedules: action.payload.data,
                loading: false
            });
            return succSched;
        case adminConstants.GET_SCHEDULES_FAILURE:
            const errSched = merge({}, state, {
                error: { schedules: action.error }
            });
            return errSched;
        case adminConstants.GET_TRUCKING_REQUEST:
             const reqTruck = merge({}, state, {
                loading: true
            });
            return reqTruck;
        case adminConstants.GET_TRUCKING_SUCCESS:
            const succTruck = merge({}, state, {
                trucking: action.payload.data,
                loading: false
            });
            return succTruck;
        case adminConstants.GET_TRUCKING_FAILURE:
            const errTruck = merge({}, state, {
                error: { trucking: action.error }
            });
            return errTruck;

        case adminConstants.GET_PRICINGS_REQUEST:
             const reqPric = merge({}, state, {
                loading: true
            });
            return reqPric;
        case adminConstants.GET_PRICINGS_SUCCESS:
            const succPric = merge({}, state, {
                pricingData: action.payload.data,
                loading: false
            });
            return succPric;
        case adminConstants.GET_PRICINGS_FAILURE:
            const errPric = merge({}, state, {
                error: { pricings: action.error }
            });
            return errPric;
        case adminConstants.GET_SERVICE_CHARGES_REQUEST:
             const reqSC = merge({}, state, {
                loading: true
            });
            return reqSC;
        case adminConstants.GET_SERVICE_CHARGES_SUCCESS:
            const succSC = merge({}, state, {
                serviceCharges: action.payload.data,
                loading: false
            });
            return succSC;
        case adminConstants.GET_SERVICE_CHARGES_FAILURE:
            const errSC = merge({}, state, {
                error: { serviceCharges: action.error }
            });
            return errSC;
        default:
            return state;
    }
}
