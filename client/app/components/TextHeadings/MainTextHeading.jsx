import React from 'react'
import PropsTypes from '../../prop-types'

export function MainTextHeading ({ text, theme }) {
  const headerStyle = {
    background: theme && theme.colors ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})` : 'black'
  }
  return (
    <div className="flex-100 layout-row layout-align-start-center">
      <h1>
        <p className="flex-none clip" style={headerStyle}>{text}</p>
      </h1>
    </div>
  )
}

MainTextHeading.propTypes = {
  text: PropsTypes.string.isRequired,
  theme: PropsTypes.theme
}

MainTextHeading.defaultProps = {
  theme: null
}

export default MainTextHeading
