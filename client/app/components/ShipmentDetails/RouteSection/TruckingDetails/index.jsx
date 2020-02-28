import React from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import styles from './index.scss'
import { Tooltip } from '../../../Tooltip/Tooltip'
import { humanizeSnakeCase } from '../../../../helpers/stringTools'

function TruckingDetails ({
  theme, trucking, truckTypes, onTruckingDetailsChange, target, hide, wrapperClassName
}) {
  if (hide) return null
  if (truckTypes.length === 0) return null

  function tooltip (truckType) {
    return (
      <Tooltip
        text={truckType}
        icon="fa-info-circle"
        theme={theme}
        color="white"
        wrapperClassName={styles.tooltip}
        place="left"
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
        className={`
          ${styles.form_group} ${disabledClass} ${wrapperClassName}
          layout-row
        `}
        data-tip={`${humanizedTruckType} is not available for the given address.`}
        data-for={id}
      >
        { disabled ? <ReactTooltip effect="solid" id={id} place="bottom" /> : '' }

        <div className={disabled ? styles.overlay : ''} />
        <input
          type="radio"
          id={`${carriage}-${truckType}`}
          name={`${carriage}Truck`}
          value={`${carriage}Truck`}
          checked={trucking[carriage].truckType === truckType}
          onChange={onTruckingDetailsChange}
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
      <div className="flex-100 layout-row layout-align-start">
        { baseTruckTypes.map((truckType) => formGroup(carriage, truckType)) }
      </div>
    )
  }

  return (
    <div className={styles.trucking_details}>
      { carriageSection(target) }
    </div>
  )
}

TruckingDetails.defaultProps = {
  theme: null
}

export default TruckingDetails
