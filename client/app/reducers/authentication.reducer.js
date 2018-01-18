import { authenticationConstants } from '../constants';
import { getSubdomain } from '../helpers/subdomain';
const subdomainKey = getSubdomain();
const cookieKey = subdomainKey + '_user';
const user = JSON.parse(localStorage.getItem(cookieKey));
const initialState = user ? { loggedIn: true, user } : {};

export function authentication(state = initialState, action) {
    switch (action.type) {
        case authenticationConstants.LOGIN_REQUEST:
            return {
                loggingIn: true,
                user: action.user
            };
        case authenticationConstants.LOGIN_SUCCESS:
            return {
                loggedIn: true,
                user: action.user
            };
        case authenticationConstants.LOGIN_FAILURE:
            return {};

        case authenticationConstants.UPDATE_USER_REQUEST:
            return {
                loggedIn: true,
                registering: true,
                user: action.user
            };
        case authenticationConstants.UPDATE_USER_SUCCESS:
            return {
                loggedIn: true,
                registered: true,
                user: action.user
            };
        case authenticationConstants.UPDATE_USER_FAILURE:
            return {};

        case authenticationConstants.REGISTRATION_REQUEST:
            return {
                loading: true,
                registering: true,
                user: action.user
            };
        case authenticationConstants.REGISTRATION_SUCCESS:
            return {
                loggedIn: true,
                registered: true,
                user: action.user
            };
        case authenticationConstants.REGISTRATION_FAILURE:
            return {};
        case authenticationConstants.LOGOUT:
            return {};
        case authentication.GETALL_REQUEST:
            return {
                loading: true
            };
         case authenticationConstants.SET_USER:
            return {
                ...state,
                user: action.user
            };
        default:
            return state;
    }
}
