import { shipmentConstants } from '../constants'

export default function shipment (state = {}, action) {
  switch (action.type) {
    case shipmentConstants.CLEAR_LOADING:
      return {
        ...state,
        loading: false
      }
    case shipmentConstants.NEW_SHIPMENT_REQUEST:
      return {
        request: {
          stage1: action.shipmentData
        },
        loading: true
      }
    case shipmentConstants.NEW_SHIPMENT_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage1: action.shipmentData
        },
        activeShipment: action.shipmentData.shipment.id,
        loading: false
      }
    case shipmentConstants.NEW_SHIPMENT_FAILURE:
      return {
        ...state,
        error: {
          ...state.errors,
          stage1: [action.error]
        },
        loading: false
      }

    case shipmentConstants.GET_SHIPMENT_REQUEST:
      return {
        ...state,
        loading: true
      }
    case shipmentConstants.GET_SHIPMENT_SUCCESS:
      return action.shipmentData
    case shipmentConstants.GET_SHIPMENT_FAILURE:
      return {
        ...state,
        error: {
          ...state.errors,
          get: [action.error]
        },
        loading: false
      }

    case shipmentConstants.SET_SHIPMENT_DETAILS_REQUEST:
      return {
        ...state,
        request: {
          ...state.request,
          stage2: action.shipmentData
        },
        loading: true
      }
    case shipmentConstants.SET_SHIPMENT_DETAILS_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage2: action.shipmentData
        },
        loading: false,
        activeShipment: action.shipmentData.shipment.id
      }
    case shipmentConstants.SET_SHIPMENT_DETAILS_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage2: [action.error]
        },
        loading: false
      }
    case shipmentConstants.SET_SHIPMENT_ROUTE_REQUEST:
      return {
        ...state,
        request: {
          ...state.request,
          stage3: action.shipmentData
        },
        loading: true
      }
    case shipmentConstants.SET_SHIPMENT_ROUTE_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage3: action.shipmentData
        },
        loading: false,
        activeShipment: action.shipmentData.shipment.id
      }
    case shipmentConstants.SET_SHIPMENT_ROUTE_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage3: [action.error]
        },
        loading: false
      }
    case shipmentConstants.SET_SHIPMENT_CONTACTS_REQUEST:
      return {
        ...state,
        request: {
          ...state.request,
          stage4: action.shipmentData
        },
        loading: true
      }
    case shipmentConstants.SET_SHIPMENT_CONTACTS_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage4: action.shipmentData
        },
        loading: false,
        activeShipment: action.shipmentData.shipment.id
      }
    case shipmentConstants.SET_SHIPMENT_CONTACTS_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage3: [action.error]
        },
        loading: false
      }

    case shipmentConstants.ACCEPT_SHIPMENT_REQUEST:
      return {
        ...state,
        request: {
          ...state.request,
          stage5: action.shipmentData
        },
        loading: true
      }
    case shipmentConstants.ACCEPT_SHIPMENT_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage5: action.shipmentData
        },
        loading: false,
        activeShipment: action.shipmentData.shipment.id
      }
    case shipmentConstants.ACCEPT_SHIPMENT_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage3: [action.error]
        },
        loading: false
      }

    case shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_REQUEST:
      return state
    case shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_SUCCESS: {
      const docs = state.response.stage3.documents
      docs[action.payload.doc_type] = action.payload
      return {
        ...state,
        response: {
          stage3: {
            documents: docs
          }
        },
        loading: false
      }
    }
    case shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          hubs: action.error
        }
      }

    case shipmentConstants.SHIPMENT_DELETE_DOCUMENT_REQUEST:
      return state
    case shipmentConstants.SHIPMENT_DELETE_DOCUMENT_SUCCESS: {
      const docObj = {}
      Object.keys(state.response.stage3.documents).forEach((key) => {
        if (state.response.stage3.documents[key].id !== action.payload) {
          docObj[key] = state.response.stage3.documents[key]
        }
      })
      return {
        ...state,
        response: {
          ...state.response,
          stage3: {
            ...state.response.stage3,
            documents: docObj
          }
        },
        loading: false
      }
    }
    case shipmentConstants.SHIPMENT_DELETE_DOCUMENT_FAILURE:
      return {
        ...state,
        error: { hubs: action.error }
      }

    case shipmentConstants.DELETE_REQUEST:
      // add 'deleting:true' property to user being deleted
      return {
        ...state,
        items: state.items.map(user => (user.id === action.id ? { ...user, deleting: true } : user))
      }
    case shipmentConstants.DELETE_SUCCESS:
      // remove deleted user from state
      return {
        items: state.items.filter(user => user.id !== action.id)
      }
    case shipmentConstants.DELETE_FAILURE:
      // remove 'deleting:true' property and add 'deleteError:[error]' property to user
      return {
        ...state,
        items: state.items.map((user) => {
          if (user.id === action.id) {
            // make copy of user without 'deleting:true' property
            const { deleting, ...userCopy } = user
            console.log(deleting)
            // return copy of user with 'deleteError:[error]' property
            return { ...userCopy, deleteError: [action.error] }
          }

          return user
        })
      }
    default:
      return state
  }
}
