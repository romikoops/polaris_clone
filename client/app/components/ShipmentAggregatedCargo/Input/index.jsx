import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../prop-types'
import ValidatedInput from '../../ValidatedInput/ValidatedInput'

function ShipmentAggregatedCargoInput ({
  value, name, handleDelta, nextStageAttempt, maxValue, t
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
        isDefaultRequiredValue: t('common:greaterZero'),
        nonNegative: t('common:greaterZero'),
        maxValue: `${t('errors:maxValue')} ${maxValue}`
      }}
      required
    />
  )
}

ShipmentAggregatedCargoInput.propTypes = {
  value: PropTypes.number,
  t: PropTypes.func.isRequired,
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

export default withNamespaces(['common', 'errors'])(ShipmentAggregatedCargoInput)
