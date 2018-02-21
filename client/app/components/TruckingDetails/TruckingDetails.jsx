import React from 'react'
import PropTypes from '../../prop-types'
import styles from './TruckingDetails.scss'
import { Tooltip } from '../Tooltip/Tooltip'
import { TextHeading } from '../TextHeading/TextHeading'
import { humanizeSnakeCase } from '../../helpers/stringTools'

export default function TruckingDetails (props) {
  const { theme, trucking, handleTruckingDetailsChange } = props
  function tooltip (truckType) {
    return (
      <Tooltip
        text={truckType}
        icon="fa-info-circle"
        theme={theme}
        wrapperClassName={styles.tooltip}
      />
    )
  }

  function formGroup (carriage, truckType) {
    return (
      <div className={`${styles.form_group} layout-row layout-align-start-end`}>
        <input
          type="radio"
          id={`${carriage}-${truckType}`}
          name={`${carriage}_truck`}
          checked={trucking[carriage].truck_type === truckType}
          onChange={handleTruckingDetailsChange}
        />
        <label htmlFor={`${carriage}_${truckType}`}>{ humanizeSnakeCase(truckType) }</label>
        { tooltip(truckType, theme) }
      </div>
    )
  }
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
              { formGroup('pre_carriage', 'side_lifter') }
              { formGroup('pre_carriage', 'chassis') }
            </div>
          </div>
          <div className="flex-50 layout-row layout-wrap">
            <div className="flex-100">
              <h5>On-Carriage</h5>
            </div>
            <div className="flex-100 layout-column layout-align-space-around">
              { formGroup('on_carriage', 'side_lifter') }
              { formGroup('on_carriage', 'chassis') }
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

TruckingDetails.propTypes = {
  theme: PropTypes.theme,
  trucking: PropTypes.shape({
    on_carriage: {
      truck: PropTypes.string
    },
    pre_carriage: {
      truck: PropTypes.string
    }
  }).isRequired,
  handleTruckingDetailsChange: PropTypes.func.isRequired
}

TruckingDetails.defaultProps = {
  theme: null
}
