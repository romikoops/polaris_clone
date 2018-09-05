import React from 'react'
import { translate } from 'react-i18next'
import styles from '../CargoContainerGroup.scss'
import PropTypes from '../../../../../prop-types'
import { trim, WRAP_ROW, ALIGN_CENTER, ROW } from '../../../../../classNames'

const CONTAINER = trim(`
  AGGREGATED
  ${styles.panel} 
  ${styles.open_panel} 
  ${WRAP_ROW(100)}
  layout-align-start-center
`)
const THIRD_OF_ROW = 'flex-33 layout-row layout-align-space-around'
const CENTERED_ROW = 'flex-none layout-row layout-align-center-center'

export function CargoContainerGroupAggregated ({ group, t }) {
  const cargoType = group.payload_in_kg || group.weight

  return (
    <div className={CONTAINER}>
      <div className={trim(`
        ${styles.detailed_row_aggregated}
        ${WRAP_ROW(100)}
        layout-align-none-center
      `)}
      >
        <div className={THIRD_OF_ROW}>
          <div className="layout-column">
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>
              <span className={styles.cargo_type}>{cargoType}</span> &nbsp;kg </p>
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>
              {t('cargo:cargoGrossWeight')}
            </p>
          </div>
        </div>

        <div className={THIRD_OF_ROW}>
          <div className="layout-column">
            <p className={CENTERED_ROW}>
              <span className={styles.cargo_type}>
                {(+group.gross_weight)}
              </span> &nbsp;kg</p>
            <p className={CENTERED_ROW}>
              {t('cargo:grossWeight')}
            </p>
          </div>
        </div>

        <div className={THIRD_OF_ROW}>
          <div className="layout-column">
            <p className={CENTERED_ROW}>
              <span className={styles.cargo_type}>
                {+(group.tare_weight).toFixed(3)}
              </span>
              &nbsp;kg
            </p>
            <p className={CENTERED_ROW}>
              {t('cargo:tareWeight')}
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

CargoContainerGroupAggregated.propTypes = {
  t: PropTypes.func.isRequired,
  group: PropTypes.objectOf(PropTypes.any)
}

CargoContainerGroupAggregated.defaultProps = {
  group: {}
}

export default translate('cargo')(CargoContainerGroupAggregated)
