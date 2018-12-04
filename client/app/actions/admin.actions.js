import { push } from 'react-router-redux'
import { adminConstants } from '../constants/admin.constants'
import { adminService } from '../services/admin.service'
import { alertActions, documentActions } from './'

function getHubs (redirect, page, hubType, country, status) {
  function request (hubData) {
    return { type: adminConstants.GET_HUBS_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.GET_HUBS_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.GET_HUBS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getHubs(page, hubType, country, status).then(
      (data) => {
        if (redirect) {
          dispatch(push('/admin/hubs'))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function getAllHubs () {
  function request (hubData) {
    return { type: adminConstants.GET_ALL_HUBS_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.GET_ALL_HUBS_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.GET_ALL_HUBS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getAllHubs().then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function searchHubs (text, page, hubType, country, status) {
  function request (hubData) {
    return { type: adminConstants.GET_HUBS_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.GET_HUBS_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.GET_HUBS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.searchHubs(text, page, hubType, country, status).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function searchShipments (text, target, page, perPage) {
  function request (hubData) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_PAGE_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_PAGE_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_PAGE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.searchShipments(text, target, page, perPage).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getHub (id, redirect) {
  function request (hubData) {
    return { type: adminConstants.GET_HUB_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.GET_HUB_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.GET_HUB_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getHub(id).then(
      (data) => {
        dispatch(success(data))
        if (redirect) {
          dispatch(push(`/admin/hubs/${id}`))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function editHub (id, object) {
  function request (hubData) {
    return { type: adminConstants.EDIT_HUB_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.EDIT_HUB_SUCCESS, payload: hubData.data }
  }
  function failure (error) {
    return { type: adminConstants.EDIT_HUB_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.editHub(id, object).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function wizardHubs (file) {
  function request (hubData) {
    return { type: adminConstants.WIZARD_HUBS_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.WIZARD_HUBS_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.WIZARD_HUBS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.wizardHubs(file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function wizardSCharge (file) {
  function request (hubData) {
    return { type: adminConstants.WIZARD_SERVICE_CHARGE_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.WIZARD_SERVICE_CHARGE_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.WIZARD_SERVICE_CHARGE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.wizardSCharge(file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function wizardPricings (file) {
  function request (hubData) {
    return { type: adminConstants.WIZARD_PRICING_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.WIZARD_PRICING_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.WIZARD_PRICING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.wizardPricings(file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function wizardTrucking (type, file) {
  function request (hubData) {
    return { type: adminConstants.WIZARD_TRUCKING_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.WIZARD_TRUCKING_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.WIZARD_TRUCKING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.wizardTrucking(type, file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function wizardOpenPricings (file) {
  function request (hubData) {
    return { type: adminConstants.WIZARD_OPEN_PRICING_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.WIZARD_OPEN_PRICING_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: adminConstants.WIZARD_OPEN_PRICING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.wizardOpenPricings(file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getServiceCharges (redirect) {
  function request (scData) {
    return { type: adminConstants.GET_SERVICE_CHARGES_REQUEST, payload: scData }
  }
  function success (scData) {
    return { type: adminConstants.GET_SERVICE_CHARGES_SUCCESS, payload: scData }
  }
  function failure (error) {
    return { type: adminConstants.GET_SERVICE_CHARGES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getServiceCharges().then(
      (data) => {
        if (redirect) {
          dispatch(push('/admin/service_charges'))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function getPricings (redirect, pages) {
  function request (prData) {
    return { type: adminConstants.GET_PRICINGS_REQUEST, payload: prData }
  }
  function success (prData) {
    return { type: adminConstants.GET_PRICINGS_SUCCESS, payload: prData }
  }
  function failure (error) {
    return { type: adminConstants.GET_PRICINGS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    dispatch(getTrucking())
    adminService.getPricings(pages).then(
      (response) => {
        if (redirect) {
          dispatch(push('/admin/pricings'))
        }
        dispatch(success(response.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function searchPricings (text, page, mot) {
  function request (pricingData) {
    return { type: adminConstants.SEARCH_PRICINGS_REQUEST, payload: pricingData }
  }
  function success (pricingData) {
    return { type: adminConstants.SEARCH_PRICINGS_SUCCESS, payload: pricingData }
  }
  function failure (error) {
    return { type: adminConstants.SEARCH_PRICINGS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.searchPricings(text, page, mot).then(
      (response) => {
        dispatch(success(response.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getPricingsTest (req) {
  function request (prData) {
    return { type: adminConstants.GET_PRICINGS_TEST_REQUEST, payload: prData }
  }
  function success (prData) {
    return { type: adminConstants.GET_PRICINGS_TEST_SUCCESS, payload: prData }
  }
  function failure (error) {
    return { type: adminConstants.GET_PRICINGS_TEST_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    dispatch(getTrucking())
    adminService.getPricingsTest(req).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function deletePricing (pricing) {
  function request (payload) {
    return { type: adminConstants.DELETE_PRICING_REQUEST, payload }
  }
  function success (payload) {
    return { type: adminConstants.DELETE_PRICING_SUCCESS, payload }
  }
  function failure (error) {
    return { type: adminConstants.DELETE_PRICING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(pricing))
    adminService.deletePricing(pricing).then(
      () => {
        dispatch(success(pricing))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getClientPricings (id, redirect) {
  function request (prData) {
    return { type: adminConstants.GET_CLIENT_PRICINGS_REQUEST, payload: prData }
  }
  function success (prData) {
    // ;
    return { type: adminConstants.GET_CLIENT_PRICINGS_SUCCESS, payload: prData }
  }
  function failure (error) {
    return { type: adminConstants.GET_CLIENT_PRICINGS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getClientPricings(id).then(
      (data) => {
        if (redirect) {
          dispatch(push(`/admin/pricings/clients/${id}`))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getItineraryPricings (id, redirect) {
  function request (prData) {
    return { type: adminConstants.GET_ROUTE_PRICINGS_REQUEST, payload: prData }
  }
  function success (prData) {
    // ;
    return { type: adminConstants.GET_ROUTE_PRICINGS_SUCCESS, payload: prData }
  }
  function failure (error) {
    return { type: adminConstants.GET_ROUTE_PRICINGS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    dispatch(getTrucking())
    adminService.getItineraryPricings(id).then(
      (data) => {
        if (redirect) {
          dispatch(push(`/admin/pricings/routes/${id}`))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function updatePricing (id, req) {
  function request (prData) {
    return { type: adminConstants.UPDATE_PRICING_REQUEST, payload: prData }
  }
  function success (prData) {
    return { type: adminConstants.UPDATE_PRICING_SUCCESS, payload: prData }
  }
  function failure (error) {
    return { type: adminConstants.UPDATE_PRICING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.updatePricing(id, req).then(
      (data) => {
        dispatch(success(data.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function assignDedicatedPricings (pricing, clientIds) {
  function request (prData) {
    return { type: adminConstants.ASSIGN_DEDICATED_PRICING_REQUEST, payload: prData }
  }
  function success (prData) {
    // ;
    return { type: adminConstants.ASSIGN_DEDICATED_PRICING_SUCCESS, payload: prData }
  }
  function failure (error) {
    return { type: adminConstants.ASSIGN_DEDICATED_PRICING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.assignDedicatedPricings(pricing, clientIds).then(
      (data) => {
        dispatch(success(data.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getSchedules (redirect) {
  function request (schedData) {
    return { type: adminConstants.GET_SCHEDULES_REQUEST, payload: schedData }
  }
  function success (schedData) {
    return { type: adminConstants.GET_SCHEDULES_SUCCESS, payload: schedData }
  }
  function failure (error) {
    return { type: adminConstants.GET_SCHEDULES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getSchedules().then(
      (data) => {
        dispatch(success(data))
        if (redirect) {
          dispatch(push('/admin/schedules'))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getTrucking (redirect) {
  function request (truckData) {
    return { type: adminConstants.GET_TRUCKING_REQUEST, payload: truckData }
  }
  function success (truckData) {
    return { type: adminConstants.GET_TRUCKING_SUCCESS, payload: truckData }
  }
  function failure (error) {
    return { type: adminConstants.GET_TRUCKING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getTrucking().then(
      (data) => {
        if (redirect) {
          dispatch(push('/admin/trucking'))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getShipments (pages, perPage, params, redirect) {
  function request (shipmentData) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_REQUEST, payload: shipmentData }
  }
  function success (shipmentData) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_SUCCESS, payload: shipmentData }
  }
  function failure (error) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getShipments(pages, perPage, params, redirect).then(
      (data) => {
        dispatch(success(data))
        if (redirect) {
          dispatch(push('/admin/shipments'))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deltaShipmentsPage (target, page, perPage, params) {
  function request (shipmentData) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_PAGE_REQUEST, payload: shipmentData }
  }
  function success (shipmentData) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_PAGE_SUCCESS, payload: shipmentData }
  }
  function failure (error) {
    return { type: adminConstants.ADMIN_GET_SHIPMENTS_PAGE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.deltaShipmentsPage(target, page, perPage, params).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function getDashShipments () {
  function request (shipmentData) {
    return { type: adminConstants.GET_DASH_SHIPMENTS_REQUEST, payload: shipmentData }
  }
  function success (shipmentData) {
    return { type: adminConstants.GET_DASH_SHIPMENTS_SUCCESS, payload: shipmentData }
  }
  function failure (error) {
    return { type: adminConstants.GET_DASH_SHIPMENTS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getShipments().then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getShipment (id, redirect) {
  function request (shipmentData) {
    return { type: adminConstants.ADMIN_GET_SHIPMENT_REQUEST, payload: shipmentData }
  }
  function success (shipmentData) {
    return { type: adminConstants.ADMIN_GET_SHIPMENT_SUCCESS, payload: shipmentData }
  }
  function failure (error) {
    return { type: adminConstants.ADMIN_GET_SHIPMENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getShipment(id).then(
      (data) => {
        dispatch(success(data))
        if (redirect) {
          dispatch(push(`/admin/shipments/view/${id}`))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getClients (redirect) {
  function request (clientData) {
    return { type: adminConstants.GET_CLIENTS_REQUEST, payload: clientData }
  }
  function success (clientData) {
    return { type: adminConstants.GET_CLIENTS_SUCCESS, payload: clientData }
  }
  function failure (error) {
    return { type: adminConstants.GET_CLIENTS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getClients().then(
      (data) => {
        if (redirect) {
          dispatch(push('/admin/clients'))
        }

        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getClient (id, redirect) {
  function request (clientData) {
    return { type: adminConstants.GET_CLIENT_REQUEST, payload: clientData }
  }
  function success (clientData) {
    return { type: adminConstants.GET_CLIENT_SUCCESS, payload: clientData }
  }
  function failure (error) {
    return { type: adminConstants.GET_CLIENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getClient(id).then(
      (data) => {
        if (redirect) {
          dispatch(push(`/admin/clients/${id}`))
        }

        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getVehicleTypes (itineraryId) {
  function request (vehicleData) {
    return { type: adminConstants.GET_VEHICLE_TYPES_REQUEST, payload: vehicleData }
  }
  function success (vehicleData) {
    return { type: adminConstants.GET_VEHICLE_TYPES_SUCCESS, payload: vehicleData }
  }
  function failure (error) {
    return { type: adminConstants.GET_VEHICLE_TYPES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getVehicleTypes(itineraryId).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getDashboard (redirect) {
  function request (showLoading) {
    return { type: adminConstants.GET_DASHBOARD_REQUEST, payload: showLoading }
  }
  function success (dashData) {
    return { type: adminConstants.GET_DASHBOARD_SUCCESS, payload: dashData }
  }
  function failure (error) {
    return { type: adminConstants.GET_DASHBOARD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(redirect))

    adminService.getDashboard().then(
      (data) => {
        if (redirect) {
          dispatch(push('/admin/dashboard'))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function editTruckingPrice (price) {
  function request (dashData) {
    return { type: adminConstants.EDIT_TRUCKING_PRICE_REQUEST, payload: dashData }
  }
  function success (dashData) {
    return { type: adminConstants.EDIT_TRUCKING_PRICE_SUCCESS, payload: dashData }
  }
  function failure (error) {
    return { type: adminConstants.EDIT_TRUCKING_PRICE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.editTruckingPrice(price).then(
      (data) => {
        dispatch(success(data.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function autoGenSchedules (data) {
  function request (schedData) {
    return { type: adminConstants.GENERATE_SCHEDULES_REQUEST, payload: schedData }
  }
  function success (schedData) {
    return { type: adminConstants.GENERATE_SCHEDULES_SUCCESS, payload: schedData }
  }
  function failure (error) {
    return { type: adminConstants.GENERATE_SCHEDULES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.autoGenSchedules(data).then(
      (schedData) => {
        dispatch(success(schedData))
        dispatch(documentActions.setStats(schedData.data.stats))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function confirmShipment (id, action, redirect) {
  function request () {
    return {
      type: adminConstants.CONFIRM_SHIPMENT_REQUEST,
      payload: { id, action }
    }
  }
  function successAccept (shipmentData) {
    return {
      type: adminConstants.CONFIRM_SHIPMENT_SUCCESS,
      payload: shipmentData
    }
  }
  function acceptAnimation (shipmentData) {
    return {
      type: adminConstants.ACCEPT_ANIMATION,
      payload: shipmentData.id
    }
  }
  function successFinished (shipmentData) {
    return {
      type: adminConstants.FINISHED_SHIPMENT_SUCCESS,
      payload: shipmentData
    }
  }
  function successDeny (shipmentData) {
    return {
      type: adminConstants.DENY_SHIPMENT_SUCCESS,
      payload: shipmentData
    }
  }
  function successRequested (shipmentData) {
    return {
      type: adminConstants.REQUESTED_SHIPMENT_SUCCESS,
      payload: shipmentData
    }
  }
  function successArchive (shipmentData) {
    return {
      type: adminConstants.ARCHIVE_SHIPMENT_SUCCESS,
      payload: shipmentData
    }
  }
  function failure (error) {
    return { type: adminConstants.CONFIRM_SHIPMENT_FAILURE, error, payload: { id } }
  }

  return (dispatch) => {
    dispatch(request())
    adminService.confirmShipment(id, action).then(
      (resp) => {
        const shipmentData = resp.data
        if (action === 'accept') {
          dispatch(acceptAnimation(shipmentData))
          setTimeout(() => {
            dispatch(successAccept(shipmentData))
          }, 5000)
        } else if (action === 'finished') {
          dispatch(successFinished(shipmentData))
        } else if (['decline', 'ignore'].includes(action)) {
          dispatch(successDeny(shipmentData))
        } else if (action === 'archive') {
          dispatch(successArchive(shipmentData))
        } else if (action === 'requested') {
          dispatch(successRequested(shipmentData))
        } else {
          dispatch(successArchive(shipmentData))
        }

        if (redirect) {
          dispatch(getShipment(id, true))
        }
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}
function getItineraries (redirect) {
  function request (routeData) {
    return { type: adminConstants.GET_ROUTES_REQUEST, payload: routeData }
  }
  function success (routeData) {
    return { type: adminConstants.GET_ROUTES_SUCCESS, payload: routeData }
  }
  function failure (error) {
    return { type: adminConstants.GET_ROUTES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getItineraries().then(
      (data) => {
        dispatch(success(data))
        if (redirect) {
          dispatch(push('/admin/routes'))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getLayovers (itineraryId, target) {
  function request (layovers) {
    return { type: adminConstants.GET_LAYOVERS_REQUEST, payload: layovers }
  }
  function success (layovers) {
    return { type: adminConstants.GET_LAYOVERS_SUCCESS, payload: { layovers, target } }
  }
  function failure (error) {
    return { type: adminConstants.GET_LAYOVERS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getLayovers(itineraryId).then(
      (data) => {
        dispatch(success(data.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function saveItineraryNotes (itineraryId, notes) {
  function request (itinerary) {
    return { type: adminConstants.SAVE_ITINERARY_NOTES_REQUEST, payload: itinerary }
  }
  function success (itinerary) {
    return { type: adminConstants.SAVE_ITINERARY_NOTES_SUCCESS, payload: itinerary }
  }
  function failure (error) {
    return { type: adminConstants.SAVE_ITINERARY_NOTES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    adminService.saveItineraryNotes(itineraryId, notes).then(
      (data) => {
        dispatch(success(data.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deleteItineraryNote (itineraryId, noteId) {
  function request (itinerary) {
    return { type: adminConstants.DELETE_ITINERARY_NOTES_REQUEST, payload: itinerary }
  }
  function success (itinerary) {
    return { type: adminConstants.DELETE_ITINERARY_NOTES_SUCCESS, payload: itinerary }
  }
  function failure (error) {
    return { type: adminConstants.DELETE_ITINERARY_NOTES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    adminService.deleteItineraryNote(itineraryId, noteId).then(
      (data) => {
        dispatch(success(data.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getItinerary (id, redirect) {
  function request (routeData) {
    return { type: adminConstants.GET_ROUTE_REQUEST, payload: routeData }
  }
  function success (routeData) {
    return { type: adminConstants.GET_ROUTE_SUCCESS, payload: routeData }
  }
  function failure (error) {
    return { type: adminConstants.GET_ROUTE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.getItinerary(id).then(
      (data) => {
        dispatch(success(data))
        if (redirect) {
          dispatch(push(`/admin/routes/${id}`))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function newRoute (data) {
  function request (routeData) {
    return { type: adminConstants.NEW_ROUTE_REQUEST, payload: routeData }
  }
  function success (routeData) {
    return { type: adminConstants.NEW_ROUTE_SUCCESS, payload: routeData.data }
  }
  function failure (error) {
    return { type: adminConstants.NEW_ROUTE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.newRoute(data).then(
      (newData) => {
        dispatch(success(newData))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function updateServiceCharge (id, req) {
  function request (prData) {
    return { type: adminConstants.UPDATE_SERVICE_CHARGES_REQUEST, payload: prData }
  }
  function success (prData) {
    // ;
    return { type: adminConstants.UPDATE_SERVICE_CHARGES_SUCCESS, payload: prData }
  }
  function failure (error) {
    return { type: adminConstants.UPDATE_SERVICE_CHARGES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.updateServiceCharge(id, req).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function newClient (data) {
  function request (newClientData) {
    return { type: adminConstants.NEW_CLIENT_REQUEST, payload: newClientData }
  }
  function success (newClientData) {
    return { type: adminConstants.NEW_CLIENT_SUCCESS, payload: newClientData.data }
  }
  function failure (error) {
    return { type: adminConstants.NEW_CLIENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.newClient(data).then(
      (newData) => {
        dispatch(success(newData))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function activateHub (hubId) {
  function request (newHubData) {
    return { type: adminConstants.ACTIVATE_HUB_REQUEST, payload: newHubData }
  }
  function success (newHubData) {
    return { type: adminConstants.ACTIVATE_HUB_SUCCESS, payload: newHubData.data }
  }
  function failure (error) {
    return { type: adminConstants.ACTIVATE_HUB_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.activateHub(hubId).then(
      (data) => {
        dispatch(getClients(false))
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deleteHub (hubId, redirect) {
  function request (delHubData) {
    return { type: adminConstants.DELETE_HUB_REQUEST, payload: delHubData }
  }
  function success (delHubData) {
    return { type: adminConstants.DELETE_HUB_SUCCESS, payload: delHubData.data }
  }
  function failure (error) {
    return { type: adminConstants.DELETE_HUB_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.deleteHub(hubId).then(
      (data) => {
        if (redirect) {
          dispatch(push(`/admin/hubs`))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deleteItinerary (id, redirect) {
  function request (deleted) {
    return { type: adminConstants.DELETE_ITINERARY_REQUEST, payload: deleted }
  }
  function success (deleted) {
    return { type: adminConstants.DELETE_ITINERARY_SUCCESS, payload: deleted.data }
  }
  function failure (error) {
    return { type: adminConstants.DELETE_ITINERARY_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.deleteItinerary(id).then(
      (data) => {
        if (redirect) {
          dispatch(push(`/admin/routes`))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deleteTrip (id, redirect) {
  function request (deleted) {
    return { type: adminConstants.DELETE_TRIP_REQUEST, payload: deleted }
  }
  function success (deleted) {
    return { type: adminConstants.DELETE_TRIP_SUCCESS, payload: id }
  }
  function failure (error) {
    return { type: adminConstants.DELETE_TRIP_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.deleteTrip(id).then(
      (data) => {
        if (redirect) {
          dispatch(push(`/admin/schedules`))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deleteClient (id, redirect) {
  function request (deleted) {
    return { type: adminConstants.DELETE_CLIENT_REQUEST, payload: deleted }
  }
  function success (deleted) {
    return { type: adminConstants.DELETE_CLIENT_SUCCESS, payload: id }
  }
  function failure (error) {
    return { type: adminConstants.DELETE_CLIENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.deleteClient(id).then(
      (data) => {
        if (redirect) {
          dispatch(push(`/admin/clients`))
        }
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function documentAction (docId, action) {
  function request (docData) {
    return { type: adminConstants.DOCUMENT_ACTION_REQUEST, payload: docData }
  }
  function success (docData) {
    return { type: adminConstants.DOCUMENT_ACTION_SUCCESS, payload: docData.data }
  }
  function failure (error) {
    return { type: adminConstants.DOCUMENT_ACTION_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.documentAction(docId, action).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function deleteDocument (docId) {
  function request (docData) {
    return { type: adminConstants.DOCUMENT_DELETE_REQUEST, payload: docData }
  }
  function success (docData) {
    return { type: adminConstants.DOCUMENT_DELETE_SUCCESS, payload: docData.data }
  }
  function failure (error) {
    return { type: adminConstants.DOCUMENT_DELETE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.deleteDocument(docId).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function saveNewHub (hub, address) {
  function request (hubData) {
    return { type: adminConstants.NEW_HUB_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.NEW_HUB_SUCCESS, payload: hubData.data }
  }
  function failure (error) {
    return { type: adminConstants.NEW_HUB_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.saveNewHub(hub, address).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function saveNewTrucking (obj) {
  function request (truckingData) {
    return { type: adminConstants.NEW_TRUCKING_REQUEST, payload: truckingData }
  }
  // function success (truckingData) {
  //   return { type: adminConstants.NEW_TRUCKING_SUCCESS, payload: truckingData.data }
  // }
  function failure (error) {
    return { type: adminConstants.NEW_TRUCKING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.saveNewTrucking(obj).then(
      (data) => {
        dispatch(viewTrucking(data.data.truckingHubId))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function editShipmentPrice (id, priceObj) {
  function request (shipmentData) {
    return { type: adminConstants.EDIT_SHIPMENT_PRICE_REQUEST, payload: shipmentData }
  }
  function success (shipmentData) {
    return { type: adminConstants.EDIT_SHIPMENT_PRICE_SUCCESS, payload: shipmentData.data }
  }
  function failure (error) {
    return { type: adminConstants.EDIT_SHIPMENT_PRICE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.editShipmentPrice(id, priceObj).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function editShipmentServicePrice (id, data) {
  function success (shipmentData) {
    return { type: adminConstants.EDIT_SHIPMENT_SERVICE_PRICE_SUCCESS, payload: shipmentData.data }
  }
  function failure (error) {
    return { type: adminConstants.EDIT_SHIPMENT_SERVICE_PRICE_FAILURE, error }
  }

  return (dispatch) => {
    adminService.editShipmentServicePrice(id, data).then(
      (res) => {
        dispatch(success(res))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function editLocalCharges (data) {
  function request (chargeData) {
    return { type: adminConstants.EDIT_LOCAL_CHARGES_REQUEST, payload: chargeData }
  }
  function success (chargeData) {
    return { type: adminConstants.EDIT_LOCAL_CHARGES_SUCCESS, payload: chargeData.data }
  }
  function failure (error) {
    return { type: adminConstants.EDIT_LOCAL_CHARGES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.editLocalCharges(data).then(
      (resp) => {
        dispatch(success(resp))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function editCustomsFees (data) {
  function request (chargeData) {
    return { type: adminConstants.EDIT_LOCAL_CHARGES_REQUEST, payload: chargeData }
  }
  function success (chargeData) {
    return { type: adminConstants.EDIT_LOCAL_CHARGES_SUCCESS, payload: chargeData.data }
  }
  function failure (error) {
    return { type: adminConstants.EDIT_LOCAL_CHARGES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.editLocalCharges(data).then(
      (resp) => {
        dispatch(success(resp))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function editShipmentTime (id, timeObj) {
  function request (truckingData) {
    return { type: adminConstants.EDIT_SHIPMENT_TIME_REQUEST, payload: truckingData }
  }
  function success (truckingData) {
    return { type: adminConstants.EDIT_SHIPMENT_TIME_SUCCESS, payload: truckingData.data }
  }
  function failure (error) {
    return { type: adminConstants.EDIT_SHIPMENT_TIME_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.editShipmentTime(id, timeObj).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function assignManager (obj) {
  function request (managerData) {
    return { type: adminConstants.ASSIGN_MANAGER_REQUEST, payload: managerData }
  }
  function success (managerData) {
    return { type: adminConstants.ASSIGN_MANAGER_SUCCESS, payload: managerData.data }
  }
  function failure (error) {
    return { type: adminConstants.ASSIGN_MANAGER_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.assignManager(obj).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function viewTrucking (truckingHub) {
  function request (truckingData) {
    return { type: adminConstants.VIEW_TRUCKING_REQUEST, payload: truckingData }
  }
  function success (truckingData) {
    return { type: adminConstants.VIEW_TRUCKING_SUCCESS, payload: truckingData.data }
  }
  function failure (error) {
    return { type: adminConstants.VIEW_TRUCKING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.viewTrucking(truckingHub).then(
      (data) => {
        dispatch(success(data))
        dispatch(push(`/admin/pricings/trucking/${truckingHub}`))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function loadItinerarySchedules (id, redirect) {
  function request (truckingData) {
    return { type: adminConstants.LOAD_ITINERARY_SCHEDULES_REQUEST, payload: truckingData }
  }
  function success (truckingData) {
    return { type: adminConstants.LOAD_ITINERARY_SCHEDULES_SUCCESS, payload: truckingData.data }
  }
  function failure (error) {
    return { type: adminConstants.LOAD_ITINERARY_SCHEDULES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    adminService.loadItinerarySchedules(id).then(
      (data) => {
        dispatch(success(data))
        if (redirect) {
          dispatch(push(`/admin/schedules/${id}`))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function uploadTrucking (url, file, direction) {
  function request (truckingData) {
    return { type: adminConstants.UPLOAD_TRUCKING_REQUEST, payload: truckingData }
  }
  function success (truckingData) {
    return { type: adminConstants.UPLOAD_TRUCKING_SUCCESS, payload: truckingData.data }
  }
  function failure (error) {
    return { type: adminConstants.UPLOAD_TRUCKING_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.uploadTrucking(url, file, direction).then(
      (data) => {
        dispatch(documentActions.setStats(data.data))
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function newHubImage (id, file) {
  function request (hubData) {
    return { type: adminConstants.UPLOAD_HUB_IMAGE_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.UPLOAD_HUB_IMAGE_SUCCESS, payload: hubData.data }
  }
  function failure (error) {
    return { type: adminConstants.UPLOAD_HUB_IMAGE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.newHubImage(id, file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function updateHubMandatoryCharges (id, charges) {
  function request (hubData) {
    return { type: adminConstants.UPDATE_MANDATORY_CHARGE_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: adminConstants.UPDATE_MANDATORY_CHARGE_SUCCESS, payload: hubData.data }
  }
  function failure (error) {
    return { type: adminConstants.UPDATE_MANDATORY_CHARGE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.updateHubMandatoryCharges(id, charges).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function uploadDocument (doc, type, url) {
  function request (file) {
    return { type: adminConstants.ADMIN_UPLOAD_DOCUMENT_REQUEST, payload: file }
  }
  function success (file) {
    return { type: adminConstants.ADMIN_UPLOAD_DOCUMENT_SUCCESS, payload: file.data }
  }
  function failure (error) {
    return { type: adminConstants.ADMIN_UPLOAD_DOCUMENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    adminService.uploadDocument(doc, type, url).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function clearLoading () {
  return { type: adminConstants.CLEAR_LOADING, payload: null }
}

function logOut () {
  return { type: adminConstants.ADMIN_LOG_OUT, payload: null }
}

function goTo (path) {
  return (dispatch) => {
    dispatch(push(path))
  }
}

export const adminActions = {
  getHubs,
  newHubImage,
  uploadDocument,
  getItineraries,
  updateServiceCharge,
  updatePricing,
  deleteItinerary,
  getClientPricings,
  getItinerary,
  deleteHub,
  getServiceCharges,
  getPricings,
  getTrucking,
  getClient,
  getShipment,
  documentAction,
  getSchedules,
  getDashboard,
  goTo,
  uploadTrucking,
  autoGenSchedules,
  getVehicleTypes,
  getShipments,
  getClients,
  confirmShipment,
  getHub,
  getItineraryPricings,
  wizardHubs,
  wizardSCharge,
  wizardPricings,
  wizardOpenPricings,
  wizardTrucking,
  viewTrucking,
  newClient,
  activateHub,
  saveNewHub,
  getDashShipments,
  newRoute,
  clearLoading,
  logOut,
  getLayovers,
  saveNewTrucking,
  assignManager,
  editShipmentPrice,
  editShipmentServicePrice,
  editShipmentTime,
  editLocalCharges,
  deletePricing,
  editHub,
  loadItinerarySchedules,
  deleteTrip,
  deleteClient,
  saveItineraryNotes,
  deleteItineraryNote,
  editTruckingPrice,
  editCustomsFees,
  updateHubMandatoryCharges,
  assignDedicatedPricings,
  searchHubs,
  getAllHubs,
  getPricingsTest,
  searchShipments,
  deltaShipmentsPage,
  deleteDocument,
  searchPricings
}

export default adminActions
