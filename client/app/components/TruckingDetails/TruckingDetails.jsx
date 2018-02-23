import React from 'react'
import PropTypes from '../../prop-types'
import styles from './TruckingDetails.scss'
import { Tooltip } from '../Tooltip/Tooltip'
import { TextHeading } from '../TextHeading/TextHeading'
import { humanizeSnakeCase, capitalize } from '../../helpers/stringTools'

export default function TruckingDetails (props) {
  const {
    theme, trucking, truckTypes, handleTruckingDetailsChange
  } = props

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
          value={`${carriage}_truck`}
          checked={trucking[carriage].truck_type === truckType}
          onChange={handleTruckingDetailsChange}
        />
        <label htmlFor={`${carriage}_${truckType}`}>{ humanizeSnakeCase(truckType) }</label>
        { tooltip(truckType, theme) }
      </div>
    )
  }

  function carriageSection (carriage) {
    const disabled = !trucking[carriage].truck_type
    const disabledClass = disabled ? styles.disabled : ''
    const prefix = capitalize(carriage.split('_')[0])
    return (
      <div className={`${styles.carriage_sec} ${disabledClass} flex-50 layout-row layout-wrap`}>
        <div className={disabled ? styles.overlay : ''} />
        <div className="flex-100">
          <h5>{`${prefix}-Carriage`}</h5>
        </div>
        <div className="flex-100 layout-column layout-align-space-around">
          { truckTypes.map(_truckType => formGroup(carriage, _truckType)) }
        </div>
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
          { carriageSection('pre_carriage') }
          { carriageSection('on_carriage') }
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
  truckTypes: PropTypes.arrayOf(PropTypes.string).isRequired,
  handleTruckingDetailsChange: PropTypes.func.isRequired
}

TruckingDetails.defaultProps = {
  theme: null
}
