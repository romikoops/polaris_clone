import React from 'react'
import styles from '../CargoItemGroup.scss'
import PropTypes from '../../../../../prop-types'

export default function CargoItemGroupAggregated ({ group }) {
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
            <p className="flex-none layout-row layout-align-center-center"><span>{group.payload_in_kg || group.weight}</span> kg</p>
            <p className="flex-none layout-row layout-align-center-center">Gross Weight</p>
          </div>
        </div>

        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center">
              <span>{(+group.volume).toFixed(3)}</span> m<sup>3</sup>
            </p>
            <p className="flex-none layout-row layout-align-center-center">Volume</p>
          </div>
        </div>
        <div className="flex-33 layout-row layout-align-space-around">
          <div className="layout-column">
            <p className="flex-none layout-row layout-align-center-center"><span>{(group.chargeable_weight).toFixed(3)}</span> kg</p>
            <p className="flex-none layout-row layout-align-center-center">Chargeable Weight</p>
          </div>
        </div>
      </div>
    </div>
  )
}

CargoItemGroupAggregated.propTypes = {
  group: PropTypes.objectOf(PropTypes.any)
}

CargoItemGroupAggregated.defaultProps = {
  group: {}
}
