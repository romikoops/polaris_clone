import React, { Component } from 'react'
import { get } from 'lodash'
import { connect } from 'react-redux'
import { numberSpacing } from '../../../helpers'

class UnitsWeight extends Component {
  render () {
    const { value, spanClasses, scope } = this.props
    const weightScope = get(scope, ['values', 'weight'], false)
    const renderValue = weightScope.unit === 'kg' ? value : (value / 1000)
    const renderDecimals = weightScope.decimals || 2

    return (
      <span className={spanClasses}>
        { ` ${numberSpacing(renderValue, renderDecimals)} ${weightScope.unit}` }
      </span>
    )
  }
}

UnitsWeight.defaultProps = {
  spanClasses: 'flex layout-row layout-align-end',
  value: 0,
  scope: {}
}

function mapStateToProps (state) {
  const {
    app
  } = state
  const { tenant } = app
  const { theme, scope } = tenant

  return {
    tenant,
    scope,
    theme
  }
}

export default connect(mapStateToProps, null)(UnitsWeight)
