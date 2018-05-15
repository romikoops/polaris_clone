import React from 'react'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../prop-types'
import styles from './ShipmentLocationBox.scss'
import { capitalizeAndDashifyCamelCase } from '../../helpers'

function showTootip (truckingOption, directionConstraint, hubName) {
  return (!truckingOption || ['mandatory', 'disabled'].includes(directionConstraint)) && hubName
}

export default function TruckingTooltip ({
  truckingOptions, carriage, hubName, direction, scope
}) {
  const directionConstraints = {
    onCarriage: scope.carriage_options.on_carriage[direction],
    preCarriage: scope.carriage_options.pre_carriage[direction]
  }

  if (!showTootip(truckingOptions[carriage], directionConstraints[carriage], hubName)) return ''

  let dataTip
  const carriageText = capitalizeAndDashifyCamelCase(carriage)
  if (!truckingOptions[carriage]) {
    dataTip = `${carriageText} is not available in ${hubName}`
  } else if (directionConstraints[carriage] === 'mandatory') {
    dataTip = `${carriageText} is mandatory for ${direction}`
  } else if (directionConstraints[carriage] === 'disabled') {
    dataTip = `${carriageText} is not offered for ${direction}`
  }

  return (
    <div>
      <ReactTooltip effect="solid" />
      <div
        className={styles.toggle_box_overlay}
        data-tip={dataTip}
      />
    </div>
  )
}

TruckingTooltip.propTypes = {
  truckingOptions: PropTypes.objectOf(PropTypes.bool).isRequired,
  scope: PropTypes.scope.isRequired,
  carriage: PropTypes.string.isRequired,
  hubName: PropTypes.string,
  direction: PropTypes.string
}

TruckingTooltip.defaultProps = {
  hubName: '',
  direction: ''
}
