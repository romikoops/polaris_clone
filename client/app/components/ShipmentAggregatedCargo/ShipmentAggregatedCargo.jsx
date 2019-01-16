import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './ShipmentAggregatedCargo.scss'
import ShipmentAggregatedCargoInput from './Input'
import { calcMaxDimensionsToApply } from '../../helpers'

function ShipmentAggregatedCargo ({
  theme, aggregatedCargo, handleDelta, nextStageAttempt, maxDimensions, availableMotsForRoute, t
}) {
  const sharedProps = { handleDelta, nextStageAttempt }

  const maxDimensionsToApply = calcMaxDimensionsToApply(availableMotsForRoute, maxDimensions)

  return (
    <div
      className="layout-row layout-wrap layout-align-center content_width_booking"
      style={{ padding: '30px 0 70px 0' }}
    >
      <div className={`${styles.input_box} flex-45 flex-sm-70 layout-row`}>
        <div className="flex-25 layout-row layout-align-center-center">
          {t('cargo:totalVolume')}
        </div>
        <ShipmentAggregatedCargoInput
          value={aggregatedCargo.volume}
          name="volume"
          maxValue={+maxDimensionsToApply.volume || 35}
          {...sharedProps}
        />
        <div className="flex-10 layout-row layout-align-center-center">
          {t('acronym:meterCubed')}
        </div>
      </div>
      <div className={`${styles.input_box} flex-45 flex-sm-70 offset-gt-md-10 layout-row`}>
        <div className="flex-25 layout-row layout-align-center-center">
          {t('cargo:totalWeight')}
        </div>
        <ShipmentAggregatedCargoInput
          value={aggregatedCargo.weight}
          name="weight"
          maxValue={+maxDimensionsToApply.payloadInKg || 35000}
          {...sharedProps}
        />
        <div className="flex-10 layout-row layout-align-center-center">
          {t('acronym:kg')}
        </div>
      </div>
    </div>
  )
}

ShipmentAggregatedCargo.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  aggregatedCargo: PropTypes.shape({
    volume: PropTypes.number,
    weight: PropTypes.number
  }),
  handleDelta: PropTypes.func.isRequired,
  nextStageAttempt: PropTypes.bool,
  availableMotsForRoute: PropTypes.bool.isRequired,
  maxDimensions: PropTypes.objectOf(PropTypes.objectOf(PropTypes.string)).isRequired
}

ShipmentAggregatedCargo.defaultProps = {
  theme: null,
  aggregatedCargo: {
    volume: 0,
    weight: 0
  },
  nextStageAttempt: false
}

export default withNamespaces(['cargo', 'acronym'])(ShipmentAggregatedCargo)
