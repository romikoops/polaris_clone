import { camelizeKeys } from './objectTools'

function reuseCargoItems (cargoItems) {
  return cargoItems.map(ci => (
    {
      payload_in_kg: ci.payload_in_kg,
      height: ci.height,
      width: ci.width,
      length: ci.length,
      dangerous_goods: ci.dangerous_goods,
      cargo_item_type_id: ci.cargo_item_type_id,
      cargo_class: ci.cargo_class,
      stackable: ci.stackable,
      quantity: ci.quantity
    }
  ))
}
function reuseContainers (containers) {
  return containers.map(ci => (
    {
      payload_in_kg: ci.payload_in_kg,
      gross_weight: ci.gross_weight,
      size_class: ci.size_class,
      length: ci.length,
      dangerous_goods: ci.dangerous_goods,
      cargo_class: ci.cargo_class,
      quantity: ci.quantity
    }
  ))
}
function reuseLocation (shipment, target) {
  const resp = {
    nexusIds: [shipment[`${target}_nexus_id`]]
  }
  let address = {}
  if (shipment.has_pre_carriage && target === 'origin') {
    address = {
      number: shipment.pickup_address.street_number,
      street: shipment.pickup_address.street,
      city: shipment.pickup_address.city,
      country: shipment.pickup_address.country.name,
      zipCode: shipment.pickup_address.zip_code,
      latitude: shipment.pickup_address.latitude,
      longitude: shipment.pickup_address.longitude,
      fullAddress: shipment.pickup_address.geocoded_address
    }
  } else if (shipment.has_on_carriage && target === 'destination') {
    address = {
      number: shipment.delivery_address.street_number,
      street: shipment.delivery_address.street,
      city: shipment.delivery_address.city,
      country: shipment.delivery_address.country.name,
      zipCode: shipment.delivery_address.zip_code,
      latitude: shipment.delivery_address.latitude,
      longitude: shipment.delivery_address.longitude,
      fullAddress: shipment.delivery_address.geocoded_address
    }
  }

  return {
    ...address,
    ...resp
  }
}

function reuseContacts (contacts) {
  const oldConsignee = contacts.filter(oc => oc.type === 'consignee')[0]
  const oldShipper = contacts.filter(oc => oc.type === 'shipper')[0]
  const oldNotifyees = contacts.filter(oc => oc.type === 'notifyee')

  const resp = {
    consignee: {
      contact: camelizeKeys(oldConsignee.contact),
      address: camelizeKeys(oldConsignee.address)
    },
    shipper: {
      contact: camelizeKeys(oldShipper.contact),
      address: camelizeKeys(oldShipper.address)
    },
    notifyees: oldNotifyees.length > 0 ? oldNotifyees.map(n => ({
      contact: camelizeKeys(n.contact),
      address: camelizeKeys(n.address)
    })) : []
  }

  return resp
}
const reuseShipments = {
  reuseCargoItems,
  reuseContainers,
  reuseLocation,
  reuseContacts

}
export default reuseShipments
