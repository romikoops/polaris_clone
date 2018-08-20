export function totalPrice (shipment) {
  const selectedOffer = shipment.selected_offer

  if (!selectedOffer) return {}

  return selectedOffer.edited_total || selectedOffer.total || {}
}

export function totalPriceString (shipment) {
  const { currency, value } = totalPrice(shipment)

  return `${currency} ${(+value).toFixed(2)}`
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
