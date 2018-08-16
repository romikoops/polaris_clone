import React from 'react'
import styles from '../CargoContainerGroup.scss'
import PropTypes from '../../../../../prop-types'

export default function CargoContainerGroupAggregated ({ group }) {
  return (
    <div className={
      `${styles.panel} ${styles.open_panel} flex-100 ` +
      'layout-row layout-wrap layout-align-start-center'
    }
    >
      {/* <div className={
        `${styles.detailed_row} flex-100 layout-row layout-wrap layout-align-none-center`
      }
      >
        <h4 className="flex-none"> Aggregate Values:</h4>
      </div> */}
      <div className={
        `${styles.detailed_row_aggregated} flex-100 ` +
        'layout-row layout-wrap layout-align-none-center'
      }
      >
        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center"><span className={styles.cargo_type}>{group.payload_in_kg || group.weight}</span> &nbsp;kg </p>
            <p className="flex-none layout-row layout-align-center-center">Cargo Gross Weight</p>
          </div>
        </div>

        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span className={styles.cargo_type}>
                {(+group.gross_weight)}
              </span> &nbsp;kg</p>
            <p className="flex-none layout-row layout-align-center-center">Gross Weight</p>
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
            <p className="flex-none layout-row layout-align-center-center">Tare Weight</p>
          </div>
        </div>
      </div>
    </div>
  )
}

CargoContainerGroupAggregated.propTypes = {
  group: PropTypes.objectOf(PropTypes.any)
}

CargoContainerGroupAggregated.defaultProps = {
  group: {}
}
