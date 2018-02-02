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
                ...state,
                loginAttempt: false,
                loggingIn: true,
            };
        case authenticationConstants.LOGIN_SUCCESS:
            return {
                user: action.user,
                loggedIn: true
            };
        case authenticationConstants.LOGIN_FAILURE:
            const newState = action.loginFailure.persistState ? state : {};
            return {
                ...newState,
                error: action.loginFailure.error,
                loginAttempt: true,
                loggingIn: false
            };

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
                loading: action.user.guest,
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
            return {
                registrationAttempt: true
            };
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
