import { shipmentConstants } from '../constants';
import merge from 'lodash/merge';
export function shipment(state = {}, action) {
    switch (action.type) {
        case shipmentConstants.NEW_SHIPMENT_REQUEST:
            return {
                request: {
                    stage1: action.shipmentData
                },
                loading: true
            };
        case shipmentConstants.NEW_SHIPMENT_SUCCESS:
            return {
               response: {
                    stage1: action.shipmentData
               }
            };
        case shipmentConstants.NEW_SHIPMENT_FAILURE:
            return {
                error: action.error
            };

        case shipmentConstants.GET_SHIPMENT_REQUEST:
            return {
                loading: true
            };
        case shipmentConstants.GET_SHIPMENT_SUCCESS:
            return action.shipmentData;
        case shipmentConstants.GET_SHIPMENT_FAILURE:
            return {
                error: action.error
            };

        case shipmentConstants.SET_SHIPMENT_DETAILS_REQUEST:
            const req2 = merge({}, state, {request: { stage2: action.shipmentData }, loading: true});
            return req2;
        case shipmentConstants.SET_SHIPMENT_DETAILS_SUCCESS:
            const resp2 = merge({}, state, {response: { stage2: action.shipmentData }});
            return resp2;
            // return {
            //    response: { ...state.response, stage2: action.shipmentData}
            // };
            // return  Object.assign({}, state.shipment, action.shipmentData);
        case shipmentConstants.SET_SHIPMENT_DETAILS_FAILURE:
            return {
                error: action.error
            };


        case shipmentConstants.SET_SHIPMENT_ROUTE_REQUEST:
            const req3 = merge({}, state, {request: { stage3: action.shipmentData }, loading: true});
            return req3;
        case shipmentConstants.SET_SHIPMENT_ROUTE_SUCCESS:
            const resp3 = merge({}, state, {response: { stage3: action.shipmentData }});
            return resp3;
        case shipmentConstants.SET_SHIPMENT_ROUTE_FAILURE:
            return {
                error: action.error
            };

        case shipmentConstants.SET_SHIPMENT_CONTACTS_REQUEST:
            const req4 = merge({}, state, {request: { stage3: action.shipmentData }, loading: true});
            return req4;
        case shipmentConstants.SET_SHIPMENT_CONTACTS_SUCCESS:
            const resp4 = merge({}, state, {response: { stage4: action.shipmentData }});
            return resp4;
        case shipmentConstants.SET_SHIPMENT_CONTACTS_FAILURE:
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
