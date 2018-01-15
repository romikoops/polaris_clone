import { userConstants } from '../constants';
import merge from 'lodash/merge';
export function users(state = {}, action) {
    switch (action.type) {
        case userConstants.GETALL_REQUEST:
            return {
                loading: true
            };
        case userConstants.GETALL_SUCCESS:
            return {
                items: action.payload
            };
        case userConstants.GETALL_FAILURE:
            return {
                error: action.error
            };
        case userConstants.DELETE_REQUEST:
            // add 'deleting:true' property to user being deleted
            return {
                ...state,
                items: state.items.map(
                    user =>
                        user.id === action.id
                            ? { ...user, deleting: true }
                            : user
                )
            };
        case userConstants.DELETE_SUCCESS:
            // remove deleted user from state
            return {
                items: state.items.filter(user => user.id !== action.id)
            };
        case userConstants.DELETE_FAILURE:
            // remove 'deleting:true' property and add 'deleteError:[error]' property to user
            return {
                ...state,
                items: state.items.map(user => {
                    if (user.id === action.id) {
                        // make copy of user without 'deleting:true' property
                        const { deleting, ...userCopy } = user;
                        console.log(deleting);
                        // return copy of user with 'deleteError:[error]' property
                        return { ...userCopy, deleteError: action.error };
                    }

                    return user;
                })
            };
        case userConstants.GETLOCATIONS_REQUEST:
            return {
                ...state,
                loading: true
            };
        case userConstants.GETLOCATIONS_SUCCESS:
            return {
                items: action.payload
            };
        case userConstants.GETLOCATIONS_FAILURE:
            return {
                error: action.error
            };
        case userConstants.DESTROYLOCATION_REQUEST:
            return {
                ...state,
                loading: true
            };
        case userConstants.DESTROYLOCATION_SUCCESS:
            return {
                items: state.items.filter(
                    item => item.id !== parseInt(action.payload.id, 10)
                )
            };
        case userConstants.DESTROYLOCATION_FAILURE:
            return {
                error: action.error
            };
        case userConstants.MAKEPRIMARY_REQUEST:
            return {
                ...state,
                loading: true
            };
        case userConstants.MAKEPRIMARY_SUCCESS:
            return {
                items: action.payload
            };
        case userConstants.MAKEPRIMARY_FAILURE:
            return {
                error: action.error
            };
         case userConstants.GET_SHIPMENTS_REQUEST:
            const reqShips = merge({}, state, {
                loading: true
            });
            return reqShips;
        case userConstants.GET_SHIPMENTS_SUCCESS:
            const succShips = merge({}, state, {
                shipments: action.payload.data,
                loading: false
            });
            return succShips;
        case userConstants.GET_SHIPMENTS_FAILURE:
            const errShips = merge({}, state, {
                error: { shipments: action.error }
            });
            return errShips;
        case userConstants.GET_HUBS_REQUEST:
            const reqHubs = merge({}, state, {
                loading: true
            });
            return reqHubs;
        case userConstants.GET_HUBS_SUCCESS:
            const succHubs = merge({}, state, {
                hubs: action.payload.data,
                loading: false
            });
            return succHubs;
        case userConstants.GET_HUBS_FAILURE:
            const errHubs = merge({}, state, {
                error: { hubs: action.error }
            });
            return errHubs;

        case userConstants.USER_GET_SHIPMENT_REQUEST:
            const reqShip = merge({}, state, {
                loading: true
            });
            return reqShip;
        case userConstants.USER_GET_SHIPMENT_SUCCESS:
            const succShip = merge({}, state, {
                shipment: action.payload.data,
                loading: false
            });
            return succShip;
        case userConstants.USER_GET_SHIPMENT_FAILURE:
            const errShip = merge({}, state, {
                error: { shipments: action.error }
            });
            return errShip;

        case userConstants.UPDATE_CONTACT_REQUEST:
            const reqContact = merge({}, state, {
                loading: true
            });
            return reqContact;
        case userConstants.UPDATE_CONTACT_SUCCESS:
            debugger;
            const contacts = state.dashboard.contacts.filter(x => x.id !== action.payload.data.id);
            contacts.push(action.payload.data);
            const succContact = merge({}, state, {
                dashboard: {
                    contacts: contacts
                },
                contactData : {
                    contact: action.payload.data
                },
                loading: false
            });
            return succContact;
        case userConstants.UPDATE_CONTACT_FAILURE:
            const errContact = merge({}, state, {
                error: { contacts: action.error }
            });
            return errContact;
        default:
            return state;
    }
}
