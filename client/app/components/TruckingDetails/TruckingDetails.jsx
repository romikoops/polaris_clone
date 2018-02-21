import React from 'react'
import PropTypes from '../../prop-types'
import styles from './TruckingDetails.scss'
import { Tooltip } from '../Tooltip/Tooltip'
import { TextHeading } from '../TextHeading/TextHeading'
import { humanizeSnakeCase } from '../../helpers/stringTools'

function tooltip (truckType, theme) {
  return (
    <Tooltip
      text={truckType}
      icon="fa-info-circle"
      theme={theme}
      wrapperClassName={styles.tooltip}
    />
  )
}

function formGroup (carriage, truckType, theme, handleTruckingDetailsChange) {
  return (
    <div className={`${styles.form_group} layout-row layout-align-start-end`}>
      <input
        type="radio"
        id={`${carriage}-${truckType}`}
        name={`${carriage}_truck`}
        onChange={handleTruckingDetailsChange}
      />
      <label htmlFor={`${carriage}_${truckType}`}>{ humanizeSnakeCase(truckType) }</label>
      { tooltip(truckType, theme) }
    </div>
  )
}

export default function TruckingDetails (props) {
  const { theme, handleTruckingDetailsChange } = props
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
              { formGroup('pre_carriage', 'side_lifter', theme, handleTruckingDetailsChange) }
              { formGroup('pre_carriage', 'chassis', theme, handleTruckingDetailsChange) }
            </div>
          </div>
          <div className="flex-50 layout-row layout-wrap">
            <div className="flex-100">
              <h5>On-Carriage</h5>
            </div>
            <div className="flex-100 layout-column layout-align-space-around">
              { formGroup('on_carriage', 'side_lifter', theme, handleTruckingDetailsChange) }
              { formGroup('on_carriage', 'chassis', theme, handleTruckingDetailsChange) }
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

TruckingDetails.propTypes = {
  theme: PropTypes.theme,
  handleTruckingDetailsChange: PropTypes.func.isRequired
}

TruckingDetails.defaultProps = {
  theme: null
}
