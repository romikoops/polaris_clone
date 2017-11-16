import { shipmentConstants } from '../constants';

export function shipment(state = {}, action) {
    switch (action.type) {
        case shipmentConstants.NEW_SHIPMENT_REQUEST:
            return {
                loading: true
            };
        case shipmentConstants.NEW_SHIPMENT_SUCCESS:
            return {
                shipment: action.shipmentData
            };
        case shipmentConstants.NEW_SHIPMENT_FAILURE:
            return {
                error: action.error
            };
        case shipmentConstants.DELETE_REQUEST:
      // add 'deleting:true' property to user being deleted
            return {
                ...state,
                items: state.items.map(user =>
          user.id === action.id
            ? { ...user, deleting: true }
            : user
        )
            };
        case shipmentConstants.DELETE_SUCCESS:
      // remove deleted user from state
            return {
                items: state.items.filter(user => user.id !== action.id)
            };
        case shipmentConstants.DELETE_FAILURE:
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
        default:
            return state;
    }
}
