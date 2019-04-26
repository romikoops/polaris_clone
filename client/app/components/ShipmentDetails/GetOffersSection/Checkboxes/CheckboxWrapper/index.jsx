import React from 'react'
import Checkbox from '../../../../Checkbox/Checkbox'
import Tooltip from '../../../../Tooltip/Tooltip'

function CheckboxWrapper ({
  id,
  name,
  className,
  theme,
  checked,
  labelContent,
  onChange,
  show,
  style,
  disabled,
  size,
  tooltipText
}) {
  if (!show) return ''

  return (
    <div
      className={`${className} flex-100 layout-row layout-align-start-center`}
      style={style}
    >
      <div className="flex-10 layout-row layout-align-start-start">
        <Checkbox
          id={id}
          theme={theme}
          onChange={onChange}
          size={size}
          name={name}
          required
          checked={checked}
          disabled={disabled}
        />
      </div>
      <label htmlFor={id} className="pointy">
        {labelContent}
      </label>
      {
        tooltipText ? (
          <Tooltip color={theme.colors.primary} icon="fa-info-circle" text={tooltipText} />
        ) : ''
      }
    </div>
  )
}

export default CheckboxWrapper
