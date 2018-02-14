import React from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { tooltips } from '../../constants'
import { gradientTextGenerator } from '../../helpers'

export function Tooltip ({
  text, icon, theme, color
}) {
  const textStyle = color
    ? { color }
    : gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  const tipText = tooltips[text]
  const clipClass = color ? '' : 'clip'
  const id = v4()
  return (
    <div className="flex-none layout-row layout-align-center-center tooltip">
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
  text: PropTypes.string.isRequired,
  icon: PropTypes.string.isRequired,
  color: PropTypes.string
}

Tooltip.defaultProps = {
  color: null,
  theme: null
}

export default Tooltip
