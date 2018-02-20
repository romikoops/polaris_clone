import React from 'react'
import PropTypes from '../../prop-types'
import styles from './TruckingDetails.scss'
// import { Tooltip } from '../Tooltip/Tooltip'
import { TextHeading } from '../TextHeading/TextHeading'

export default function TruckingDetails (props) {
  const { theme } = props
  return (
    <div className="content_width">
      <div className={`${styles.trucking_details} layout-row layout-wrap layout-align-center`}>
        <div className="flex-100">
          <TextHeading
            theme={theme}
            text="Trucking Details"
            size={3}
          />
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center">
          <div className="flex-50 layout-row layout-wrap">
            <div className="flex-100">
              <h5>Pre-Carriage</h5>
            </div>
            <div className="flex-100 layout-column layout-align-space-around">
              <div className={styles.form_group}>
                <input
                  type="radio"
                  id="pre_carriage_side_lifter"
                  name="pre_carriage_truck"
                />
                <label htmlFor="pre_carriage_side_lifter">Side Lifter</label>
              </div>
              <div className={styles.form_group}>
                <input
                  type="radio"
                  id="pre_carriage_chassis"
                  name="pre_carriage_truck"
                />
                <label htmlFor="pre_carriage_chassis">Chassis</label>
              </div>
            </div>
          </div>
          <div className="flex-50 layout-row layout-wrap">
            <div className="flex-100">
              <h5>On-Carriage</h5>
            </div>
            <div className="flex-100 layout-column layout-align-space-around">
              <div className={styles.form_group}>
                <input
                  type="radio"
                  id="on_carriage_side_lifter"
                  name="on_carriage_truck"
                />
                <label htmlFor="on_carriage_side_lifter">Side Lifter</label>
              </div>
              <div className={styles.form_group}>
                <input
                  type="radio"
                  id="on_carriage_chassis"
                  name="on_carriage_truck"
                />
                <label htmlFor="on_carriage_chassis">Chassis</label>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

TruckingDetails.propTypes = {
  theme: PropTypes.theme
}

TruckingDetails.defaultProps = {
  theme: null
}
