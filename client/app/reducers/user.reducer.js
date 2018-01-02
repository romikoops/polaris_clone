import { userConstants } from '../constants';

import merge from 'lodash/merge';

const userData = JSON.parse(localStorage.getItem('user'));
const initialState = userData ? { loggedIn: true, userData } : {};

export function users(state = initialState, action) {
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
                error: { hubs: action.error }
            });
            return errDash;

        default:
            return state;
    }
}
