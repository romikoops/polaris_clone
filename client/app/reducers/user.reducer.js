import merge from 'lodash/merge'
import { userConstants } from '../constants'
import getSubdomain from '../helpers/subdomain'

const { localStorage } = window

const subdomainKey = getSubdomain()
const cookieKey = `${subdomainKey}_user`
const userCookie = localStorage.getItem(cookieKey)
const userData = (typeof (userCookie) !== 'undefined') && userCookie !== 'undefined' ? JSON.parse(userCookie) : {}

const initialState = userData ? { loggedIn: true, userData } : {}

export default function users (state = initialState, action) {
  switch (action.type) {
    case userConstants.GETALL_REQUEST:
      return {
        loading: true
      }
    case userConstants.GETALL_SUCCESS:
      return {
        loading: false,
        items: action.payload
      }
    case userConstants.GETALL_FAILURE:
      return {
        loading: false,
        error: action.error
      }
    case userConstants.DELETE_REQUEST:
      // add 'deleting:true' property to user being deleted
      return {
        ...state,
        loading: false,
        items: state.items.map(newUserData =>
          (newUserData.id === action.id ? { ...newUserData, deleting: true } : newUserData))
      }
    case userConstants.DELETE_SUCCESS:
      // remove deleted user from state
      return {
        items: state.items.filter(newUserData => newUserData.id !== action.id)
      }
    case userConstants.DELETE_FAILURE:
      // remove 'deleting:true' property and add 'deleteError:[error]' property to user
      return {
        ...state,
        loading: false,
        items: state.items.map((newUserData) => {
          if (newUserData.id === action.id) {
            // make copy of user without 'deleting:true' property
            const { deleting, ...userCopy } = newUserData

            // return copy of user with 'deleteError:[error]' property
            return { ...userCopy, deleteError: action.error }
          }

          return newUserData
        })
      }
    case userConstants.GETLOCATIONS_REQUEST:
      return {
        ...state,
        loading: true
      }
    case userConstants.GETLOCATIONS_SUCCESS:
      return {
        items: action.payload
      }
    case userConstants.GETLOCATIONS_FAILURE:
      return {
        ...state,
        loading: false,
        error: action.error
      }
    case userConstants.DESTROYADDRESS_REQUEST:
      return {
        ...state,
        loading: true
      }
    case userConstants.DESTROYADDRESS_SUCCESS:
      return {
        ...state,
        dashboard: {
          ...state.dashboard,
          addresses: state.dashboard.addresses
            .filter(item => item.address.id !== parseInt(action.payload.id, 10))
        },
        loading: false
      }
    case userConstants.DESTROYADDRESS_FAILURE:
      return {
        ...state,
        loading: false,
        error: action.error
      }
    case userConstants.MAKEPRIMARY_REQUEST:
      return {
        ...state,
        loading: true
      }
    case userConstants.MAKEPRIMARY_SUCCESS:
      return {
        ...state,
        loading: false,
        dashboard: {
          ...state.dashboard,
          addresses: action.payload
        }
      }
    case userConstants.MAKEPRIMARY_FAILURE:
      return {
        loading: false,
        error: action.error
      }

    case userConstants.NEW_USER_LOCATION_REQUEST:
      return {
        ...state,
        loading: true
      }
    case userConstants.NEW_USER_LOCATION_SUCCESS:
      return {
        ...state,
        loading: false,
        dashboard: {
          ...state.dashboard,
          addresses: action.payload
        }
      }
    case userConstants.NEW_USER_LOCATION_FAILURE:
      return {
        loading: false,
        error: action.error
      }

    case userConstants.EDIT_USER_LOCATION_REQUEST:
      return {
        ...state,
        loading: true
      }
    case userConstants.EDIT_USER_LOCATION_SUCCESS:
      return {
        ...state,
        loading: false,
        dashboard: {
          ...state.dashboard,
          addresses: action.payload
        }
      }
    case userConstants.EDIT_USER_LOCATION_FAILURE:
      return {
        loading: false,
        error: action.error
      }

    case userConstants.GET_SHIPMENTS_REQUEST: {
      const reqShips = merge({}, state, {
        getShipmentsRequest: true,
        loading: false
      })

      return reqShips
    }
    case userConstants.GET_SHIPMENTS_SUCCESS: {
      return {
        ...state,
        getShipmentsRequest: false,
        shipments: action.payload.data,
        loading: false
      }
    }
    case userConstants.GET_SHIPMENTS_FAILURE: {
      const errShips = merge({}, state, {
        getShipmentsRequest: false,
        loading: false,
        error: { shipments: action.error }
      })

      return errShips
    }
    case userConstants.GET_HUBS_REQUEST: {
      const reqHubs = merge({}, state, {
        loading: true
      })

      return reqHubs
    }
    case userConstants.GET_HUBS_SUCCESS: {
      const succHubs = merge({}, state, {
        hubs: action.payload.data,
        loading: false
      })

      return succHubs
    }
    case userConstants.GET_HUBS_FAILURE: {
      const errHubs = merge({}, state, {
        loading: false,
        error: { hubs: action.error }
      })

      return errHubs
    }

    case userConstants.USER_GET_SHIPMENT_REQUEST: {
      const reqShip = merge({}, state, {
        loading: true
      })

      return reqShip
    }
    case userConstants.USER_GET_SHIPMENT_SUCCESS: {
      return {
        ...state,
        shipment: action.payload.data,
        loading: false
      }
    }
    case userConstants.USER_GET_SHIPMENT_FAILURE: {
      const errShip = merge({}, state, {
        loading: false,
        error: { shipments: action.error }
      })

      return errShip
    }

    case userConstants.GET_DASHBOARD_REQUEST: {
      const reqDash = merge({}, state, {
        loading: true
      })

      return reqDash
    }
    case userConstants.GET_DASHBOARD_SUCCESS: {
      return {
        ...state,
        dashboard: action.payload.data,
        loading: false
      }
    }
    case userConstants.GET_DASHBOARD_FAILURE: {
      const errDash = merge({}, state, {
        loading: false,
        error: { hubs: action.error }
      })

      return errDash
    }

    case userConstants.GET_CONTACT_REQUEST: {
      const reqContact = merge({}, state, {
        loading: true
      })

      return reqContact
    }
    case userConstants.GET_CONTACT_SUCCESS: {
      return {
        ...state,
        contactData: action.payload.data,
        loading: false
      }
    }
    case userConstants.GET_CONTACT_FAILURE: {
      const errContact = merge({}, state, {
        loading: false,
        error: { contact: action.error }
      })

      return errContact
    }

    case userConstants.GET_CONTACTS_REQUEST: {
      // const reqContact = merge({}, state, {
      //   loading: true
      // })

      return state
    }
    case userConstants.GET_CONTACTS_SUCCESS: {
      return {
        ...state,
        contactsData: action.payload.data,
        num_contact_pages: state.dashboard.num_contact_pages,
        loading: false
      }
    }
    case userConstants.GET_CONTACTS_FAILURE: {
      const errContact = merge({}, state, {
        loading: false,
        error: { contact: action.error }
      })

      return errContact
    }

    case userConstants.NEW_CONTACT_REQUEST: {
      return {
        ...state,
        loading: true
      }
    }
    case userConstants.NEW_CONTACT_SUCCESS: {
      return {
        ...state,
        loading: false
      }
    }
    case userConstants.NEW_CONTACT_FAILURE: {
      const errNewContact = merge({}, state, {
        loading: false,
        error: { contactData: action.error }
      })

      return errNewContact
    }

    case userConstants.NEW_ALIAS_REQUEST: {
      const reqNewAlias = merge({}, state, {
        loading: true
      })

      return reqNewAlias
    }
    case userConstants.NEW_ALIAS_SUCCESS: {
      const { aliases } = state.dashboard
      aliases.push(action.payload.data)

      return {
        ...state,
        contactData: aliases,
        loading: false
      }
    }
    case userConstants.NEW_ALIAS_FAILURE: {
      const errNewAlias = merge({}, state, {
        loading: false,
        error: { contactData: action.error }
      })

      return errNewAlias
    }

    case userConstants.DELETE_ALIAS_REQUEST: {
      const reqDeleteAlias = merge({}, state, {
        loading: true
      })

      return reqDeleteAlias
    }
    case userConstants.DELETE_ALIAS_SUCCESS: {
      const aliasless = state.dashboard.aliases
        .filter(x => x.id !== parseInt(action.payload.data, 10))

      return {
        ...state,
        dashboard: {
          ...state.dashboard,
          aliases: aliasless
        },
        loading: false
      }
    }
    case userConstants.DELETE_ALIAS_FAILURE: {
      const errDeleteAlias = merge({}, state, {
        loading: false,
        error: { contactData: action.error }
      })

      return errDeleteAlias
    }

    case userConstants.UPLOAD_DOCUMENT_REQUEST: {
      const reqDocUpload = merge({}, state, {})

      return reqDocUpload
    }
    case userConstants.UPLOAD_DOCUMENT_SUCCESS: {
      const docs = state.shipment.documents
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
    case userConstants.UPLOAD_DOCUMENT_FAILURE: {
      const errDocUpload = merge({}, state, {
        loading: false,
        error: { hubs: action.error }
      })

      return errDocUpload
    }

    case userConstants.DELETE_DOCUMENT_REQUEST: {
      const reqDocDelete = merge({}, state, {})

      return reqDocDelete
    }
    case userConstants.DELETE_DOCUMENT_SUCCESS: {
      return {
        ...state,
        shipment: {
          ...state.shipment,
          documents: state.shipment.documents.filter(item => item.id !== action.payload)
        },
        loading: false
      }
    }
    case userConstants.DELETE_DOCUMENT_FAILURE: {
      const errDocDelete = merge({}, state, {
        loading: false,
        error: { hubs: action.error }
      })

      return errDocDelete
    }

    case userConstants.UPDATE_CONTACT_ADDRESS_REQUEST:
      return { ...state, loading: true }
    case userConstants.UPDATE_CONTACT_ADDRESS_SUCCESS: {
      const cLData = state.contactData
      cLData.address = action.payload

      return {
        ...state,
        contactData: cLData,
        loading: false
      }
    }
    case userConstants.UPDATE_CONTACT_ADDRESS_FAILURE:
      return {
        ...state,
        loading: false,
        error: { hubs: action.error }
      }

    case userConstants.DELETE_CONTACT_ADDRESS_REQUEST:
      return { ...state, loading: true }
    case userConstants.DELETE_CONTACT_ADDRESS_SUCCESS: {
      const caData = state.contactData
      caData.address = false

      return {
        ...state,
        contactData: caData,
        loading: false
      }
    }
    case userConstants.DELETE_CONTACT_ADDRESS_FAILURE:
      return {
        ...state,
        loading: false,
        error: { hubs: action.error }
      }

    case userConstants.UPDATE_CONTACT_REQUEST:
      return { ...state, loading: true }
    case userConstants.UPDATE_CONTACT_SUCCESS: {
      const cData = state.contactData
      cData.contact = action.payload

      return {
        ...state,
        contactData: cData,
        loading: false
      }
    }
    case userConstants.UPDATE_CONTACT_FAILURE:
      return {
        ...state,
        loading: false,
        error: { hubs: action.error }
      }

    case userConstants.GET_SHIPMENTS_PAGE_REQUEST: {
      return state
    }
    case userConstants.GET_SHIPMENTS_PAGE_SUCCESS:
      return {
        ...state,
        dashboard: {
          ...state.dashboard,
          shipments: {
            ...state.dashboard.shipments,
            [action.payload.data.target]: action.payload.data.shipments
          }
        },
        shipments: {
          ...state.shipments,
          [action.payload.data.target]: action.payload.data.shipments,
          num_shipment_pages: {
            ...state.shipments.num_shipment_pages,
            [action.payload.data.target]: action.payload.data.num_shipment_pages, // eslint-disable-line
          },
          pages: {
            ...state.shipments.pages,
            [action.payload.data.target]: action.payload.data.page
          }
        },
        loading: false
      }
    case userConstants.GET_SHIPMENTS_PAGE_FAILURE: {
      const errShips = merge({}, state, {
        error: { shipments: action.error },
        loading: false
      })

      return errShips
    }

    case userConstants.GET_PRICINGS_REQUEST:
      return { ...state, loading: true }
    case userConstants.GET_PRICINGS_SUCCESS: {
      return {
        ...state,
        pricings: {
          ...state.pricings,
          index: action.payload
        },
        loading: false
      }
    }
    case userConstants.GET_PRICINGS_FAILURE:
      return {
        ...state,
        loading: false,
        error: { pricings: action.error }
      }
    case userConstants.GET_ITINERARY_PRICINGS_REQUEST:
      return { ...state, loading: true }
    case userConstants.GET_ITINERARY_PRICINGS_SUCCESS: {
      return {
        ...state,
        pricings: {
          ...state.pricings,
          show: {
            ...state.pricings.show,
            [action.payload.itinerary_id]: action.payload
          }
        },
        loading: false
      }
    }
    case userConstants.GET_ITINERARY_PRICINGS_FAILURE:
      return {
        ...state,
        loading: false,
        error: { pricings: action.error }
      }
    case userConstants.SEND_DEDICATED_PRICINGS_REQUEST:
      return { ...state, loading: true }
    case userConstants.SEND_DEDICATED_PRICINGS_SUCCESS: {
      return {
        ...state,
        pricings: {
          ...state.pricings,
          show: {
            ...state.pricings.show,
            [action.payload.itinerary_id]: action.payload
          }
        },
        loading: false
      }
    }
    case userConstants.SEND_DEDICATED_PRICINGS_FAILURE:
      return {
        ...state,
        loading: false,
        error: { pricings: action.error }
      }

    case userConstants.CLEAR_LOADING:
      return {
        ...state,
        loading: false
      }
    case userConstants.CONFIRM_ACCOUNT_REQUEST:
      return {
        ...state,
        confirmed: false
      }
    case userConstants.CONFIRM_ACCOUNT_SUCCESS:
      return {
        ...state,
        confirmed: true
      }
    case userConstants.CONFIRM_ACCOUNT_FAILURE:
      return {
        ...state,
        confirmed: false
      }
    case userConstants.USER_LOG_OUT:
      return {}

    default:
      return state
  }
}
