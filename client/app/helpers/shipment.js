import { shipmentConstants, moment } from "../constants";

export function totalPrice (shipment) {
  const selectedOffer = shipment.selected_offer

  if (!selectedOffer) {
    return shipment.edited_total || shipment.total_price || {}
  }

  return selectedOffer.edited_total || selectedOffer.total || {}
}

export function totalPriceString (shipment) {
  const { currency, value } = totalPrice(shipment)

  return `${currency} ${(+value).toFixed(2)}`
}

export function formattedDate (date) {
  const e = moment(date)
  
  return e.format('DD/MM/YYYY | HH:mm')
}

export function formattedPriceValue (num) {
  return num ? (+num).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, '\u00a0') : '0.00'
}

export function checkPreCarriage (shipment, action) {
  if (shipment.has_pre_carriage && action === 'Pick-up') {
    return {
      type: action,
      date: shipment.planned_pickup_date
    }
  }

  return {
    type: action,
    date: shipment.planned_origin_drop_off_date
  }
}

export function checkOnCarriage (shipment, action) {
  if (shipmentConstants.has_on_carriage && action === 'Delivery') {
    return {
      type: action,
      date: shipment.planned_delivery_date
    }
  }

  return {
    type: action,
    date: shipment.planned_destination_collection_date
  }
}
export function isRequested (status) {
  return ['requested', 'requested_by_unconfirmed_account'].includes(status)
}
