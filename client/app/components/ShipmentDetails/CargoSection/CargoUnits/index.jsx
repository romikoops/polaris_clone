import React from 'react'
import uuid from 'uuid'
import CargoItem from './CargoItem'
import CargoItemAggregated from './CargoItemAggregated'
import Container from './Container'

function CargoUnits ({
  aggregateSection,
  cargoUnits,
  loadType,
  scope,
  onDeleteUnit,
  ...otherProps
}) {
  const sharedProps = {
    onDeleteUnit: cargoUnits.length > 1 && onDeleteUnit,
    scope,
    ...otherProps
  }

  if (loadType === 'cargo_item' && !aggregateSection) {
    return cargoUnits.map((cargoItem, i) => (
      <CargoItem
        cargoItem={cargoItem}
        uniqKey={uuid.v4()}
        i={i}
        {...sharedProps}
      />
    ))
  }
  if (loadType === 'cargo_item' && aggregateSection && cargoUnits.length > 0) {
    return (
      <CargoItemAggregated cargoItem={cargoUnits[0]} {...sharedProps} />
    )
  }

  if (loadType === 'container') {
    return cargoUnits.map((container, i) => (
      <Container
        container={container}
        i={i}
        {...sharedProps}
      />
    ))
  }

  return ''
}

export default CargoUnits
