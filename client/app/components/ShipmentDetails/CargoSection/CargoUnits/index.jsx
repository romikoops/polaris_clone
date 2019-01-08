import React from 'react'
import CargoItem from './CargoItem'
import Container from './Container'

function CargoUnits ({ cargoUnits, loadType, ...sharedProps }) {
  if (loadType === 'cargo_item') {
    return cargoUnits.map((cargoItem, i) => (
      <CargoItem cargoItem={cargoItem} {...sharedProps} />
    ))
  }

  if (loadType === 'container') {
    return cargoUnits.map((container, i) => (
      <Container container={container} {...sharedProps} />
    ))
  }

  return ''
}

export default CargoUnits
