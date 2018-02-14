import React from 'react'
import PropsTypes from '../../prop-types'
import { gradientGenerator } from '../../helpers/gradient'

export function SubTextHeading ({ text, theme }) {
  return (
    <div className="flex-100 layout-row layout-align-start-center">
      <h2>
        <p
          className="flex-none clip"
          style={gradientGenerator(theme.colors.primary, theme.colors.secondary)}
        >
          {text}
        </p>
      </h2>
    </div>
  )
}

SubTextHeading.propTypes = {
  text: PropsTypes.string.isRequired,
  theme: PropsTypes.theme
}

SubTextHeading.defaultProps = {
  theme: null
}

export default SubTextHeading
