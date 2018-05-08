import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './GreyBox.scss'

export class GreyBox extends Component {
  constructor (props) {
    super(props)
    this.state = {
      flex: props.flex,
      fullWidth: props.fullWidth,
      padding: props.padding
    }
  }

  render () {
    const InnerComponent = this.props.component

    return (
      <div className={`layout-row flex-${this.state.flex} layout-wrap layout-align-center-stretch ${styles.greyboxborder}
        ${this.state.padding ? styles.boxpadding : ''}
        ${this.state.fullWidth ? styles.fullWidth : ''}`}
      >
        {InnerComponent}
      </div>
    )
  }
}

GreyBox.propTypes = {
  component: PropTypes.element,
  flex: PropTypes.number,
  fullWidth: PropTypes.bool,
  padding: PropTypes.bool
}

GreyBox.defaultProps = {
  component: React.createElement('div'),
  flex: 50,
  fullWidth: false,
  padding: true
}

export default GreyBox
