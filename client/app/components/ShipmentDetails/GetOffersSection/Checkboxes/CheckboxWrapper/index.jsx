import React from 'react'
import Checkbox from '../../../../Checkbox/Checkbox'

function CheckboxWrapper ({
  id, name, className, theme, checked, labelContent, onChange, show, style
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
          size="30px"
          name={name}
          checked={checked}
        />
      </div>
      <div className="flex">
        <label htmlFor={id} className="pointy">
          {labelContent}
        </label>
      </div>
    </div>
  )
}

export default CheckboxWrapper
