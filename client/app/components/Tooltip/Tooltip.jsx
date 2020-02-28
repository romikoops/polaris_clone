import React from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import { get } from 'lodash'
import PropTypes from '../../prop-types'
import { tooltips } from '../../constants'
import { gradientTextGenerator } from '../../helpers'
import styles from './Tooltip.scss'

export function Tooltip ({
  text, icon, theme, color, toolText, place
}) {
  const textStyle = color
    ? { color }
    : gradientTextGenerator(get(theme, ['colors', 'primary']), get(theme, ['colors', 'secondary']))
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
      <ReactTooltip id={id} className={styles.tooltip_box} effect="solid" place={place} />
    </div>
  )
}

Tooltip.propTypes = {
  theme: PropTypes.theme,
  text: PropTypes.string,
  icon: PropTypes.string,
  color: PropTypes.string,
  toolText: PropTypes.string,
  place: PropTypes.string
}

Tooltip.defaultProps = {
  color: '',
  theme: {},
  toolText: '',
  text: '',
  icon: '',
  place: 'top'
}

export default Tooltip
