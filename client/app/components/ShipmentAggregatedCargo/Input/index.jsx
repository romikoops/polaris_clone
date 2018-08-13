import React from 'react'
import PropTypes from '../../../prop-types'
import { ValidatedInput } from '../../ValidatedInput/ValidatedInput'

export default function ShipmentAggregatedCargoInput ({
  value, name, handleDelta, nextStageAttempt, maxValue
}) {
  return (
    <ValidatedInput
      wrapperClassName="flex"
      name={name}
      value={value}
      type="number"
      min="0"
      step="any"
      onChange={handleDelta}
      nextStageAttempt={nextStageAttempt}
      firstRenderInputs
      errorStyles={{
        fontSize: '10px',
        bottom: '-14px'
      }}
      validations={{
        nonNegative: (values, _value) => _value > 0,
        maxValue: (values, _value) => _value < maxValue
      }}
      validationErrors={{
        isDefaultRequiredValue: 'Must be greater than 0',
        nonNegative: 'Must be greater than 0',
        maxValue: `Must be less than ${maxValue}`
      }}
      required
    />
  )
}

ShipmentAggregatedCargoInput.propTypes = {
  value: PropTypes.number,
  name: PropTypes.string,
  handleDelta: PropTypes.func.isRequired,
  nextStageAttempt: PropTypes.bool,
  maxValue: PropTypes.number.isRequired
}

ShipmentAggregatedCargoInput.defaultProps = {
  value: 0,
  name: '',
  nextStageAttempt: false
}
