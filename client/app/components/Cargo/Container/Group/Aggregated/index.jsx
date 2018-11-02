import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../CargoContainerGroup.scss'
import PropTypes from '../../../../../prop-types'

function CargoContainerGroupAggregated ({ group, t }) {
  return (
    <div className={
      `${styles.panel} ${styles.open_panel} flex-100 ` +
      'layout-row layout-wrap layout-align-start-center'
    }
    >
      <div className={
        `${styles.detailed_row_aggregated} flex-100 ` +
        'layout-row layout-wrap layout-align-none-center'
      }
      >
        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center"><span className={styles.cargo_type}>{group.payload_in_kg || group.weight}</span> &nbsp;kg </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:cargoGrossWeight')}</p>
          </div>
        </div>

        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>
                {(+group.gross_weight)}
              </span> &nbsp;kg</p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:grossWeight')}</p>
          </div>
        </div>
        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>
                {+(group.tare_weight).toFixed(3)}
              </span>
              &nbsp;kg
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('cargo:tareWeight')}</p>
          </div>
        </div>
      </div>
    </div>
  )
}

CargoContainerGroupAggregated.propTypes = {
  group: PropTypes.objectOf(PropTypes.any),
  t: PropTypes.func.isRequired
}

CargoContainerGroupAggregated.defaultProps = {
  group: {}
}

export default withNamespaces(['cargo', 'common'])(CargoContainerGroupAggregated)
