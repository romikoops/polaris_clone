import React from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { tooltips } from '../../constants'
import { gradientTextGenerator } from '../../helpers'

export function Tooltip ({
  text, icon, theme, color, toolText
}) {
  const textStyle = color
    ? { color }
    : gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  const tipText = toolText ? text : tooltips[text]
  const clipClass = color ? '' : 'clip'
  const id = v4()
  return (
    <div className="flex-none layout-row layout-align-center-center tooltip" style={{ margin: '0 10px' }}>
      <p
        className={`flex-none ${clipClass} fa ${icon}`}
        style={textStyle}
        data-tip={tipText}
        data-for={id}
      />
      <div className="flex-30">
        <ReactTooltip id={id} className="flex-20" />
      </div>
    </div>
  )
}

Tooltip.propTypes = {
  theme: PropTypes.theme,
  text: PropTypes.string,
  icon: PropTypes.string.isRequired,
  color: PropTypes.string,
  toolText: PropTypes.bool
}

Tooltip.defaultProps = {
  color: '',
  theme: '',
  text: '',
  toolText: false
}

export default Tooltip
