import { nexusConstants } from '../constants';
import { nexusService } from '../services';

function getAvailableDestinations(routes, origin) {
    function request() {
        return { type: nexusConstants.GET_AVAILABLE_DESTINATIONS_REQUEST };
    }
    function success(response) {
        return {
            type: nexusConstants.GET_AVAILABLE_DESTINATIONS_SUCCESS,
            data: response.data
        };
    }
    function failure(error) {
        return { type: nexusConstants.GET_AVAILABLE_DESTINATIONS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());
        nexusService.getAvailableDestinations(routes, origin)
            .then(
                response => dispatch(success(response)),
                error => dispatch(failure(error))
            );
    };
}

export const nexusActions = {
    getAvailableDestinations,
};
