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
      <div className={
        `${styles.detailed_row} flex-100 layout-row layout-wrap layout-align-none-center`
      }
      >
        <h4 className="flex-none"> Aggregate Values:</h4>
      </div>
      <div className={
        `${styles.detailed_row} flex-100 ` +
        'layout-row layout-wrap layout-align-none-center'
      }
      >
        <div className="flex-33 layout-row layout-align-space-around">
          <p className="flex-none">Gross Weight</p>
          <p className="flex-none">{group.payload_in_kg || group.weight} kg</p>
        </div>

        <div className="flex-33 layout-row layout-align-space-around">
          <p className="flex-none">Volume</p>
          <p className="flex-none">
            {(+group.volume).toFixed(3)} m<sup>3</sup>
          </p>
        </div>
        <div className="flex-33 layout-row layout-align-space-around">
          <p className="flex-none">Chargeable Weight</p>
          <p className="flex-none">{(+group.chargeable_weight).toFixed(3)} kg</p>
        </div>
      </div>
      <hr className="flex-100" />
    </div>
  )
}

CargoItemGroupAggregated.propTypes = {
  group: PropTypes.objectOf(PropTypes.any)
}

CargoItemGroupAggregated.defaultProps = {
  group: {}
}
