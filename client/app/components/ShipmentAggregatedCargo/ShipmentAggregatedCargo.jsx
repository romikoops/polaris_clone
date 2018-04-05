import React from 'react'
import PropTypes from '../../prop-types'
import ShipmentAggregatedCargoInput from '../ValidatedInput/ValidatedInput'

function ShipmentAggregatedCargo ({
  theme, aggregatedCargo, handleDelta, nextStageAttempt
}) {
  const sharedProps = { handleDelta, nextStageAttempt }
  return (
    <ShipmentAggregatedCargoInput
      value={aggregatedCargo.volume}
      name="volume"
      {...sharedProps}
    />
  )
}

ShipmentAggregatedCargo.propTypes = {
  theme: PropTypes.theme,
  aggregatedCargo: PropTypes.shape({
    volume: PropTypes.number,
    weight: PropTypes.number
  }),
  handleDelta: PropTypes.func,
  nextStageAttempt: PropTypes.bool
}

ShipmentAggregatedCargo.defaultProps = {
  theme: null,
  aggregatedCargo: {
    volume: 0,
    weight: 0
  },
  handleDelta: null,
  nextStageAttempt: false
}
