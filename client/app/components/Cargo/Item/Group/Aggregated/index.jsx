import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../CargoItemGroup.scss'
import { numberSpacing } from '../../../../../helpers'

function CargoItemGroupAggregated ({ group, t, hideUnits }) {
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
              <span className={styles.cargo_type}>{numberSpacing(group.payload_in_kg || group.weight, 2)}</span>
              {' '}
              &nbsp;kg
              {' '}
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalGrossWeight')}</p>
          </div>
        </div>

        <div className="flex layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>
                {numberSpacing(+group.volume, 3)}
              </span>
              {' '}
              &nbsp;m
              <sup>3</sup>
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalVolume')}</p>
          </div>
        </div>
        { hideUnits ? '' : (
          <div className="flex layout-row layout-align-space-around">
            <div className="layout-column">
              <p className="flex-none layout-row layout-align-center-center">
                <span className={styles.cargo_type}>
                  { numberSpacing(group.chargeable_weight, 2) }
                </span>
              &nbsp;kg
              </p>
              <p className="flex-none layout-row layout-align-center-center">{t('cargo:totalChargeableWeight')}</p>
            </div>
          </div>
        ) }
      </div>
    </div>
  )
}

CargoItemGroupAggregated.defaultProps = {
  group: {}
}

export default withNamespaces('common')(CargoItemGroupAggregated)
