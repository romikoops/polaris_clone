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

  return e.format('DD/MM/YYYY')
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

export function cargoPlurals (shipment, t) {
  const { cargo_count, load_type } = shipment
  let noun = ''
  if (load_type === 'cargo_item' && cargo_count > 1) {
    noun = `${t('cargo:cargoItems')}`
  } else if (load_type === 'cargo_item' && cargo_count === 1) {
    noun = `${t('cargo:cargoItem')}`
  } else if (load_type === 'container' && cargo_count > 1) {
    noun = `${t('cargo:containers')}`
  } else if (load_type === 'container' && cargo_count === 1) {
    noun = `${t('cargo:container')}`
  }

  return `${noun}`
}

export function loadOriginNexus (nexuses) {
  const origin = nexuses.origin_nexuses.map(nexus => ({
    label: nexus.name,
    value: nexus.id
  }))

  return origin
}
export function loadDestinationNexus (nexuses) {
  const destination = nexuses.destination_nexuses.map(nexus => ({
    label: nexus.name,
    value: nexus.id
  }))

  return destination
}
export function loadClients (clients) {
  const clientArr = clients.map(client => ({
    label: `${client.first_name} ${client.last_name}`,
    value: client.id
  }))
  return clientArr
}

export function loadMot () {
  const mots = ['Ocean', 'Air', 'Rail']

  const loadMot = mots.map(mot => ({
    label: mot,
    value: mot.toLowerCase()
  }))

  return loadMot
}