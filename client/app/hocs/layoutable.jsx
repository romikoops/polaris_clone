import React from 'react'
import PropTypes from '../prop-types'

function layoutable (WrappedComponent, options = {}) {
  class Klass extends React.Component {
    constructor (props) {
      super(props)

      this.getFlex = this.getFlex.bind(this)
    }
    getFlex () {
      const { flex } = this.props

      return flex.split(' ').map(flexValue => `flex-${flexValue}`).join(' ')
    }

    render () {
      return <WrappedComponent {...this.props} getFlex={this.getFlex} />
    }
  }

  Klass.propTypes = {
    flex: PropTypes.string
  }
  Klass.defaultProps = {
    flex: options.defaultFlex || '100 md-45 gt-md-30'
  }

  return Klass
}

export default layoutable
