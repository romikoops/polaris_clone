import merge from 'lodash/merge'
import { adminConstants } from '../constants'

export default function admin (state = {}, action) {
  switch (action.type) {
    case adminConstants.WIZARD_HUBS_REQUEST: {
      const reqWzHubs = merge({}, state, {
        loading: true
      })
      return reqWzHubs
    }
    case adminConstants.WIZARD_HUBS_SUCCESS: {
      const succWzHubs = merge({}, state, {
        wizard: {
          newHubs: action.payload.data
        },
        loading: false
      })
      return succWzHubs
    }
    case adminConstants.WIZARD_HUBS_FAILURE: {
      const errWzHubs = merge({}, state, {
        error: {
          wizard: {
            newHubs: action.error
          }
        },
        loading: false
      })
      return errWzHubs
    }

    case adminConstants.WIZARD_SERVICE_CHARGE_REQUEST: {
      const reqWzScs = merge({}, state, {
        loading: true
      })
      return reqWzScs
    }
    case adminConstants.WIZARD_SERVICE_CHARGE_SUCCESS: {
      const succWzScs = merge({}, state, {
        wizard: {
          newScs: action.payload.data
        },
        loading: false
      })
      return succWzScs
    }
    case adminConstants.WIZARD_SERVICE_CHARGE_FAILURE: {
      const errWzScs = merge({}, state, {
        error: {
          wizard: {
            newScs: action.error
          }
        },
        loading: false
      })
      return errWzScs
    }

    case adminConstants.WIZARD_TRUCKING_REQUEST: {
      const reqWzTrucking = merge({}, state, {
        loading: true
      })
      return reqWzTrucking
    }
    case adminConstants.WIZARD_TRUCKING_SUCCESS: {
      const succWzTrucking = merge({}, state, {
        wizard: {
          newTrucking: action.payload.data
        },
        loading: false
      })
      return succWzTrucking
    }
    case adminConstants.WIZARD_TRUCKING_FAILURE: {
      const errWzTrucking = merge({}, state, {
        error: {
          wizard: {
            newTrucking: action.error
          }
        },
        loading: false
      })
      return errWzTrucking
    }

    case adminConstants.WIZARD_PRICINGS_REQUEST: {
      const reqWzPric = merge({}, state, {
        loading: true
      })
      return reqWzPric
    }
    case adminConstants.WIZARD_PRICINGS_SUCCESS: {
      const succWzPric = merge({}, state, {
        wizard: {
          newPricings: action.payload.data
        },
        loading: false
      })
      return succWzPric
    }
    case adminConstants.WIZARD_PRICINGS_FAILURE: {
      const errWzPric = merge({}, state, {
        error: {
          wizard: {
            newPricings: action.error
          }
        },
        loading: false
      })
      return errWzPric
    }

    case adminConstants.WIZARD_OPEN_PRICINGS_REQUEST: {
      const reqWzOpenPric = merge({}, state, {
        loading: true
      })
      return reqWzOpenPric
    }
    case adminConstants.WIZARD_OPEN_PRICINGS_SUCCESS: {
      const succWzOpenPric = merge({}, state, {
        wizard: {
          newOpenPricings: action.payload.data
        },
        loading: false
      })
      return succWzOpenPric
    }
    case adminConstants.WIZARD_OPEN_PRICINGS_FAILURE: {
      const errWzOpenPric = merge({}, state, {
        error: {
          wizard: {
            newOpenPricings: action.error
          }
        },
        loading: false
      })
      return errWzOpenPric
    }

    case adminConstants.GET_HUBS_REQUEST: {
      const reqHubs = merge({}, state, {
        loading: true
      })
      return reqHubs
    }
    case adminConstants.GET_HUBS_SUCCESS:
      return {
        ...state,
        hubs: action.payload.data,
        loading: false
      }
    case adminConstants.GET_HUBS_FAILURE: {
      const errHubs = merge({}, state, {
        error: { hubs: action.error },
        loading: false
      })
      return errHubs
    }
    case adminConstants.GET_HUB_REQUEST: {
      const reqHub = merge({}, state, {
        loading: true
      })
      return reqHub
    }
    case adminConstants.GET_HUB_SUCCESS:
      return {
        ...state,
        hub: action.payload.data,
        loading: false
      }
    case adminConstants.GET_HUB_FAILURE: {
      const errHub = merge({}, state, {
        error: { hub: action.error },
        loading: false
      })
      return errHub
    }
    case adminConstants.DELETE_HUB_REQUEST: {
      const reqHub = merge({}, state, {
        loading: true
      })
      return reqHub
    }
    // eslint-disable-next-line no-case-declarations
    case adminConstants.DELETE_HUB_SUCCESS:
      const hubs = state.hubs.filter(x => x.id !== parseInt(action.payload.id, 10))
      const hub = state.hub.hub.id === parseInt(action.payload.id, 10) ? {} : state.hub
      return {
        ...state,
        hub,
        hubs,
        loading: false
      }
    case adminConstants.DELETE_HUB_FAILURE: {
      const errHub = merge({}, state, {
        error: { hub: action.error },
        loading: false
      })
      return errHub
    }
    case adminConstants.GET_DASHBOARD_REQUEST: {
      const reqDash = merge({}, state, {
        loading: true
      })
      return reqDash
    }
    case adminConstants.GET_DASHBOARD_SUCCESS:
      return {
        ...state,
        dashboard: action.payload.data,
        shipments: action.payload.data.shipments,
        loading: false
      }
    case adminConstants.GET_DASHBOARD_FAILURE: {
      const errDash = merge({}, state, {
        error: { hubs: action.error },
        loading: false
      })
      return errDash
    }

    case adminConstants.ADMIN_GET_SHIPMENTS_REQUEST: {
      const reqShips = merge({}, state, {
        loading: true
      })
      return reqShips
    }
    case adminConstants.ADMIN_GET_SHIPMENTS_SUCCESS:
      return {
        ...state,
        dashboard: {
          ...state.dashboard,
          shipments: action.payload.data
        },
        shipments: action.payload.data,
        loading: false
      }
    case adminConstants.ADMIN_GET_SHIPMENTS_FAILURE: {
      const errShips = merge({}, state, {
        error: { shipments: action.error },
        loading: false
      })
      return errShips
    }

    case adminConstants.GET_DASH_SHIPMENTS_REQUEST:
      return merge({}, state, {
        loading: true
      })
    case adminConstants.GET_DASH_SHIPMENTS_SUCCESS:
      return {
        ...state,
        dashboard: {
          ...state.dashboard,
          shipments: action.payload.data
        },
        loading: false
      }
    case adminConstants.GET_DASH_SHIPMENTS_FAILURE:
      return merge({}, state, {
        error: { shipments: action.error },
        loading: false
      })

    case adminConstants.ADMIN_GET_SHIPMENT_REQUEST: {
      const reqShip = merge({}, state, {
        loading: true
      })
      return reqShip
    }
    case adminConstants.ADMIN_GET_SHIPMENT_SUCCESS:
      return {
        ...state,
        shipment: action.payload.data,
        loading: false
      }
    case adminConstants.ADMIN_GET_SHIPMENT_FAILURE: {
      const errShip = merge({}, state, {
        error: { shipments: action.error },
        loading: false
      })
      return errShip
    }

    case adminConstants.CONFIRM_SHIPMENT_REQUEST: {
      const reqConfShip = merge({}, state, {
        loading: true
      })
      return reqConfShip
    }
    case adminConstants.CONFIRM_SHIPMENT_SUCCESS: {
      const req =
        state.shipments && state.shipments.requested
          ? state.shipments.requested.filter(x => x.id !== action.payload.id)
          : []
      const dashReq =
        state.dashboard && state.dashboard.shipments && state.dashboard.shipments.requested
          ? state.dashboard.shipments.requested.filter(x => x.id !== action.payload.id)
          : []
      const open = state.shipments && state.shipments.open ? state.shipments.open : []
      const dashOpen =
        state.dashboard && state.dashboard.shipments && state.dashboard.shipments.open
          ? state.dashboard.shipments.open
          : []
      open.push(action.payload)
      dashOpen.push(action.payload)
      const shipment = state.shipment && state.shipment.shipment ? state.shipment.shipment : {}
      if (shipment) {
        shipment.status = 'confirmed'
      }
      return {
        ...state,
        dashboard: {
          ...state.dashboard,
          shipments: {
            ...state.dashboard.shipments,
            open: dashOpen,
            requested: dashReq
          }
        },
        shipments: {
          ...state.shipments,
          open,
          requested: req
        },
        shipment: {
          ...state.shipment,
          shipment
        },
        loading: false
      }
    }
    case adminConstants.FINISHED_SHIPMENT_SUCCESS: {
      const req =
        state.shipments && state.shipments.requested
          ? state.shipments.requested.filter(x => x.id !== action.payload.id)
          : []
      const dashReq =
        state.dashboard && state.dashboard.shipments && state.dashboard.shipments.requested
          ? state.dashboard.shipments.requested.filter(x => x.id !== action.payload.id)
          : []
      const finished = state.shipments && state.shipments.finished ? state.shipments.finished : []
      const dashFinished =
        state.dashboard && state.dashboard.shipments && state.dashboard.shipments.finished
          ? state.dashboard.shipments.finished
          : []
      finished.push(action.payload)
      dashFinished.push(action.payload)
      const shipment = state.shipment && state.shipment.shipment ? state.shipment.shipment : {}
      if (shipment) {
        shipment.status = 'finished'
      }
      return {
        ...state,
        dashboard: {
          ...state.dashboard,
          shipments: {
            ...state.dashboard.shipments,
            open: dashFinished,
            requested: dashReq
          }
        },
        shipments: {
          ...state.shipments,
          finished,
          requested: req
        },
        shipment: {
          ...state.shipment,
          shipment
        },
        loading: false
      }
    }
    case adminConstants.CONFIRM_SHIPMENT_FAILURE: {
      const errConfShip = merge({}, state, {
        error: { shipments: action.error },
        loading: false
      })
      return errConfShip
    }

    case adminConstants.DENY_SHIPMENT_REQUEST:
      return {
        ...state,
        loading: true
      }
    case adminConstants.DENY_SHIPMENT_SUCCESS: {
      const denReq =
        state.shipments && state.shipments.requested
          ? state.shipments.requested.filter(x => x.id !== action.payload.id)
          : []
      const denDashReq =
        state.dashboard && state.dashboard.shipments && state.dashboard.shipments.requested
          ? state.dashboard.shipments.requested.filter(x => x.id !== action.payload.id)
          : []
      return {
        ...state,
        dashboard: {
          ...state.dashboard,
          shipments: {
            ...state.dashboard.shipments,
            requested: denDashReq
          }
        },
        shipments: {
          ...state.shipments,
          requested: denReq
        },
        loading: false
      }
    }
    case adminConstants.DENY_SHIPMENT_FAILURE:
      return {
        ...state,
        error: { shipments: action.error },
        loading: false
      }

    case adminConstants.GET_SCHEDULES_REQUEST:
      return {
        ...state,
        loading: true
      }
    case adminConstants.GET_SCHEDULES_SUCCESS:
      return {
        ...state,
        schedules: action.payload.data,
        loading: false
      }
    case adminConstants.GET_SCHEDULES_FAILURE: {
      const errSched = merge({}, state, {
        error: { schedules: action.error },
        loading: false
      })
      return errSched
    }

    case adminConstants.GENERATE_SCHEDULES_REQUEST: {
      return {
        ...state,
        loading: true
      }
    }
    case adminConstants.GENERATE_SCHEDULES_SUCCESS: {
      return {
        ...state,
        schedules: action.payload.data,
        loading: false
      }
    }
    case adminConstants.GENERATE_SCHEDULES_FAILURE: {
      return {
        error: { schedules: action.error },
        loading: false
      }
    }

    case adminConstants.EDIT_TRUCKING_PRICE_REQUEST: {
      return {
        ...state,
        loading: true
      }
    }
    case adminConstants.EDIT_TRUCKING_PRICE_SUCCESS: {
      const otps = state.truckingDetail.truckingPricings
        .filter(tp => tp.truckingPricing.id === action.payload.id)[0]
      const tps = state.truckingDetail.truckingPricings
        .filter(tp => tp.truckingPricing.id !== action.payload.id)
      otps.truckingPricing = action.payload
      tps.push(otps)
      return {
        ...state,
        truckingDetail: {
          ...state.truckingDetail,
          truckingPricings: tps
        },
        loading: false
      }
    }
    case adminConstants.EDIT_TRUCKING_PRICE_FAILURE: {
      return {
        ...state,
        error: { schedules: action.error },
        loading: false
      }
    }

    case adminConstants.GET_TRUCKING_REQUEST: {
      const reqTruck = merge({}, state, {
        loading: true
      })
      return reqTruck
    }
    case adminConstants.GET_TRUCKING_SUCCESS: {
      const succTruck = merge({}, state, {
        trucking: action.payload.data,
        loading: false
      })
      return succTruck
    }
    case adminConstants.GET_TRUCKING_FAILURE: {
      const errTruck = merge({}, state, {
        error: { trucking: action.error },
        loading: false
      })
      return errTruck
    }

    case adminConstants.VIEW_TRUCKING_REQUEST: {
      return {
        ...state,
        loading: true
      }
    }
    case adminConstants.VIEW_TRUCKING_SUCCESS: {
      return {
        ...state,
        truckingDetail: action.payload,
        loading: false
      }
    }
    case adminConstants.VIEW_TRUCKING_FAILURE: {
      return {
        ...state,
        error: { trucking: action.error },
        loading: false
      }
    }

    case adminConstants.GET_VEHICLE_TYPES_REQUEST: {
      const reqVehicleTypes = merge({}, state, {
        loading: true
      })
      return reqVehicleTypes
    }
    case adminConstants.GET_VEHICLE_TYPES_SUCCESS: {
      const succVehicleTypes = merge({}, state, {
        vehicleTypes: action.payload.data,
        loading: false
      })
      return succVehicleTypes
    }
    case adminConstants.GET_VEHICLE_TYPES_FAILURE: {
      const errVehicleTypes = merge({}, state, {
        error: { vehicleTypes: action.error },
        loading: false
      })
      return errVehicleTypes
    }

    case adminConstants.GET_PRICINGS_REQUEST: {
      const reqPric = merge({}, state, {
        loading: true
      })
      return reqPric
    }
    case adminConstants.GET_PRICINGS_SUCCESS: {
      const succPric = merge({}, state, {
        pricingData: action.payload.data,
        loading: false
      })
      return succPric
    }
    case adminConstants.GET_PRICING_FAILURE: {
      const errPric = merge({}, state, {
        error: { pricings: action.error },
        loading: false
      })
      return errPric
    }

    case adminConstants.DELETE_PRICING_REQUEST: {
      return {
        ...state,
        loading: true
      }
    }
    case adminConstants.DELETE_PRICING_SUCCESS: {
      const { pricings } = state.pricingData
      // eslint-disable-next-line no-underscore-dangle
      delete pricings[action.payload._id]
      return {
        ...state,
        pricingData: {
          ...state.pricingData,
          pricings
        },
        loading: false
      }
    }
    case adminConstants.DELETE_PRICINGS_FAILURE: {
      return {
        ...state,
        error: { pricings: action.error },
        loading: false
      }
    }

    case adminConstants.UPDATE_PRICING_REQUEST:
      return state
    case adminConstants.UPDATE_PRICING_SUCCESS: {
      const exPricings = state.pricingData.pricings
      exPricings[action.payload.id] = action.payload
      return {
        ...state,
        pricingData: {
          ...state.pricingData,
          pricings: exPricings
        }
      }
    }
    case adminConstants.UPDATE_PRICING_FAILURE:
      return state

    case adminConstants.UPDATE_SERVICE_CHARGES_REQUEST:
      return state
    case adminConstants.UPDATE_SERVICE_CHARGES_SUCCESS: {
      const scs = state.serviceCharges
      const newScs = [action.payload]
      scs.forEach((sc) => {
        if (sc.id !== action.payload.id) {
          newScs.push(sc)
        }
      })
      const newState = merge({}, state, {
        serviceCharges: newScs,
        loading: false
      })
      return newState
    }
    case adminConstants.UPDATE_SERVICE_CHARGES_FAILURE:
      return state

    case adminConstants.GET_CLIENT_PRICINGS_REQUEST: {
      const reqClientPric = merge({}, state, {
        loading: true
      })
      return reqClientPric
    }
    case adminConstants.GET_CLIENT_PRICINGS_SUCCESS:
      return {
        ...state,
        clientPricings: action.payload.data,
        loading: false
      }
    case adminConstants.GET_CLIENT_PRICINGS_FAILURE: {
      const errClientPric = merge({}, state, {
        error: { pricings: action.error },
        loading: false
      })
      return errClientPric
    }

    case adminConstants.GET_ROUTE_PRICINGS_REQUEST: {
      const reqRoutePric = merge({}, state, {
        loading: true
      })
      return reqRoutePric
    }
    case adminConstants.GET_ROUTE_PRICINGS_SUCCESS:
      return {
        ...state,
        itineraryPricings: action.payload.data,
        loading: false
      }
    case adminConstants.GET_ROUTE_PRICINGS_FAILURE: {
      const errRoutePric = merge({}, state, {
        error: { pricings: action.error },
        loading: false
      })
      return errRoutePric
    }

    case adminConstants.GET_CLIENTS_REQUEST:
      return {
        ...state,
        loading: true
      }
    case adminConstants.GET_CLIENTS_SUCCESS:
      return {
        ...state,
        clients: action.payload.data.clients,
        managers: action.payload.data.managers,
        loading: false
      }
    case adminConstants.GET_CLIENTS_FAILURE: {
      const errClients = merge({}, state, {
        error: { clients: action.error },
        loading: false
      })
      return errClients
    }

    case adminConstants.NEW_CLIENT_REQUEST:
      return {
        ...state,
        loading: true
      }
    case adminConstants.NEW_CLIENT_SUCCESS: {
      const { clients } = state
      clients.push(action.payload)
      return {
        ...state,
        clients,
        loading: false
      }
    }
    case adminConstants.NEW_CLIENT_FAILURE:
      return {
        ...state,
        error: { client: action.error },
        loading: false
      }

    case adminConstants.NEW_ROUTE_REQUEST:
      return {
        ...state,
        loading: true
      }
    case adminConstants.NEW_ROUTE_SUCCESS: {
      const itineraries = state.itineraries.filter(x => x.id !== action.payload.id)
      itineraries.push(action.payload)
      return {
        ...state,
        itineraries,
        loading: false
      }
    }
    case adminConstants.NEW_ROUTE_FAILURE:
      return {
        ...state,
        error: { client: action.error },
        loading: false
      }

    case adminConstants.GET_CLIENT_REQUEST: {
      const reqClient = merge({}, state, {
        loading: true
      })
      return reqClient
    }
    case adminConstants.GET_CLIENT_SUCCESS: {
      // ;
      const succClient = merge({}, state, {
        client: action.payload.data,
        loading: false
      })
      return succClient
    }
    case adminConstants.GET_CLIENT_FAILURE: {
      const errClient = merge({}, state, {
        error: { client: action.error },
        loading: false
      })
      return errClient
    }

    case adminConstants.GET_SERVICE_CHARGES_REQUEST: {
      const reqSC = merge({}, state, {
        loading: true
      })
      return reqSC
    }
    case adminConstants.GET_SERVICE_CHARGES_SUCCESS: {
      const succSC = merge({}, state, {
        serviceCharges: action.payload.data,
        loading: false
      })
      return succSC
    }
    case adminConstants.GET_SERVICE_CHARGES_FAILURE: {
      const errSC = merge({}, state, {
        error: { serviceCharges: action.error },
        loading: false
      })
      return errSC
    }

    case adminConstants.GET_ROUTES_REQUEST: {
      const reqRoutes = merge({}, state, {
        loading: true
      })
      return reqRoutes
    }
    case adminConstants.GET_ROUTES_SUCCESS: {
      return {
        ...state,
        itineraries: action.payload.data,
        loading: false
      }
    }
    case adminConstants.GET_ROUTES_FAILURE: {
      const errRoutes = merge({}, state, {
        error: { routes: action.error },
        loading: false
      })
      return errRoutes
    }

    case adminConstants.GET_ROUTE_REQUEST: {
      const reqRoute = merge({}, state, {
        loading: true
      })
      return reqRoute
    }
    case adminConstants.GET_ROUTE_SUCCESS: {
      return {
        ...state,
        itinerary: action.payload.data,
        loading: false
      }
    }
    case adminConstants.GET_ROUTE_FAILURE: {
      const errRoute = merge({}, state, {
        error: { route: action.error },
        loading: false
      })
      return errRoute
    }

    case adminConstants.ACTIVATE_HUB_REQUEST: {
      const reqHubActivate = merge({}, state, {
        loading: true
      })
      return reqHubActivate
    }
    case adminConstants.ACTIVATE_HUB_SUCCESS:
      return {
        ...state,
        hub: {
          ...state.hub,
          hub: action.payload.data
        },
        loading: false
      }
    case adminConstants.ACTIVATE_HUB_FAILURE: {
      const errHubActivate = merge({}, state, {
        error: { hub: action.error },
        loading: false
      })
      return errHubActivate
    }

    case adminConstants.DOCUMENT_ACTION_REQUEST: {
      const reqDocAction = merge({}, state, {
        loading: true
      })
      return reqDocAction
    }
    case adminConstants.DOCUMENT_ACTION_SUCCESS: {
      const docs = state.shipment.documents.filter(x => x.id !== action.payload.id)
      docs.push(action.payload)
      return {
        ...state,
        shipment: {
          ...state.shipment,
          documents: docs
        },
        loading: false
      }
    }
    case adminConstants.DOCUMENT_ACTION_FAILURE: {
      const errDocAction = merge({}, state, {
        error: { documents: action.error },
        loading: false
      })
      return errDocAction
    }

    case adminConstants.NEW_HUB_REQUEST:
      return merge({}, state, {
        loading: true
      })
    case adminConstants.NEW_HUB_SUCCESS: {
      const newHubs = state.hubs
      newHubs.push(action.payload)
      return {
        ...state,
        loading: false,
        hubs: newHubs
      }
    }
    case adminConstants.NEW_HUB_FAILURE:
      return merge({}, state, {
        error: { hubs: action.error },
        loading: false
      })

    case adminConstants.EDIT_HUB_REQUEST:
      return merge({}, state, {
        loading: true
      })
    case adminConstants.EDIT_HUB_SUCCESS: {
      const newHubs = state.hubs.filter(x => x.id !== action.payload.hub.id)
      newHubs.push({ data: action.payload.hub, location: action.payload.location })
      return {
        ...state,
        loading: false,
        hubs: newHubs,
        hub: {
          ...state.hub,
          hub: action.payload.hub,
          location: action.payload.location
        }
      }
    }
    case adminConstants.EDIT_HUB_FAILURE:
      return merge({}, state, {
        error: { hubs: action.error },
        loading: false
      })

    case adminConstants.NEW_TRUCKING_REQUEST:
      return merge({}, state, {
        loading: true
      })
    case adminConstants.NEW_TRUCKING_SUCCESS:
      return {
        ...state,
        loading: false
      }
    case adminConstants.NEW_TRUCKING_FAILURE:
      return merge({}, state, {
        error: { trucking: action.error },
        loading: false
      })

    case adminConstants.ASSIGN_MANAGER_REQUEST:
      return merge({}, state, {
        loading: true
      })
    case adminConstants.ASSIGN_MANAGER_SUCCESS: {
      const newManagerArr = state.client.managerAssignments
      newManagerArr.push(action.payload)
      return {
        ...state,
        client: {
          ...state.client,
          manager_assignments: newManagerArr
        },
        loading: false
      }
    }
    case adminConstants.ASSIGN_MANAGER_FAILURE:
      return merge({}, state, {
        error: { trucking: action.error },
        loading: false
      })

    case adminConstants.VIEW_TRUCKING: {
      const newTrucking = merge({}, state, {
        truckingDetail: action.payload
      })
      return newTrucking
    }

    case adminConstants.GET_LAYOVERS_REQUEST:
      return state
    case adminConstants.GET_LAYOVERS_SUCCESS:
      if (action.payload.target === 'schedules') {
        return {
          ...state,
          schedules: {
            ...state.schedules,
            itineraryLayovers: {
              [action.payload.data[0].layover.trip_id]: action.payload.layovers
            }
          },
          loading: false
        }
      }
      return {
        ...state,
        itinerary: {
          ...state.itinerary,
          layovers: {
            [action.payload.layovers[0].layover.trip_id]: action.payload.layovers
          }
        },
        loading: false
      }

    case adminConstants.GET_LAYOVERS_FAILURE:
      return {
        ...state,
        error: { route: action.error },
        loading: false
      }
    case adminConstants.EDIT_SHIPMENT_PRICE_REQUEST:
      return state
    case adminConstants.EDIT_SHIPMENT_PRICE_SUCCESS:
      return {
        ...state,
        shipment: {
          ...state.shipment,
          shipment: action.payload
        },
        loading: false
      }
    case adminConstants.EDIT_SHIPMENT_PRICE_FAILURE:
      return {
        ...state,
        error: { route: action.error },
        loading: false
      }

    case adminConstants.SAVE_ITINERARY_NOTES_REQUEST:
      return state
    case adminConstants.SAVE_ITINERARY_NOTES_SUCCESS:
      return {
        ...state,
        itinerary: {
          ...state.itinerary,
          itinerary: action.payload
        },
        loading: false
      }
    case adminConstants.SAVE_ITINERARY_NOTES_FAILURE:
      return {
        ...state,
        error: { route: action.error },
        loading: false
      }

    case adminConstants.EDIT_SHIPMENT_TIME_REQUEST:
      return state
    case adminConstants.EDIT_SHIPMENT_TIME_SUCCESS:
      return {
        ...state,
        shipment: {
          ...state.shipment,
          shipment: action.payload
        },
        loading: false
      }
    case adminConstants.EDIT_SHIPMENT_TIME_FAILURE:
      return {
        ...state,
        error: { route: action.error },
        loading: false
      }
    case adminConstants.EDIT_LOCAL_CHARGES_REQUEST:
      return state
    case adminConstants.EDIT_LOCAL_CHARGES_SUCCESS: {
      const newCharges = state.hub.charges.filter(c => c.id !== action.payload.id)
      newCharges.push(action.payload)
      return {
        ...state,
        hub: {
          ...state.hub,
          charges: newCharges
        },
        loading: false
      }
    }
    case adminConstants.EDIT_LOCAL_CHARGES_FAILURE:
      return {
        ...state,
        error: { hub: action.error },
        loading: false
      }

    case adminConstants.EDIT_CUSTOMS_FEES_REQUEST:
      return state
    case adminConstants.EDIT_CUSTOMS_FEES_SUCCESS: {
      const newCustoms = state.hub.customs.filter(c => c.id !== action.payload.id)
      newCustoms.push(action.payload)
      return {
        ...state,
        hub: {
          ...state.hub,
          customs: newCustoms
        },
        loading: false
      }
    }
    case adminConstants.EDIT_CUSTOMS_FEES_FAILURE:
      return {
        ...state,
        error: { hub: action.error },
        loading: false
      }

    case adminConstants.UPLOAD_TRUCKING_REQUEST:
      return state
    case adminConstants.UPLOAD_TRUCKING_SUCCESS:
      return {
        ...state,
        trucking: action.payload,
        loading: false
      }
    case adminConstants.UPLOAD_TRUCKING_FAILURE:
      return {
        ...state,
        error: { hub: action.error },
        loading: false
      }
    case adminConstants.UPLOAD_HUB_IMAGE_REQUEST:
      return state
    // eslint-disable-next-line no-case-declarations
    case adminConstants.UPLOAD_HUB_IMAGE_SUCCESS:
      const hubsArr = state.hubs.filter(h => h.id !== action.payload.id)
      hubsArr.push(action.payload)
      return {
        ...state,
        hub: {
          ...this.state.hub,
          hub: action.payload
        },
        hubs: hubsArr,
        loading: false
      }
    case adminConstants.UPLOAD_HUB_IMAGE_FAILURE:
      return {
        ...state,
        error: { hub: action.error },
        loading: false
      }

    case adminConstants.LOAD_ITINERARY_SCHEDULES_REQUEST:
      return state
    case adminConstants.LOAD_ITINERARY_SCHEDULES_SUCCESS:
      return {
        ...state,
        itinerarySchedules: action.payload,
        loading: false
      }
    case adminConstants.LOAD_ITINERARY_SCHEDULES_FAILURE:
      return {
        ...state,
        error: { hub: action.error },
        loading: false
      }

    case adminConstants.DELETE_CLIENT_REQUEST:
      return state
    case adminConstants.DELETE_CLIENT_SUCCESS: {
      const clients = state.clients.filter(client => client.id !== action.payload)
      return {
        ...state,
        clients,
        loading: false
      }
    }
    case adminConstants.DELETE_CLIENT_FAILURE:
      return {
        ...state,
        error: { clients: action.error },
        loading: false
      }

    case adminConstants.DELETE_TRIP_REQUEST:
      return state
    case adminConstants.DELETE_TRIP_SUCCESS:
      return {
        ...state,
        itinerarySchedules: {
          ...state.itinerarySchedules,
          schedules: state.itinerarySchedules.schedules.filter(x => x.id !== action.payload)
        },
        loading: false
      }
    case adminConstants.DELETE_TRIP_FAILURE:
      return {
        ...state,
        error: { hub: action.error },
        loading: false
      }
    case adminConstants.UPDATE_MANDATORY_CHARGE_REQUEST:
      return state
    case adminConstants.UPDATE_MANDATORY_CHARGE_SUCCESS:
      return {
        ...state,
        hub: {
          ...state.hub,
          hub: action.payload.hub,
          mandatoryCharge: action.payload.mandatoryCharge
        },
        loading: false
      }
    case adminConstants.UPDATE_MANDATORY_CHARGE_FAILURE:
      return {
        ...state,
        error: { hub: action.error },
        loading: false
      }
    case adminConstants.CLEAR_LOADING:
      return {
        ...state,
        loading: false
      }
    case adminConstants.ADMIN_LOG_OUT:
      return {}
    default:
      return state
  }
}
