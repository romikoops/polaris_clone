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
            const succShips = merge({}, state, {
                shipments: action.payload.data,
                loading: false
            });
            return succShips;
        case adminConstants.GET_SHIPMENTS_FAILURE:
            const errShips = merge({}, state, {
                error: { shipments: action.error }
            });
            return errShips;

        case adminConstants.ADMIN_GET_SHIPMENT_REQUEST:
            const reqShip = merge({}, state, {
                loading: true
            });
            return reqShip;
        case adminConstants.ADMIN_GET_SHIPMENT_SUCCESS:
            const succShip = merge({}, state, {
                shipment: action.payload.data,
                loading: false
            });
            return succShip;
        case adminConstants.ADMIN_GET_SHIPMENT_FAILURE:
            const errShip = merge({}, state, {
                error: { shipments: action.error }
            });
            return errShip;

        case adminConstants.CONFIRM_SHIPMENT_REQUEST:
            const reqConfShip = merge({}, state, {
                loading: true
            });
            return reqConfShip;
        case adminConstants.CONFIRM_SHIPMENT_SUCCESS:
            const succConfShip = merge({}, state, {
                shipment: action.payload.data,
                loading: false
            });
            return succConfShip;
        case adminConstants.CONFIRM_SHIPMENT_FAILURE:
            const errConfShip = merge({}, state, {
                error: { shipments: action.error }
            });
            return errConfShip;


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

        case adminConstants.GENERATE_SCHEDULES_REQUEST:
            const reqGenSched = merge({}, state, {
                loading: true
            });
            return reqGenSched;
        case adminConstants.GENERATE_SCHEDULES_SUCCESS:
            const succGenSched = merge({}, state, {
                schedules: action.payload.data,
                loading: false
            });
            return succGenSched;
        case adminConstants.GENERATE_SCHEDULES_FAILURE:
            const errGenSched = merge({}, state, {
                error: { schedules: action.error }
            });
            return errGenSched;

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

        case adminConstants.GET_VEHICLE_TYPES_REQUEST:
            const reqVehicleTypes = merge({}, state, {
                loading: true
            });
            return reqVehicleTypes;
        case adminConstants.GET_VEHICLE_TYPES_SUCCESS:
            const succVehicleTypes = merge({}, state, {
                vehicleTypes: action.payload.data,
                loading: false
            });
            return succVehicleTypes;
        case adminConstants.GET_VEHICLE_TYPES_FAILURE:
            const errVehicleTypes = merge({}, state, {
                error: { vehicleTypes: action.error }
            });
            return errVehicleTypes;


        case adminConstants.GET_PRICINGS_REQUEST:
            const reqPric = merge({}, state, {
                loading: true
            });
            return reqPric;
        case adminConstants.GET_PRICINGS_SUCCESS:
            // debugger;
            const succPric = merge({}, {
                pricingData: action.payload.data,
                loading: false
            }, state);
            return succPric;
        case adminConstants.GET_PRICINGS_FAILURE:
            const errPric = merge({}, state, {
                error: { pricings: action.error }
            });
            return errPric;

        case adminConstants.GET_CLIENTS_REQUEST:
            const reqClients = merge({}, state, {
                loading: true
            });
            return reqClients;
        case adminConstants.GET_CLIENTS_SUCCESS:
            // debugger;
            const succClients = merge({}, {
                clients: action.payload.data,
                loading: false
            }, state);
            return succClients;
        case adminConstants.GET_CLIENTS_FAILURE:
            const errClients = merge({}, state, {
                error: { pricings: action.error }
            });
            return errClients;

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
