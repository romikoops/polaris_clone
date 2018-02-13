import { userConstants } from '../constants';

import merge from 'lodash/merge';
import { getSubdomain } from '../helpers/subdomain';
const subdomainKey = getSubdomain();
const cookieKey = subdomainKey + '_user';
const userData = JSON.parse(localStorage.getItem(cookieKey));
// const userData = JSON.parse(localStorage.getItem('user'));
const initialState = userData ? { loggedIn: true, userData } : {};

export function users(state = initialState, action) {
    switch (action.type) {
        case userConstants.GETALL_REQUEST:
            return {
                loading: true
            };
        case userConstants.GETALL_SUCCESS:
            return {
                loading: false,
                items: action.payload
            };
        case userConstants.GETALL_FAILURE:
            return {
                loading: false,
                error: action.error
            };
        case userConstants.DELETE_REQUEST:
            // add 'deleting:true' property to user being deleted
            return {
                ...state,
                loading: false,
                items: state.items.map(
                    userData =>
                        userData.id === action.id
                            ? { ...userData, deleting: true }
                            : userData
                )
            };
        case userConstants.DELETE_SUCCESS:
            // remove deleted user from state
            return {
                items: state.items.filter(userData => userData.id !== action.id)
            };
        case userConstants.DELETE_FAILURE:
            // remove 'deleting:true' property and add 'deleteError:[error]' property to user
            return {
                ...state,
                loading: false,
                items: state.items.map(userData => {
                    if (userData.id === action.id) {
                        // make copy of user without 'deleting:true' property
                        const { deleting, ...userCopy } = userData;
                        console.log(deleting);
                        // return copy of user with 'deleteError:[error]' property
                        return { ...userCopy, deleteError: action.error };
                    }

                    return userData;
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
                ...state,
                loading: false,
                error: action.error
            };
        case userConstants.DESTROYLOCATION_REQUEST:
            return {
                ...state,
                loading: true
            };
        case userConstants.DESTROYLOCATION_SUCCESS:
            return {
                ...state,
                dashboard: {
                    ...state.dashboard,
                    locations: state.dashboard.locations.filter(
                        item => item.location.id !== parseInt(action.payload.id, 10)
                    )
                },
                loading: false
            };
        case userConstants.DESTROYLOCATION_FAILURE:
            return {
                ...state,
                loading: false,
                error: action.error
            };
        case userConstants.MAKEPRIMARY_REQUEST:
            return {
                ...state,
                loading: true
            };
        case userConstants.MAKEPRIMARY_SUCCESS:
            return {
                ...state,
                loading: false,
                dashboard: {
                    ...state.dashboard,
                    locations: action.payload
                }
            };
        case userConstants.MAKEPRIMARY_FAILURE:
            return {
                loading: false,
                error: action.error
            };

        case userConstants.NEW_USER_LOCATION_REQUEST:
            return {
                ...state,
                loading: true
            };
        case userConstants.NEW_USER_LOCATION_SUCCESS:
            return {
                ...state,
                loading: false,
                dashboard: {
                    ...state.dashboard,
                    locations: action.payload
                }
            };
        case userConstants.NEW_USER_LOCATION_FAILURE:
            return {
                loading: false,
                error: action.error
            };

        case userConstants.EDIT_USER_LOCATION_REQUEST:
            return {
                ...state,
                loading: true
            };
        case userConstants.EDIT_USER_LOCATION_SUCCESS:
            return {
               ...state,
                loading: false,
                dashboard: {
                    ...state.dashboard,
                    locations: action.payload
                }
            };
        case userConstants.EDIT_USER_LOCATION_FAILURE:
            return {
                loading: false,
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
                loading: false,
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
                loading: false,
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
                loading: false,
                error: { shipments: action.error }
            });
            return errShip;

        case userConstants.GET_DASHBOARD_REQUEST:
            const reqDash = merge({}, state, {
                loading: true
            });
            return reqDash;
        case userConstants.GET_DASHBOARD_SUCCESS:
            const succDash = merge({}, state, {
                dashboard: action.payload.data,
                loading: false
            });
            return succDash;
        case userConstants.GET_DASHBOARD_FAILURE:
            const errDash = merge({}, state, {
                loading: false,
                error: { hubs: action.error }
            });
            return errDash;

        case userConstants.GET_CONTACT_REQUEST:
            const reqContact = merge({}, state, {
                loading: true
            });
            return reqContact;
        case userConstants.GET_CONTACT_SUCCESS:
            const succContact = merge({}, state, {
                contactData: action.payload.data,
                loading: false
            });
            return succContact;
        case userConstants.GET_CONTACT_FAILURE:
            const errContact = merge({}, state, {
                loading: false,
                error: { contact: action.error }
            });
            return errContact;

        case userConstants.NEW_CONTACT_REQUEST:
            const reqNewContact = merge({}, state, {
                loading: true
            });
            return reqNewContact;
        case userConstants.NEW_CONTACT_SUCCESS:
            const succNewContact = merge({}, state, {
                contactData: action.payload.data,
                loading: false
            });
            return succNewContact;
        case userConstants.NEW_CONTACT_FAILURE:
            const errNewContact = merge({}, state, {
                loading: false,
                error: { contactData: action.error }
            });
            return errNewContact;

        case userConstants.NEW_ALIAS_REQUEST:
            const reqNewAlias = merge({}, state, {
                loading: true
            });
            return reqNewAlias;
        case userConstants.NEW_ALIAS_SUCCESS:
            const aliases = state.dashboard.aliases;
            aliases.push(action.payload.data);
            const succNewAlias = merge({}, state, {
                contactData: aliases,
                loading: false
            });
            return succNewAlias;
        case userConstants.NEW_ALIAS_FAILURE:
            const errNewAlias = merge({}, state, {
                loading: false,
                error: { contactData: action.error }
            });
            return errNewAlias;

        case userConstants.DELETE_ALIAS_REQUEST:
            const reqDeleteAlias = merge({}, state, {
                loading: true
            });
            return reqDeleteAlias;
        case userConstants.DELETE_ALIAS_SUCCESS:
            const aliasless = state.dashboard.aliases.filter(x => x.id !== parseInt(action.payload.data, 10));
            return {
                ...state,
                dashboard: {
                    ...state.dashboard,
                    aliases: aliasless
                },
                loading: false
            };
        case userConstants.DELETE_ALIAS_FAILURE:
            const errDeleteAlias = merge({}, state, {
                loading: false,
                error: { contactData: action.error }
            });
            return errDeleteAlias;


        case userConstants.UPLOAD_DOCUMENT_REQUEST:
            const reqDocUpload = merge({}, state, {
            });
            return reqDocUpload;
        case userConstants.UPLOAD_DOCUMENT_SUCCESS:

            const docs = state.shipment.documents;
            docs.push(action.payload);
            const succDocUpload = merge({}, state, {
                shipment: {
                    documents: docs
                },
                loading: false
            });
            return succDocUpload;
        case userConstants.UPLOAD_DOCUMENT_FAILURE:
            const errDocUpload = merge({}, state, {
                loading: false,
                error: { hubs: action.error }
            });
            return errDocUpload;


        case userConstants.DELETE_DOCUMENT_REQUEST:
            const reqDocDelete = merge({}, state, {
            });
            return reqDocDelete;
        case userConstants.DELETE_DOCUMENT_SUCCESS:
            const succDocDelete = merge({}, state, {
                shipment: {
                    documents: state.shipment.documents.filter(item => item.id !== action.payload)
                },
                loading: false
            });
            return succDocDelete;
        case userConstants.DELETE_DOCUMENT_FAILURE:
            const errDocDelete = merge({}, state, {
                loading: false,
                error: { hubs: action.error }
            });
            return errDocDelete;

        case userConstants.UPDATE_CONTACT_ADDRESS_REQUEST:
            return {...state, loading: true};
        case userConstants.UPDATE_CONTACT_ADDRESS_SUCCESS:
            const cLData = state.contactData;
            cLData.location = action.payload;
            return {
                ...state,
                contactData: cLData,
                loading: false
            };
        case userConstants.UPDATE_CONTACT_ADDRESS_FAILURE:
            return {
                ...state,
                loading: false,
                error: { hubs: action.error }
            };

        case userConstants.DELETE_CONTACT_ADDRESS_REQUEST:
            return {...state, loading: true};
        case userConstants.DELETE_CONTACT_ADDRESS_SUCCESS:
            const caData = state.contactData;
            caData.location = false;
            return {
                ...state,
                contactData: caData,
                loading: false
            };
        case userConstants.DELETE_CONTACT_ADDRESS_FAILURE:
            return {
                ...state,
                loading: false,
                error: { hubs: action.error }
            };

        case userConstants.UPDATE_CONTACT_REQUEST:
            return {...state, loading: true};
        case userConstants.UPDATE_CONTACT_SUCCESS:
            const cData = state.contactData;
            cData.contact = action.payload;
            return {
                ...state,
                contactData: cData,
                loading: false
            };
        case userConstants.UPDATE_CONTACT_FAILURE:
            return {
                ...state,
                loading: false,
                error: { hubs: action.error }
            };

        case userConstants.CLEAR_LOADING:
            return {
                ...state,
                loading: false
            };
        case userConstants.USER_LOG_OUT:
            return {};

        default:
            return state;
    }
}
