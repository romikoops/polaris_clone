import { messagingConstants } from '../constants';
import { messagingService } from '../services';
import { alertActions } from './';
// import { Promise } from 'es6-promise-promise';
// import { push } from 'react-router-redux';

function getUserConversations() {
    function request(convoData) {
        return { type: messagingConstants.GET_USER_MESSAGES_REQUEST, payload: convoData };
    }
    function success(convoData) {
        return { type: messagingConstants.GET_USER_MESSAGES_SUCCESS, payload: convoData.data };
    }
    function failure(error) {
        return { type: messagingConstants.GET_USER_MESSAGES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        messagingService.getUserConversations().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Messages successful')
                );
                dispatch(success(data));
            },
            error => {
                // ;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function getAdminConversations() {
    function request(convoData) {
        return { type: messagingConstants.GET_ADMIN_MESSAGES_REQUEST, payload: convoData };
    }
    function success(convoData) {
        return { type: messagingConstants.GET_ADMIN_MESSAGES_SUCCESS, payload: convoData.data };
    }
    function failure(error) {
        return { type: messagingConstants.GET_ADMIN_MESSAGES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        messagingService.getAdminConversations().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Messages successful')
                );
                dispatch(success(data));
            },
            error => {
                // ;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function sendUserMessage(message) {
    function request(msgData) {
        return { type: messagingConstants.SEND_USER_MESSAGE_REQUEST, payload: msgData };
    }
    function success(msgData) {
        return { type: messagingConstants.SEND_USER_MESSAGE_SUCCESS, payload: msgData.data };
    }
    function failure(error) {
        return { type: messagingConstants.SEND_USER_MESSAGE_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        messagingService.sendUserMessage(message).then(
            data => {
                dispatch(
                    alertActions.success('Sending Message successful')
                );
                dispatch(success(data));
            },
            error => {
                // ;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function getShipment(ref) {
    function request(shipData) {
        return { type: messagingConstants.GET_SHIPMENT_DATA_REQUEST, payload: shipData };
    }
    function success(shipData) {
        return { type: messagingConstants.GET_SHIPMENT_DATA_SUCCESS, payload: shipData.data };
    }
    function failure(error) {
        return { type: messagingConstants.GET_SHIPMENT_DATA_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        messagingService.getShipmentData(ref).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Data successful')
                );
                dispatch(success(data));
            },
            error => {
                // ;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function markAsRead(ref) {
    function request(convoData) {
        return { type: messagingConstants.MARK_AS_READ_REQUEST, payload: convoData };
    }
    function success(convoData) {
        return { type: messagingConstants.MARK_AS_READ_SUCCESS, payload: convoData.data };
    }
    function failure(error) {
        return { type: messagingConstants.MARK_AS_READ_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        messagingService.markAsRead(ref).then(
            data => {
                dispatch(
                    alertActions.success('Mark As Read successful')
                );
                dispatch(success(data));
            },
            error => {
                // ;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}

function showMessageCenter() {
    return { type: messagingConstants.SHOW_MESSAGE_CENTER, payload: true };
}


export const messagingActions = {
    getUserConversations,
    sendUserMessage,
    getShipment,
    markAsRead,
    getAdminConversations,
    showMessageCenter
};
