import React from 'react'
import styles from './index.scss'
import Checkbox from '../../../../Checkbox/Checkbox'
import Tooltip from '../../../../Tooltip/Tooltip'
import { camelToSnakeCase } from '../../../../../helpers'

export default function CheckboxWrapper ({
  cargoItem,
  checkedTransform = x => x,
  disabled,
  i,
  labelText,
  onChange,
  onWrapperClick = () => {},
  prop,
  theme
}) {
  return (
    <div
      onClick={onWrapperClick}
      className={`layout-row flex layout-wrap layout-align-start-center ${styles.cargo_unit_check}`}
    >
      <Checkbox
        id={`${i}-${prop}`}
        name={`${i}-${prop}`}
        onChange={onChange}
        checked={checkedTransform(cargoItem[prop])}
        theme={theme}
        size="15px"
        disabled={disabled}
      />
      <div className="layout-row flex-75 layout-wrap layout-align-start-center">
        <label className={`${styles.input_check} flex-none pointy`} htmlFor={`${i}-${prop}`}>
          <p>{labelText}</p>
        </label>
        <Tooltip color={theme.colors.primary} icon="fa-info-circle" text={camelToSnakeCase(prop)} />
      </div>
    </div>
  )
}
