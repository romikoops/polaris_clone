import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../CargoItemGroup.scss'
import PropTypes from '../../../../../prop-types'
import { numberSpacing } from '../../../../../helpers'

function CargoItemGroupAggregated ({ group, t }) {
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
            <p className="flex-none layout-row layout-align-center-center">{t('common:grossWeight')}</p>
          </div>
        </div>

        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>
                {numberSpacing(+group.volume, 3)}
              </span> &nbsp;m<sup>3</sup>
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:volume')}</p>
          </div>
        </div>
        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>
                {!group.size_class ? numberSpacing(group.chargeable_weight, 2) : ''}
              </span>
              &nbsp;kg
            </p>
            <p className="flex-none layout-row layout-align-center-center">{t('common:chargeableWeight')}</p>
          </div>
        </div>
      </div>
    </div>
  )
}

CargoItemGroupAggregated.propTypes = {
  group: PropTypes.objectOf(PropTypes.any),
  t: PropTypes.func.isRequired
}

CargoItemGroupAggregated.defaultProps = {
  group: {}
}

export default withNamespaces('common')(CargoItemGroupAggregated)
