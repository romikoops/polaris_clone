import { get } from 'lodash'

export default function clients (state = {}, action) {
  switch (action.type) {
    case 'CLIENT_LOG_OUT': {
      return {}
    }
    case 'GET_CLIENTS_LIST_SUCCESS': {
      return {
        ...state,
        users: action.payload
      }
    }
    case 'GET_COMPANIES_LIST_SUCCESS': {
      return {
        ...state,
        companies: action.payload
      }
    }
    case 'GET_MARGINS_LIST_SUCCESS': {
      return {
        ...state,
        margins: action.payload
      }
    }
    case 'CLEAR_MARGINS_LIST': {
      return {
        ...state,
        margins: {}
      }
    }
    case 'GET_LOCAL_CHARGES_LIST_SUCCESS': {
      return {
        ...state,
        localCharges: action.payload
      }
    }
    case 'REMOVE_LOCAL_CHARGE': {
      const localCharges = state.localCharges.localChargeData.filter(lc => lc.id !== action.payload)

      return {
        ...state,
        localCharges
      }
    }
    case 'REMOVE_CLIENT_DATA': {
      const newState = { ...state }
      delete newState.client
      
      return newState
    }
    case 'GET_GROUPS_LIST_SUCCESS': {
      return {
        ...state,
        groups: action.payload
      }
    }
    case 'VIEW_GROUP_SUCCESS': {
      return {
        ...state,
        group: action.payload
      }
    }
    case 'VIEW_CLIENT_SUCCESS': {
      return {
        ...state,
        client: action.payload
      }
    }
    case 'VIEW_COMPANY_SUCCESS': {
      return {
        ...state,
        company: action.payload
      }
    }
    case 'EDIT_GROUP_MEMBERSHIP_SUCCESS': {
      return {
        ...state,
        group: action.payload
      }
    }
    case 'GET_MARGIN_FORM_DATA_SUCCESS': {
      return {
        ...state,
        marginFormData: action.payload
      }
    }
    case 'GET_MARGIN_FEE_DATA_REQUEST': {
      return {
        ...state,
        marginFormData: {
          targetGroupId: get(state, ['marginFormData', 'targetGroupId'], false)
        }
      }
    }
    case 'GET_MARGIN_FEE_DATA_SUCCESS': {
      return {
        ...state,
        marginFormData: {
          ...state.marginFormData,
          fineFeeData: action.payload
        }
      }
    }
    case 'GET_GROUPS_AND_MARGINS_SUCCESS': {
      return {
        ...state,
        groupsAndMargins: action.payload
      }
    }
    case 'NEW_MARGIN_FROM_GROUP': {
      return {
        ...state,
        marginFormData: {
          ...state.marginFormData,
          targetGroupId: action.payload
        }
      }
    }
    case 'MEMBERSHIP_DATA_SUCCESS': {
      return {
        ...state,
        groups: {
          ...state.groups,
          memberships: action.payload
        }
      }
    }
    case 'TEST_MARGINS_REQUEST': {
      return {
        ...state,
        loading: true
      }
    }
    case 'TEST_MARGINS_SUCCESS': {
      return {
        ...state,
        marginPreview: action.payload,
        loading: false
      }
    }
    case 'FETCH_SCOPE_SUCCESS': {
      return {
        ...state,
        scopes: action.payload
      }
    }
    case 'CLEAR_MARGIN_PREVIEW': {
      const newState = { ...state }
      delete newState.marginPreview

      return newState
    }
    default:
      return state
  }
}
