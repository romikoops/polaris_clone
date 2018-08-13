import React from 'react'
import PropTypes from '../../prop-types'
import styles from './ShipmentAggregatedCargo.scss'
import ShipmentAggregatedCargoInput from './Input'

export default function ShipmentAggregatedCargo ({
  theme, aggregatedCargo, handleDelta, nextStageAttempt
}) {
  const sharedProps = { handleDelta, nextStageAttempt }

  return (
    <div
      className="layout-row layout-wrap layout-align-center content_width_booking"
      style={{ padding: '30px 0 70px 0' }}
    >
      <div className={`${styles.input_box} flex-45 layout-row`}>
        <div className="flex-25 layout-row layout-align-center-center">
          Total Volume
        </div>
        <ShipmentAggregatedCargoInput
          value={aggregatedCargo.volume}
          name="volume"
          maxValue={15}
          {...sharedProps}
        />
        <div className="flex-10 layout-row layout-align-center-center">
          m³
        </div>
      </div>
      <div className={`${styles.input_box} flex-45 offset-10 layout-row`}>
        <div className="flex-25 layout-row layout-align-center-center">
          Total Weight
        </div>
        <ShipmentAggregatedCargoInput
          value={aggregatedCargo.weight}
          name="weight"
          maxValue={35000}
          {...sharedProps}
        />
        <div className="flex-10 layout-row layout-align-center-center">
          Kg
        </div>
      </div>
    </div>
  )
}

ShipmentAggregatedCargo.propTypes = {
  theme: PropTypes.theme,
  aggregatedCargo: PropTypes.shape({
    volume: PropTypes.number,
    weight: PropTypes.number
  }),
  handleDelta: PropTypes.func.isRequired,
  nextStageAttempt: PropTypes.bool
  // stackeableGoodsConfirmed: PropTypes.bool
}

ShipmentAggregatedCargo.defaultProps = {
  theme: null,
  aggregatedCargo: {
    volume: 0,
    weight: 0
  },
  nextStageAttempt: false
  // stackeableGoodsConfirmed: false
}
