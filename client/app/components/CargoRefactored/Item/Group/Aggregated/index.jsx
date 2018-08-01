import React from 'react'
import styles from '../CargoItemGroup.scss'
import PropTypes from '../../../../../prop-types'
import { trim, ROW, WRAP_ROW, ALIGN_CENTER } from '../../../../../classNames'

export default function CargoItemGroupAggregated ({ group }) {
  const chargableWeight = group.size_class ? '' : +(group.chargeable_weight).toFixed(3)

  return (
    <div className={trim(`
      ${styles.panel} 
      ${styles.open_panel} 
      ${WRAP_ROW(100)}
      layout-align-start-center
    `)}
    >
      <div className={trim(`
          ${styles.detailed_row_aggregated}
          ${WRAP_ROW(100)} 
          layout-align-none-center
        `)}
      >
        <div className={`${ROW(33)} layout-align-space-around`}>
          <div className="layout-column">
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>
              <span className={styles.cargo_type}>
                {group.payload_in_kg || group.weight}
              </span> &nbsp;kg </p>
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>Gross Weight</p>
          </div>
        </div>

        <div className={`${ROW(33)} layout-align-space-around`}>
          <div className="layout-column">
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>
              <span className={styles.cargo_type}>
                {(+group.volume).toFixed(3)}
              </span> &nbsp;m<sup>3</sup>
            </p>
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>Volume</p>
          </div>
        </div>

        <div className={`${ROW(33)} layout-align-space-around`}>
          <div className="layout-column">
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>
              <span className={styles.cargo_type}>
                {chargableWeight}
              </span>
              &nbsp;kg
            </p>
            <p className={`${ROW('none')} ${ALIGN_CENTER}`}>Chargeable Weight</p>
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
