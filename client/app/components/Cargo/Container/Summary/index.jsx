import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../../Item/Group/CargoItemGroup.scss'
import { numberSpacing } from '../../../../helpers'

function CargoContainerSummary ({ items, t }) {
  const weight = items.reduce((product, item) => (
    product + (parseFloat(item.payload_in_kg) * parseInt(item.quantity, 10))
  ), 0)
  const tareWeight = items.reduce((product, item) => (
    product + (parseFloat(item.tare_weight) * parseInt(item.quantity, 10))
  ), 0)
  const quantity = items.reduce((product, item) => (
    product + parseInt(item.quantity, 10)
  ), 0)

  return (
    <div className={
      `${styles.panel} ${styles.open_panel} flex-100 ` +
      'layout-row layout-wrap layout-align-start-center'
    }
    >
      <div className={`flex-100 layout-row layout-align-start-center ${styles.summary_header}`}>
        <p className="flex-none">{t('cargo:cargoSummary')}</p>
      </div>
      <div className={
        `${styles.detailed_row_aggregated} flex-100 ` +
        'layout-row layout-wrap layout-align-none-center'
      }
      >
        <div className="flex layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>{quantity}</span>
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalQuantity')}</p>
          </div>
        </div>
        <div className="flex layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>{numberSpacing(weight, 2)}</span>
              {' '}
              &nbsp;kg
              {' '}
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalPayloadWeight')}</p>
          </div>
        </div>
        <div className="flex layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>
                { numberSpacing(tareWeight + weight, 2) }
              </span>
            &nbsp;kg
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalGrossWeight')}</p>
          </div>
        </div>
      </div>
    </div>
  )
}

CargoContainerSummary.defaultProps = {
  group: {}
}

export default withNamespaces('cargo')(CargoContainerSummary)
