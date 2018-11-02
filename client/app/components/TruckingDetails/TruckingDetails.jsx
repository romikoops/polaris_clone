import React from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './TruckingDetails.scss'
import { Tooltip } from '../Tooltip/Tooltip'
import { humanizeSnakeCase } from '../../helpers/stringTools'

export default function TruckingDetails (props) {
  const {
    theme, trucking, truckTypes, handleTruckingDetailsChange, target
  } = props

  if (truckTypes.length === 0) return ''

  function tooltip (truckType) {
    return (
      <Tooltip
        text={truckType}
        icon="fa-info-circle"
        theme={theme}
        color="white"
        wrapperClassName={styles.tooltip}
      />
    )
  }

  function formGroup (carriage, truckType) {
    const disabled = !truckTypes.includes(truckType)
    const disabledClass = disabled ? styles.disabled : ''
    const id = v4()
    const humanizedTruckType = humanizeSnakeCase(truckType)

    return (
      <div
        className={`${styles.form_group} ${disabledClass} flex-50 layout-row layout-align-start-end`}
        data-tip={`${humanizedTruckType} is not available for the given address.`}
        data-for={id}
      >
        { disabled ? <ReactTooltip effect="solid" id={id} place="bottom" /> : '' }

        <div className={disabled ? styles.overlay : ''} />
        <input
          type="radio"
          id={`${carriage}-${truckType}`}
          name={`${carriage}_truck`}
          value={`${carriage}_truck`}
          checked={trucking[carriage].truck_type === truckType}
          onChange={handleTruckingDetailsChange}
          disabled={disabled}
        />
        <label htmlFor={`${carriage}-${truckType}`}>{ humanizedTruckType }</label>
        {tooltip(truckType)}
      </div>
    )
  }

  function carriageSection (carriage) {
    const baseTruckTypes = ['side_lifter', 'chassis']

    return (
      <div className={`${styles.carriage_sec}  flex-100 layout-row layout-wrap`}>
        <div className="flex-100 layout-row layout-align-space-around">
          { baseTruckTypes.map(_truckType => formGroup(carriage, _truckType)) }
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
