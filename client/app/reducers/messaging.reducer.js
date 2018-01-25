import { messagingConstants } from '../constants';
import merge from 'lodash/merge';
export function messaging(state = {}, action) {
    switch (action.type) {
        case messagingConstants.GET_USER_MESSAGES_SUCCESS:
            return merge({}, state, {
                ...action.payload,
                loading: false
            });
        case messagingConstants.GET_USER_MESSAGES_ERROR:
            return merge({}, state, {
                error: action.payload,
                loading: false
            });
        case messagingConstants.GET_USER_MESSAGES_REQUEST:
            return merge({}, state, {
                loading: true
            });
        case messagingConstants.SEND_USER_MESSAGE_SUCCESS:
            return merge({}, state, {
                ...action.payload,
                loading: false
            });
        case messagingConstants.SEND_USER_MESSAGE_ERROR:
            return merge({}, state, {
                error: action.payload,
                loading: false
            });
        case messagingConstants.SEND_USER_MESSAGE_REQUEST:
            return merge({}, state, {
                loading: true
            });

        case messagingConstants.GET_SHIPMENT_DATA_SUCCESS:
            return merge({}, state, {
                shipment: action.payload,
                loading: false
            });
        case messagingConstants.GET_SHIPMENT_DATA_ERROR:
            return merge({}, state, {
                error: action.payload,
                loading: false
            });
        case messagingConstants.GET_SHIPMENT_DATA_REQUEST:
            return merge({}, state, {
                loading: true
            });
        case messagingConstants.MARK_AS_READ_SUCCESS:
            return merge({}, state, {
                ...action.payload,
                loading: false
            });
        case messagingConstants.MARK_AS_READ_ERROR:
            return merge({}, state, {
                error: action.payload,
                loading: false
            });
        case messagingConstants.MARK_AS_READ_REQUEST:
            return merge({}, state, {
                loading: true
            });
        default:
            return state;
    }
}
