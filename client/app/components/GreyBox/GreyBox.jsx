import React, { Component } from 'react'
import PropTypes from 'prop-types'
import defaults from '../../styles/default_classes.scss'
import styles from './GreyBox.scss'

export class GreyBox extends Component {
  constructor (props) {
    super(props)
    this.state = {
      title: props.title,
      subtitle: props.subtitle,
      flex: props.flex,
      fullWidth: props.fullWidth,
      padding: props.padding
    }
  }

  // <div className='layout-column flex-100 layout-wrap layout-align-start-center'>
  //   <span className='title'>{this.state.title}</span><br/>
  //   <span className='subtitle'>{this.state.subtitle}</span>
  // </div>

  render () {
    const Component = this.props.component

    return (
      <div className={`layout-row flex-${this.state.flex} layout-wrap layout-align-center-stretch ${styles.greyboxborder}
        ${this.state.padding ? styles.boxpadding : ''}
        ${this.state.fullWidth ? styles.fullWidth : ''}`}>
        {Component}
      </div>
    )
  }
}

GreyBox.propTypes = {
  // component: PropTypes.instanceOf(Component),
  title: PropTypes.string,
  subtitle: PropTypes.string,
  flex: PropTypes.number,
  fullWidth: PropTypes.bool,
  padding: PropTypes.bool
}

GreyBox.defaultProps = {
  title: '',
  subtitle: '',
  flex: 50,
  fullWidth: false,
  padding: true
}

export default GreyBox
