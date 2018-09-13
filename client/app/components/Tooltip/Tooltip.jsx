import React from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import { tooltips } from '../../constants'
import { gradientTextGenerator } from '../../helpers'
import styles from './Tooltip.scss'

export function Tooltip ({
  text, icon, theme, color, toolText
}) {
  const textStyle = color
    ? { color }
    : gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
  const tipText = toolText || tooltips[text]
  const clipClass = color ? '' : 'clip'
  const id = v4()

  return (
    <div className={`${styles.icon_placement} `} >
      <i
        className={`${clipClass} fa ${icon}`}
        style={textStyle}
        data-tip={tipText}
        data-for={id}
      />
      <ReactTooltip id={id} className={styles.tooltip_box} effect="solid" />
    </div>
  )
}

Tooltip.propTypes = {
  theme: PropTypes.theme,
  text: PropTypes.string,
  icon: PropTypes.string,
  color: PropTypes.string,
  toolText: PropTypes.string
}

Tooltip.defaultProps = {
  color: '',
  theme: {},
  toolText: '',
  text: '',
  icon: ''
}

export default Tooltip
