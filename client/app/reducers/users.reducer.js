import { userConstants } from '../constants';

export function users(state = {}, action) {
    switch (action.type) {
        case userConstants.GETALL_REQUEST:
            return {
                loading: true
            };
        case userConstants.GETALL_SUCCESS:
            return {
                items: action.users
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
                loading: true
            };
        case userConstants.GETLOCATIONS_SUCCESS:
            return {
                items: action.locations
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
            // debugger;
            return {
                items: state.items.filter(item => item.id !== parseInt(action.payload.id, 10))
            };
        case userConstants.DESTROYLOCATION_FAILURE:
            return {
                error: action.error
            };
        default:
            return state;
    }
}
