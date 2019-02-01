import i18next from 'i18next'
import { get } from 'lodash'
import { shipmentConstants } from '../constants'

export default function shipment (state = {}, action) {
  let error

  switch (action.type) {
    case shipmentConstants.CLEAR_LOADING:
      return {
        ...state,
        loading: false
      }
    case shipmentConstants.REUSE_SHIPMENT_REQUEST:
      return {
        reusedShipment: action.payload,
        loading: true,
        currentStage: 'stage1'
      }
    case shipmentConstants.NEW_SHIPMENT_REQUEST: {
      const newState = {
        ...state,
        request: {
          stage1: action.shipmentData
        },
        loading: true,
        currentStage: 'stage1',
        error: {}
      }
      if (!action.isReused) {
        newState.reusedShipment = false
      }

      return newState
    }
    case shipmentConstants.NEW_SHIPMENT_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage1: action.shipmentData
        },
        currentStage: 'stage2',
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
    case shipmentConstants.SET_ERROR:
      return {
        ...state,
        error: {
          ...state.error,
          [action.payload.stage]: action.payload.errors
        }
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

    case shipmentConstants.GET_OFFERS_REQUEST: {
      const originalSelectedDay = action.shipmentData.shipment.selected_day

      return {
        ...state,
        request: {
          ...state.request,
          stage2: action.shipmentData
        },
        originalSelectedDay,
        loading: true
      }
    }
    case shipmentConstants.GET_OFFERS_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage2: action.shipmentData
        },
        loading: false,
        currentStage: 'stage3',
        activeShipment: action.shipmentData.shipment.id
      }
    case shipmentConstants.GET_OFFERS_FAILURE:
      return {
        ...state,
        // error: {
        //   ...state.error,
        //   stage2: [action.error]
        // },
        loading: false
      }
    case shipmentConstants.SHIPMENT_GET_SCHEDULES_REQUEST: {
      return state
    }
    case shipmentConstants.SHIPMENT_GET_SCHEDULES_SUCCESS: {
      const { results } = state.response.stage2
      const targetResult = results.filter(r => (r.meta.itinerary_id === action.payload.itinerary_id) &&
        (r.meta.tenant_vehicle_id === action.payload.tenant_vehicle_id))[0]
      const targetIndex = results.indexOf(targetResult)
      results[targetIndex].schedules = action.payload.schedules
      results[targetIndex].finalResults = action.payload.finalResults

      return {
        ...state,
        response: {
          ...state.response,
          stage2: {
            ...state.response.stage2,
            results
          }
        }
      }
    }
    case shipmentConstants.SHIPMENT_GET_SCHEDULES_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage2: [action.error]
        },
        loading: false
      }
    case shipmentConstants.GET_NEW_DATE_OFFERS_REQUEST: {
      const originalSelectedDay = state.originalSelectedDay ||
        state.request.stage2.shipment.selected_day

      return {
        ...state,
        request: {
          ...state.request,
          stage2: action.shipmentData
        },
        originalSelectedDay,
        loading: true
      }
    }
    case shipmentConstants.GET_NEW_DATE_OFFERS_SUCCESS: {
      const shipmentToEdit = action.shipmentData.shipment
      const { schedules } = state.response.stage2
      action.shipmentData.schedules.forEach((sched) => {
        if (schedules.filter(sched2 => sched2.trip_id === sched.trip_id).length < 1) {
          schedules.push(sched)
        }
      })
      const adjustedShipmentData = {
        ...action.shipmentData,
        shipment: shipmentToEdit,
        schedules
      }

      return {
        ...state,
        response: {
          ...state.response,
          stage2: adjustedShipmentData
        },
        loading: false,
        activeShipment: action.shipmentData.shipment.id
      }
    }
    case shipmentConstants.GET_NEW_DATE_OFFERS_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage2: [action.error]
        },
        loading: false
      }
    case shipmentConstants.CHOOSE_OFFER_REQUEST:

      return {
        ...state,
        request: {
          ...state.request,
          stage3: action.shipmentData
        },
        loading: true
      }
    case shipmentConstants.CHOOSE_OFFER_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage3: action.shipmentData
        },
        currentStage: 'stage4',
        loading: false,
        activeShipment: action.shipmentData.shipment.id
      }
    case shipmentConstants.CHOOSE_OFFER_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage3: [action.error]
        },
        loading: false
      }
    case shipmentConstants.SEND_QUOTES_REQUEST:

      return {
        ...state,
        modal: false,
        request: {
          ...state.request,
          stage3: action.shipmentData
        },
        loading: true
      }
    case shipmentConstants.SEND_QUOTES_SUCCESS:
      return {
        ...state,
        modal: true,
        response: {
          ...state.response,
          stage3: action.shipmentData
        },
        currentStage: 'stage4',
        loading: false
      }
    case shipmentConstants.SEND_QUOTES_FAILURE:
      return {
        ...state,
        modal: false,
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
        currentStage: 'stage5',
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

    case shipmentConstants.REQUEST_SHIPMENT_REQUEST:
      return {
        ...state,
        request: {
          ...state.request,
          stage5: action.shipmentData
        },
        loading: true
      }
    case shipmentConstants.REQUEST_SHIPMENT_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage5: action.shipmentData
        },
        reusedShipment: false,
        loading: false,
        currentStage: 'stage6',
        activeShipment: action.shipmentData.shipment.id
      }
    case shipmentConstants.REQUEST_SHIPMENT_FAILURE:
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
      const stage3Documents = get(state, ['response', 'stage3', 'documents'], {})
      const stage4Documents = get(state, ['response', 'stage4', 'documents'], {})
      const docType = action.payload.doc_type
      const docArray = [stage3Documents, stage4Documents]
      docArray.forEach((documents) => {
        if (documents[docType]) {
          documents[docType].push(action.payload)
        } else {
          documents[docType] = [action.payload]
        }
      })

      return {
        ...state,
        response: {
          ...state.response,
          stage3: {
            ...state.response.stage3,
            documents: stage3Documents
          },
          stage4: {
            ...state.response.stage4,
            documents: stage4Documents
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
      
      const stage4Docs = get(state, ['response', 'stage4', 'documents'], {})
      const stage3Docs = get(state, ['response', 'stage3', 'documents'], {})
      const docArray = [stage3Docs, stage4Docs]
      const newDocArray = docArray.map((documents) => {
        const newDocuments = {}
        Object.keys(documents).forEach((key) => {
          newDocuments[key] = documents[key].filter(d => d.id !== action.payload)
        })
        return newDocuments
      })

      return {
        ...state,
        response: {
          ...state.response,
          stage3: {
            ...state.response.stage3,
            documents: newDocArray[0]
          },
          stage4: {
            ...state.response.stage4,
            documents: newDocArray[1]
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
    case shipmentConstants.CLEAR_SHIPMENTS:
      return {}

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
    case shipmentConstants.SHIPMENT_GET_NOTES_REQUEST:
      return state
    case shipmentConstants.SHIPMENT_GET_NOTES_SUCCESS:
      return {
        ...state,
        response: {
          ...state.response,
          stage1: {
            ...state.response.stage1,
            notes: action.payload
          }
        }
      }
    case shipmentConstants.SHIPMENT_GET_NOTES_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage1: [action.error]
        }
      }

    case shipmentConstants.SHIPMENT_GET_LAST_AVAILABLE_DATE_REQUEST: {
      error = { ...state.error }
      if (get(error, 'stage2', []).length > 0) {
        error.stage2 = error.stage2.filter(errorObj => (
          errorObj.id !== 'NO_SCHEDULES_FOR_ROUTE'
        ))
      }

      return {
        ...state,
        error
      }
    }
    case shipmentConstants.SHIPMENT_GET_LAST_AVAILABLE_DATE_SUCCESS: {
      error = { ...state.error }
      if (action.payload == null) {
        error.stage2 = [{
          type: 'error',
          text: i18next.t('errors:noSchedulesForRoute'),
          id: 'NO_SCHEDULES_FOR_ROUTE'
        }]
      }

      return {
        ...state,
        response: {
          ...state.response,
          stage1: {
            ...state.response.stage1,
            lastAvailableDate: action.payload
          }
        },
        error
      }
    }
    case shipmentConstants.SHIPMENT_GET_LAST_AVAILABLE_DATE_FAILURE:
      return {
        ...state,
        error: {
          ...state.error,
          stage2: [action.error]
        }
      }
    case shipmentConstants.SHIPMENT_UPDATE_CONTACT_REQUEST:
      return state
    case shipmentConstants.SHIPMENT_UPDATE_CONTACT_SUCCESS: {
      const contactData = action.payload

      const { contacts } = state
      const idx = contacts.findIndex(contact => contact.contact.id === contactData.id)
      contacts[idx] = {
        contact: {
          firstName: contactData.first_name,
          lastName: contactData.last_name,
          companyName: contactData.company_name,
          userId: contactData.user_id,
          id: contactData.id,
          email: contactData.email,
          phone: contactData.phone,
          addressId: contactData.address_id
        },
        address: {
          country: contactData.address.country.name,
          city: contactData.address.city,
          zipCode: contactData.address.zip_code,
          street: contactData.address.street,
          streetNumber: contactData.address.street_number,
          geocodedAddress: contactData.address.geocoded_address
        }
      }

      return {
        ...state,
        contacts
      }
    }
    case shipmentConstants.SHIPMENT_UPDATE_CONTACT_FAILURE:
      return {
        ...state,
        loading: false,
        error: { hubs: action.error }
      }
    case '@@router/LOCATION_CHANGE': {
      return {
        ...state,
        error: null
      }
    }
    default:
      return state
  }
}
