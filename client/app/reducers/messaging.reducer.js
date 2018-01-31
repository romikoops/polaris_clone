import { messagingConstants } from '../constants';
export function messaging(state = {}, action) {
    switch (action.type) {
        case messagingConstants.GET_USER_MESSAGES_SUCCESS:
            return {
                ...state,
                ...action.payload,
                loading: false
            };
        case messagingConstants.GET_USER_MESSAGES_ERROR:
            return {
                ...state,
                error: action.payload,
                loading: false
            };
        case messagingConstants.GET_USER_MESSAGES_REQUEST:
            return {
                ...state,
                loading: true
            };

        case messagingConstants.GET_ADMIN_MESSAGES_SUCCESS:
            return {
                ...state,
                ...action.payload,
                loading: false
            };
        case messagingConstants.GET_ADMIN_MESSAGES_ERROR:
            return {
                ...state,
                error: action.payload,
                loading: false
            };
        case messagingConstants.GET_ADMIN_MESSAGES_REQUEST:
            return {
                ...state,
                loading: true
            };

        case messagingConstants.SEND_USER_MESSAGE_SUCCESS:
            return {
                ...state,
                ...action.payload,
                loading: false
            };
        case messagingConstants.SEND_USER_MESSAGE_ERROR:
            return {
                ...state,
                error: action.payload,
                loading: false
            };
        case messagingConstants.SEND_USER_MESSAGE_REQUEST:
            return {
                ...state,
                loading: true
            };

        case messagingConstants.GET_SHIPMENT_DATA_SUCCESS:
            return {
                ...state,
                shipment: action.payload,
                loading: false
            };
        case messagingConstants.GET_SHIPMENT_DATA_ERROR:
            return {
                ...state,
                error: action.payload,
                loading: false
            };
        case messagingConstants.GET_SHIPMENT_DATA_REQUEST:
            return {
                ...state,
                loading: true
            };
        case messagingConstants.MARK_AS_READ_SUCCESS:
            return {
                ...state,
                ...action.payload,
                loading: false
            };
        case messagingConstants.MARK_AS_READ_ERROR:
            return {
                ...state,
                error: action.payload,
                loading: false
            };
        case messagingConstants.MARK_AS_READ_REQUEST:
            return {
                ...state,
                loading: true
            };
        case messagingConstants.SHOW_MESSAGE_CENTER:
            return {
                ...state,
                showMessages: !state.showMessages
            };
        default:
            return state;
    }
}
