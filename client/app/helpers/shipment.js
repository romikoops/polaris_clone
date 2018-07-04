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
  return num ? (+num).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ' ') : '0.00'
}
