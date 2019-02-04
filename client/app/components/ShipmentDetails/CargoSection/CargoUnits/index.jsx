import React from 'react'
import uuid from 'uuid'
import CargoItem from './CargoItem'
import CargoItemAggregated from './CargoItemAggregated'
import Container from './Container'

function CargoUnits ({
  aggregatedCargo,
  cargoUnits,
  loadType,
  scope,
  ...sharedProps
}) {
  if (loadType === 'cargo_item' && !aggregatedCargo) {
    return cargoUnits.map((cargoItem, i) => (
      <CargoItem
        cargoItem={cargoItem}
        uniqKey={uuid.v4()}
        i={i}
        scope={scope}
        {...sharedProps}
      />
    ))
  }
  if (loadType === 'cargo_item' && aggregatedCargo && cargoUnits.length > 0) {
    return (
      <CargoItemAggregated cargoItem={cargoUnits[0]} {...sharedProps} />
    )
  }

  if (loadType === 'container') {
    return cargoUnits.map((container, i) => (
      <Container
        container={container}
        i={i}
        scope={scope}
        {...sharedProps}
      />
    ))
  }

  return ''
}

export default CargoUnits
