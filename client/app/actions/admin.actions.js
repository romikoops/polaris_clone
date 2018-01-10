import { adminConstants } from '../constants/admin.constants';
import { adminService } from '../services/admin.service';
import { alertActions } from './';
// import { Promise } from 'es6-promise-promise';
import { push } from 'react-router-redux';

function getHubs(redirect) {
    function request(hubData) {
        return { type: adminConstants.GET_HUBS_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: adminConstants.GET_HUBS_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: adminConstants.GET_HUBS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getHubs().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Hubs successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/hubs')
                    );
                }
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

function getHub(id, redirect) {
    function request(hubData) {
        return { type: adminConstants.GET_HUB_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: adminConstants.GET_HUB_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: adminConstants.GET_HUB_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getHub(id).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Hubs successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/hubs/' + id)
                    );
                }
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

function wizardHubs(file) {
    function request(hubData) {
        return { type: adminConstants.WIZARD_HUBS_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: adminConstants.WIZARD_HUBS_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: adminConstants.WIZARD_HUBS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.wizardHubs(file).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Hubs successful')
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

function wizardSCharge(file) {
    function request(hubData) {
        return { type: adminConstants.WIZARD_SERVICE_CHARGE_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: adminConstants.WIZARD_SERVICE_CHARGE_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: adminConstants.WIZARD_SERVICE_CHARGE_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.wizardSCharge(file).then(
            data => {
                dispatch(
                    alertActions.success('Wizard Service Charges successful')
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

function wizardPricings(file) {
    function request(hubData) {
        return { type: adminConstants.WIZARD_PRICING_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: adminConstants.WIZARD_PRICING_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: adminConstants.WIZARD_PRICING_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.wizardPricings(file).then(
            data => {
                dispatch(
                    alertActions.success('Wizard Pricings successful')
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

function wizardTrucking(type, file) {
    function request(hubData) {
        return { type: adminConstants.WIZARD_TRUCKING_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: adminConstants.WIZARD_TRUCKING_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: adminConstants.WIZARD_TRUCKING_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.wizardTrucking(type, file).then(
            data => {
                dispatch(
                    alertActions.success('Wizard Trucking successful')
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

function wizardOpenPricings(file) {
    function request(hubData) {
        return { type: adminConstants.WIZARD_OPEN_PRICING_REQUEST, payload: hubData };
    }
    function success(hubData) {
        return { type: adminConstants.WIZARD_OPEN_PRICING_SUCCESS, payload: hubData };
    }
    function failure(error) {
        return { type: adminConstants.WIZARD_OPEN_PRICING_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.wizardOpenPricings(file).then(
            data => {
                dispatch(
                    alertActions.success('Wizard Open Pricings successful')
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

function getServiceCharges(redirect) {
    function request(scData) {
        return { type: adminConstants.GET_SERVICE_CHARGES_REQUEST, payload: scData };
    }
    function success(scData) {
        return { type: adminConstants.GET_SERVICE_CHARGES_SUCCESS, payload: scData };
    }
    function failure(error) {
        return { type: adminConstants.GET_SERVICE_CHARGES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getServiceCharges().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Service Charges successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/service_charges')
                    );
                }
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
function getPricings(redirect) {
    function request(prData) {
        return { type: adminConstants.GET_PRICINGS_REQUEST, payload: prData };
    }
    function success(prData) {
        // ;
        return { type: adminConstants.GET_PRICINGS_SUCCESS, payload: prData };
    }
    function failure(error) {
        return { type: adminConstants.GET_PRICINGS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getPricings().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Prices successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/pricings')
                    );
                }
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

function getClientPricings(id, redirect) {
    function request(prData) {
        return { type: adminConstants.GET_CLIENT_PRICINGS_REQUEST, payload: prData };
    }
    function success(prData) {
        // ;
        return { type: adminConstants.GET_CLIENT_PRICINGS_SUCCESS, payload: prData };
    }
    function failure(error) {
        return { type: adminConstants.GET_CLIENT_PRICINGS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getClientPricings(id).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Client Prices successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/pricings/clients/' + id)
                    );
                }
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

function getRoutePricings(id, redirect) {
    function request(prData) {
        return { type: adminConstants.GET_ROUTE_PRICINGS_REQUEST, payload: prData };
    }
    function success(prData) {
        // ;
        return { type: adminConstants.GET_ROUTE_PRICINGS_SUCCESS, payload: prData };
    }
    function failure(error) {
        return { type: adminConstants.GET_ROUTE_PRICINGS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getRoutePricings(id).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Route Prices successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/pricings/routes/' + id)
                    );
                }
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

function updatePricing(id, req) {
    function request(prData) {
        return { type: adminConstants.UPDATE_PRICING_REQUEST, payload: prData };
    }
    function success(prData) {
        // ;
        return { type: adminConstants.UPDATE_PRICING_SUCCESS, payload: prData };
    }
    function failure(error) {
        return { type: adminConstants.UPDATE_PRICING_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.updatePricing(id, req).then(
            data => {
                dispatch(
                    alertActions.success('Updating Pricing successful')
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

function getSchedules(redirect) {
    function request(schedData) {
        return { type: adminConstants.GET_SCHEDULES_REQUEST, payload: schedData };
    }
    function success(schedData) {
        return { type: adminConstants.GET_SCHEDULES_SUCCESS, payload: schedData };
    }
    function failure(error) {
        return { type: adminConstants.GET_SCHEDULES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getSchedules().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Schedules successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/schedules')
                    );
                }
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

function getTrucking(redirect) {
    function request(truckData) {
        return { type: adminConstants.GET_TRUCKING_REQUEST, payload: truckData };
    }
    function success(truckData) {
        return { type: adminConstants.GET_TRUCKING_SUCCESS, payload: truckData };
    }
    function failure(error) {
        return { type: adminConstants.GET_TRUCKING_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getTrucking().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Trucking successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/trucking')
                    );
                }
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

function getShipments(redirect) {
    function request(shipmentData) {
        return { type: adminConstants.GET_SHIPMENTS_REQUEST, payload: shipmentData };
    }
    function success(shipmentData) {
        return { type: adminConstants.GET_SHIPMENTS_SUCCESS, payload: shipmentData };
    }
    function failure(error) {
        return { type: adminConstants.GET_SHIPMENTS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getShipments().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Shipments successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/shipments')
                    );
                }

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

function getShipment(id, redirect) {
    function request(shipmentData) {
        return { type: adminConstants.ADMIN_GET_SHIPMENT_REQUEST, payload: shipmentData };
    }
    function success(shipmentData) {
        return { type: adminConstants.ADMIN_GET_SHIPMENT_SUCCESS, payload: shipmentData };
    }
    function failure(error) {
        return { type: adminConstants.ADMIN_GET_SHIPMENT_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getShipment(id).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Shipment successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/shipments/' + id)
                    );
                }
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

function getClients(redirect) {
    function request(clientData) {
        return { type: adminConstants.GET_CLIENTS_REQUEST, payload: clientData };
    }
    function success(clientData) {
        return { type: adminConstants.GET_CLIENTS_SUCCESS, payload: clientData };
    }
    function failure(error) {
        return { type: adminConstants.GET_CLIENTS_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getClients().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Clients successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/clients')
                    );
                }

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

function getClient(id, redirect) {
    function request(clientData) {
        return { type: adminConstants.GET_CLIENT_REQUEST, payload: clientData };
    }
    function success(clientData) {
        return { type: adminConstants.GET_CLIENT_SUCCESS, payload: clientData };
    }
    function failure(error) {
        return { type: adminConstants.GET_CLIENT_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getClient(id).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Clients successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/clients/' + id)
                    );
                }

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

function getVehicleTypes() {
    function request(vehicleData) {
        return { type: adminConstants.GET_VEHICLE_TYPES_REQUEST, payload: vehicleData };
    }
    function success(vehicleData) {
        return { type: adminConstants.GET_VEHICLE_TYPES_SUCCESS, payload: vehicleData };
    }
    function failure(error) {
        return { type: adminConstants.GET_VEHICLE_TYPES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getVehicleTypes().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Vehicle Types successful')
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

function getDashboard(redirect) {
    function request(dashData) {
        return { type: adminConstants.GET_DASHBOARD_REQUEST, payload: dashData };
    }
    function success(dashData) {
        return { type: adminConstants.GET_DASHBOARD_SUCCESS, payload: dashData };
    }
    function failure(error) {
        return { type: adminConstants.GET_DASHBOARD_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getDashboard().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Dashboard successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/dashboard')
                    );
                }
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


function autoGenSchedules(data) {
    function request(schedData) {
        return { type: adminConstants.GENERATE_SCHEDULES_REQUEST, payload: schedData };
    }
    function success(schedData) {
        return { type: adminConstants.GENERATE_SCHEDULES_SUCCESS, payload: schedData };
    }
    function failure(error) {
        return { type: adminConstants.GENERATE_SCHEDULES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.autoGenSchedules(data).then(
            schedData => {
                dispatch(
                    alertActions.success('Generating Schedules successful')
                );
                dispatch(success(schedData));
            },
            error => {
                // ;
                dispatch(failure(error));
                dispatch(alertActions.error(error));
            }
        );
    };
}
function confirmShipment(id, action, redirect) {
    function request(shipmentData) {
        return {
            type: adminConstants.CONFIRM_SHIPMENT_REQUEST,
            payload: shipmentData
        };
    }
    function success(shipmentData) {
        return {
            type: adminConstants.CONFIRM_SHIPMENT_SUCCESS,
            payload: shipmentData
        };
    }
    function failure(error) {
        return { type: adminConstants.CONFIRM_SHIPMENT_FAILURE, error };
    }
    return dispatch => {
        dispatch(request(id, action));
        adminService.confirmShipment(id, action).then(
            resp => {
                const shipmentData = resp.data;
                dispatch(success(shipmentData));
                if (redirect) {
                    dispatch(
                        push('/admin/shipments/' + id)
                    );
                }
                dispatch(
                    alertActions.success('Shipment Action Set successful')
                );
            },
            error => {
                error.then(data => {
                    dispatch(failure({ type: 'error', text: data.message }));
                });
            }
        );
    };
}
function getRoutes(redirect) {
    function request(routeData) {
        return { type: adminConstants.GET_ROUTES_REQUEST, payload: routeData };
    }
    function success(routeData) {
        return { type: adminConstants.GET_ROUTES_SUCCESS, payload: routeData };
    }
    function failure(error) {
        return { type: adminConstants.GET_ROUTES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getRoutes().then(
            data => {
                dispatch(
                    alertActions.success('Fetching Routes successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/routes')
                    );
                }
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

function getRoute(id, redirect) {
    function request(routeData) {
        return { type: adminConstants.GET_ROUTE_REQUEST, payload: routeData };
    }
    function success(routeData) {
        return { type: adminConstants.GET_ROUTE_SUCCESS, payload: routeData };
    }
    function failure(error) {
        return { type: adminConstants.GET_ROUTE_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.getRoute(id).then(
            data => {
                dispatch(
                    alertActions.success('Fetching Route successful')
                );
                if (redirect) {
                    dispatch(
                        push('/admin/routes/' + id)
                    );
                }
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

function updateServiceCharge(id, req) {
    function request(prData) {
        return { type: adminConstants.UPDATE_SERVICE_CHARGES_REQUEST, payload: prData };
    }
    function success(prData) {
        // ;
        return { type: adminConstants.UPDATE_SERVICE_CHARGES_SUCCESS, payload: prData };
    }
    function failure(error) {
        return { type: adminConstants.UPDATE_SERVICE_CHARGES_FAILURE, error };
    }
    return dispatch => {
        dispatch(request());

        adminService.updateServiceCharge(id, req).then(
            data => {
                dispatch(
                    alertActions.success('Updating Pricing successful')
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

function viewTrucking(truckingHub, pricing) {
    const payload = {truckingHub, pricing};
    function set(data) {
        // ;
        return { type: adminConstants.VIEW_TRUCKING, payload: data };
    }
    return dispatch => {
        dispatch(push('/admin/trucking/' + truckingHub._id));
        dispatch(set(payload));
    };
}

function goTo(path) {
    return dispatch => {
        dispatch(push(path));
    };
}
export const adminActions = {
    getHubs,
    getRoutes,
    updateServiceCharge,
    updatePricing,
    getClientPricings,
    getRoute,
    getServiceCharges,
    getPricings,
    getTrucking,
    getClient,
    getShipment,
    getSchedules,
    getDashboard,
    goTo,
    autoGenSchedules,
    getVehicleTypes,
    getShipments,
    getClients,
    confirmShipment,
    getHub,
    getRoutePricings,
    wizardHubs,
    wizardSCharge,
    wizardPricings,
    wizardOpenPricings,
    wizardTrucking,
    viewTrucking
};
