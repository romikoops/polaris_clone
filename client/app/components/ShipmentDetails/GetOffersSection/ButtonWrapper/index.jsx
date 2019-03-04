import React from 'react'
import uuid from 'uuid'
import RoundButton from '../../../RoundButton/RoundButton'

function ButtonWrapper ({
  show, text, active, disabled, type, onClick, onClickDisabled, theme, subTexts, iconClass, back
}) {
  if (!show) return ''

  return (
    <div className="flex-35 layout-row layout-wrap layout-align-end">
      <RoundButton
        text={text}
        handleNext={onClick}
        handleDisabled={onClickDisabled}
        active={active}
        disabled={disabled}
        iconClass={iconClass}
        theme={theme}
        classNames="layout-row layout-align-end"
        type={type}
        back={back}
      />

      {
        subTexts.map(subText => subText && (
          <p key={uuid.v4()} style={{ fontSize: '14px', width: '317px', color: 'rgb(211, 104, 80)' }}>
            { subText }
          </p>
        ))
      }
    </div>
  )
}

ButtonWrapper.defaultProps = {
  subTexts: [],
  show: true,
  active: null,
  disabled: null,
  iconClass: null,
  onClick: null,
  back: null
}

export default ButtonWrapper
