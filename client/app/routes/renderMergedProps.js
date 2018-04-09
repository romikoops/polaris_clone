import React from 'react'

export default function renderMergedProps (component, ...rest) {
  const finalProps = Object.assign({}, ...rest)
  return React.createElement(component, finalProps)
}
