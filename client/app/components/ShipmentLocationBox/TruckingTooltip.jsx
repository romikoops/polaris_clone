import React from 'react'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../prop-types'
import styles from './ShipmentLocationBox.scss'
import { capitalizeAndDashifyCamelCase } from '../../helpers'

export default function TruckingTooltip ({
  truckingOptions, mandatoryTrucking, carriage, hubName, direction
}) {
  if (truckingOptions[carriage] && !mandatoryTrucking[carriage]) return ''
  let dataTip
  const carriageText = capitalizeAndDashifyCamelCase(carriage)
  if (!truckingOptions[carriage]) {
    dataTip = `${carriageText} is not available in ${hubName}`
  } else if (mandatoryTrucking[carriage]) {
    dataTip = `${carriageText} is mandatory for ${direction}`
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
  mandatoryTrucking: PropTypes.objectOf(PropTypes.bool).isRequired,
  carriage: PropTypes.string.isRequired,
  hubName: PropTypes.string,
  direction: PropTypes.string
}

TruckingTooltip.defaultProps = {
  hubName: '',
  direction: ''
}
