import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import CargoUnitNumberInput from '../CargoUnit/NumberInput'
import calcMaxDimensionsToApply from '../../../../../helpers/calcMaxDimensionsToApply'

function CargoItemAggregated ({
  cargoItem, t, ShipmentDetails, maxDimensions, toggleModal, onChangeCargoUnitInput
}) {
  const maxDimensionsToApply = calcMaxDimensionsToApply(
    ShipmentDetails.availableMots,
    maxDimensions
  )
  // TODO Max dimensions
  const getMaxDimension = prop => Number(
    maxDimensionsToApply[prop]
  )
  const getSharedProps = prop => ({
    cargoItem,
    className: 'flex-100',
    unit: '',
    i: 0,
    name: `0-${prop}`,
    onChange: onChangeCargoUnitInput,
    onExcessDimensionsRequest: () => toggleModal('maxDimensions'),
    value: cargoItem[prop]
  })

  return (
    <div>
      <div style={{ position: 'relative' }}>
        <div
          className="layout-row layout-wrap layout-align-center content_width_booking"
          style={{ padding: '30px 0 70px 0' }}
        >
          <div className={`${styles.input_box} flex-45 layout-row`}>
            <div className="flex-45 layout-row layout-align-center-center">
              {t('cargo:totalVolume')}
            </div>
            <CargoUnitNumberInput
              maxDimensionsErrorText={t('errors:maxVolume')}
              {...getSharedProps('totalVolume')}
            />
            <div className="flex-10 layout-row layout-align-center-center">
              {t('acronym:meterCubed')}
            </div>
          </div>

          <div className={`${styles.input_box} flex-45 offset-10 layout-row`}>
            <div className="flex-45 layout-row layout-align-center-center">
              {t('cargo:totalWeight')}
            </div>
            <CargoUnitNumberInput
              maxDimensionsErrorText={t('errors:maxWeight')}
              {...getSharedProps('totalWeight')}
            />
            <div className="flex-10 layout-row layout-align-center-center">
              {t('acronym:kg')}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default withNamespaces(['common', 'errors'])(CargoItemAggregated)
