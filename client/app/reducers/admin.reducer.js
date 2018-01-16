import { adminConstants } from '../constants';
import merge from 'lodash/merge';
export function admin(state = {}, action) {
    switch (action.type) {
        case adminConstants.WIZARD_HUBS_REQUEST:
            const reqWzHubs = merge({}, state, {
                loading: true
            });
            return reqWzHubs;
        case adminConstants.WIZARD_HUBS_SUCCESS:
            const succWzHubs = merge({}, state, {
                wizard: {
                    newHubs: action.payload.data},
                loading: false
            });
            return succWzHubs;
        case adminConstants.WIZARD_HUBS_FAILURE:
            const errWzHubs = merge({}, state, {
                error: {wizard: {
                    newHubs: action.error }}
            });
            return errWzHubs;

        case adminConstants.WIZARD_SERVICE_CHARGE_REQUEST:
            const reqWzScs = merge({}, state, {
                loading: true
            });
            return reqWzScs;
        case adminConstants.WIZARD_SERVICE_CHARGE_SUCCESS:
            const succWzScs = merge({}, state, {
                wizard: {
                    newScs: action.payload.data},
                loading: false
            });
            return succWzScs;
        case adminConstants.WIZARD_SERVICE_CHARGE_FAILURE:
            const errWzScs = merge({}, state, {
                error: {wizard: {
                    newScs: action.error }}
            });
            return errWzScs;

        case adminConstants.WIZARD_TRUCKING_REQUEST:
            const reqWzTrucking = merge({}, state, {
                loading: true
            });
            return reqWzTrucking;
        case adminConstants.WIZARD_TRUCKING_SUCCESS:
            const succWzTrucking = merge({}, state, {
                wizard: {
                    newTrucking: action.payload.data},
                loading: false
            });
            return succWzTrucking;
        case adminConstants.WIZARD_TRUCKING_FAILURE:
            const errWzTrucking = merge({}, state, {
                error: {wizard: {
                    newTrucking: action.error }}
            });
            return errWzTrucking;

        case adminConstants.WIZARD_PRICINGS_REQUEST:
            const reqWzPric = merge({}, state, {
                loading: true
            });
            return reqWzPric;
        case adminConstants.WIZARD_PRICINGS_SUCCESS:
            const succWzPric = merge({}, state, {
                wizard: {
                    newPricings: action.payload.data},
                loading: false
            });
            return succWzPric;
        case adminConstants.WIZARD_PRICINGS_FAILURE:
            const errWzPric = merge({}, state, {
                error: {wizard: {
                    newPricings: action.error }}
            });
            return errWzPric;

        case adminConstants.WIZARD_OPEN_PRICINGS_REQUEST:
            const reqWzOpenPric = merge({}, state, {
                loading: true
            });
            return reqWzOpenPric;
        case adminConstants.WIZARD_OPEN_PRICINGS_SUCCESS:
            const succWzOpenPric = merge({}, state, {
                wizard: {
                    newOpenPricings: action.payload.data},
                loading: false
            });
            return succWzOpenPric;
        case adminConstants.WIZARD_OPEN_PRICINGS_FAILURE:
            const errWzOpenPric = merge({}, state, {
                error: {wizard: {
                    newOpenPricings: action.error }}
            });
            return errWzOpenPric;

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

        case adminConstants.GET_HUB_REQUEST:
            const reqHub = merge({}, state, {
                loading: true
            });
            return reqHub;
        case adminConstants.GET_HUB_SUCCESS:
            const succHub = merge({}, state, {
                hub: action.payload.data,
                loading: false
            });
            return succHub;
        case adminConstants.GET_HUB_FAILURE:
            const errHub = merge({}, state, {
                error: { hub: action.error }
            });
            return errHub;

        case adminConstants.GET_DASHBOARD_REQUEST:
            const reqDash = merge({}, state, {
                loading: true
            });
            return reqDash;
        case adminConstants.GET_DASHBOARD_SUCCESS:
            const succDash = merge({}, state, {
                dashboard: action.payload.data,
                loading: false
            });
            return succDash;
        case adminConstants.GET_DASHBOARD_FAILURE:
            const errDash = merge({}, state, {
                error: { hubs: action.error }
            });
            return errDash;


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
            const shipments = state.shipments.open.filter(x => x.status !== 'ignored');
            // const succConfShip = merge({}, state, {
            //     shipment: action.payload.data,
            //     shipments: {
            //         open: shipments
            //     },
            //     loading: false
            // });
            const succConfShip = {
                ...state,
                shipments: {
                    open: shipments,
                    ...state.shipments
                },
                loading: false
            };
            console.log(action.payload.data);
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

        case adminConstants.UPDATE_PRICING_REQUEST:
            return state;
        case adminConstants.UPDATE_PRICING_SUCCESS:
            return state;
        case adminConstants.UPDATE_PRICING_FAILURE:
            return state;

        case adminConstants.UPDATE_SERVICE_CHARGES_REQUEST:
            return state;
        case adminConstants.UPDATE_SERVICE_CHARGES_SUCCESS:
            const scs = state.serviceCharges;
            const newScs = [action.payload];
            scs.forEach(sc => {
                if (sc.id !== action.payload.id) {
                    newScs.push(sc);
                }
            });
            const newState = merge({}, state, {
                serviceCharges: newScs,
                loading: false
            });
            return newState;
        case adminConstants.UPDATE_SERVICE_CHARGES_FAILURE:
            return state;

        case adminConstants.GET_CLIENT_PRICINGS_REQUEST:
            const reqClientPric = merge({}, state, {
                loading: true
            });
            return reqClientPric;
        case adminConstants.GET_CLIENT_PRICINGS_SUCCESS:
            // ;
            const succClientPric = merge({}, state, {
                clientPricings: action.payload.data,
                loading: false
            });
            return succClientPric;
        case adminConstants.GET_CLIENT_PRICINGS_FAILURE:
            const errClientPric = merge({}, state, {
                error: { pricings: action.error }
            });
            return errClientPric;

        case adminConstants.GET_ROUTE_PRICINGS_REQUEST:
            const reqRoutePric = merge({}, state, {
                loading: true
            });
            return reqRoutePric;
        case adminConstants.GET_ROUTE_PRICINGS_SUCCESS:
            // ;
            const succRoutePric = merge({}, state, {
                routePricings: action.payload.data,
                loading: false
            });
            return succRoutePric;
        case adminConstants.GET_ROUTE_PRICINGS_FAILURE:
            const errRoutePric = merge({}, state, {
                error: { pricings: action.error }
            });
            return errRoutePric;

        case adminConstants.GET_CLIENTS_REQUEST:
            const reqClients = merge({}, state, {
                loading: true
            });
            return reqClients;
        case adminConstants.GET_CLIENTS_SUCCESS:
            // ;
            const succClients = merge({}, state, {
                clients: action.payload.data,
                loading: false
            });
            return succClients;
        case adminConstants.GET_CLIENTS_FAILURE:
            const errClients = merge({}, state, {
                error: { clients: action.error }
            });
            return errClients;

        case adminConstants.GET_CLIENT_REQUEST:
            const reqClient = merge({}, state, {
                loading: true
            });
            return reqClient;
        case adminConstants.GET_CLIENT_SUCCESS:
            // ;
            const succClient = merge({}, state, {
                client: action.payload.data,
                loading: false
            });
            return succClient;
        case adminConstants.GET_CLIENT_FAILURE:
            const errClient = merge({}, state, {
                error: { client: action.error }
            });
            return errClient;

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

        case adminConstants.GET_ROUTES_REQUEST:
            const reqRoutes = merge({}, state, {
                loading: true
            });
            return reqRoutes;
        case adminConstants.GET_ROUTES_SUCCESS:
            const succRoutes = merge({}, state, {
                routes: action.payload.data,
                loading: false
            });
            return succRoutes;
        case adminConstants.GET_ROUTES_FAILURE:
            const errRoutes = merge({}, state, {
                error: { routes: action.error }
            });
            return errRoutes;

        case adminConstants.GET_ROUTE_REQUEST:
            const reqRoute = merge({}, state, {
                loading: true
            });
            return reqRoute;
        case adminConstants.GET_ROUTE_SUCCESS:
            const succRoute = merge({}, state, {
                route: action.payload.data,
                loading: false
            });
            return succRoute;
        case adminConstants.GET_ROUTE_FAILURE:
            const errRoute = merge({}, state, {
                error: { route: action.error }
            });
            return errRoute;

        case adminConstants.ACTIVATE_HUB_REQUEST:
            const reqHubActivate = merge({}, state, {
                loading: true
            });
            return reqHubActivate;
        case adminConstants.ACTIVATE_HUB_SUCCESS:
            const succHubActivate = merge({}, state, {
                hub: action.payload.data,
                loading: false
            });
            return succHubActivate;
        case adminConstants.ACTIVATE_HUB_FAILURE:
            const errHubActivate = merge({}, state, {
                error: { hub: action.error }
            });
            return errHubActivate;

        case adminConstants.VIEW_TRUCKING:
            const newTrucking = merge({}, state, {
                truckingDetail: action.payload
            });
            return newTrucking;

        default:
            return state;
    }
}
