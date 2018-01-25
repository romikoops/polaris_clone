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


export const messagingActions = {
    getUserConversations,
    sendUserMessage
};
