import React from 'react'
import PropTypes from '../../prop-types'
import styles from './TruckingDetails.scss'
import { Tooltip } from '../Tooltip/Tooltip'
import { humanizeSnakeCase } from '../../helpers/stringTools'

export default function TruckingDetails (props) {
  const {
    theme, trucking, truckTypes, handleTruckingDetailsChange, target
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
      <div className={`${styles.form_group} flex-50 layout-row layout-align-start-end`}>
        <input
          type="radio"
          id={`${carriage}-${truckType}`}
          name={`${carriage}_truck`}
          value={`${carriage}_truck`}
          checked={trucking[carriage].truck_type === truckType}
          onChange={handleTruckingDetailsChange}
        />
        <label htmlFor={`${carriage}-${truckType}`}>{ humanizeSnakeCase(truckType) }</label>
        { tooltip(truckType, theme) }
      </div>
    )
  }

  function carriageSection (carriage) {
    const disabled = !trucking[carriage].truck_type
    const disabledClass = disabled ? styles.disabled : ''
    return (
      <div className={`${styles.carriage_sec} ${disabledClass} flex-100 layout-row layout-wrap`}>
        <div className={disabled ? styles.overlay : ''} />
        <div className="flex-100 layout-row layout-align-space-around">
          { truckTypes.map(_truckType => formGroup(carriage, _truckType)) }
        </div>
      </div>
    )
  }
  return (
    <div className="flex-100 layout-row">
      <div className={`${styles.trucking_details} flex-100 layout-row layout-wrap layout-align-center`}>
        <div className="flex-100 layout-row layout-wrap layout-align-center">
          { carriageSection(target) }
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
  handleTruckingDetailsChange: PropTypes.func.isRequired,
  target: PropTypes.string.isRequired
}

TruckingDetails.defaultProps = {
  theme: null
}
