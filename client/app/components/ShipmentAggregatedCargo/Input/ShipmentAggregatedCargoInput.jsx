import React from 'react'
import PropTypes from '../../../prop-types'
import { ValidatedInput } from '../../ValidatedInput/ValidatedInput'

function ShipmentAggregatedCargoInput ({
  value, name, handleDelta, nextStageAttempt
}) {
  return (
    <ValidatedInput
      wrapperClassName="flex-55"
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
        nonNegative: (values, _value) => _value > 0
      }}
      validationErrors={{
        isDefaultRequiredValue: 'Must be greater than 0',
        nonNegative: 'Must be greater than 0'
      }}
      required
    />
  )
}

ShipmentAggregatedCargoInput.propTypes = {
  value: PropTypes.number,
  name: PropTypes.string,
  handleDelta: PropTypes.func,
  nextStageAttempt: PropTypes.bool
}

ShipmentAggregatedCargoInput.defaultProps = {
  value: 0,
  name: '',
  handleDelta: null,
  nextStageAttempt: false
}
