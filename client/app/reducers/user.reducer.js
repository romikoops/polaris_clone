import { userConstants } from '../constants';

const userData = JSON.parse(localStorage.getItem('user'));
const initialState = userData ? { loggedIn: true, userData } : {};

export function user(state = initialState, action) {
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
        default:
            return state;
    }
}
