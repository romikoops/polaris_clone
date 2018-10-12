import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './Modal.scss'
import { dimentionToPx } from '../../helpers/dimentionToPx'

export class Modal extends Component {
  constructor (props) {
    super(props)
    this.state = {
      windowHeight: '0',
      hidden: false
    }
    this.hide = this.hide.bind(this)
    this.triggerUpdateDimensions = this.triggerUpdateDimensions.bind(this)
    this.updatedDimensions = false
    this.animationTime = 100
  }

  componentDidMount () {
    this.updateDimensions(this.animationTime)
    window.addEventListener('resize', () => this.updateDimensions(this.animationTime))
  }

  componentDidUpdate () {
    if (!this.updatedDimensions) {
      this.updateDimensions(this.animationTime)
      this.updatedDimensions = true
    }
  }

  componentWillUnmount () {
    window.removeEventListener('resize', () => this.updateDimensions(this.animationTime))
  }
  triggerUpdateDimensions (animationTime) {
    this.updatedDimensions = false
    this.animationTime = animationTime
    this.forceUpdate()
  }

  updateDimensions () {
    const interval = 20
    let counter = typeof this.animationTime === 'number' ? (this.animationTime / interval) : 1

    clearInterval(this.animation)

    this.animation = setInterval(() => {
      this.setState({
        windowHeight: window.innerHeight
      })
      counter -= 1
      if (counter === 0) clearInterval(this.animation)
    }, interval)
  }

  hide () {
    this.setState({
      hidden: true
    })
    this.props.parentToggle()
  }

  render () {
    if (this.state.hidden) return ''

    const { windowHeight } = this.state
    const { maxWidth } = this.props

    const propsMinHeight = dimentionToPx({
      value: this.props.minHeight,
      windowHeight
    })
    const minHeight = propsMinHeight || 0

    const modalStyles = {
      minHeight,
      maxHeight: `calc(${windowHeight * 0.9}px - (${this.props.verticalPadding} * 2))`,
      maxWidth,
      padding: `${this.props.verticalPadding} ${this.props.horizontalPadding}`,
      overflowY: 'auto'
    }

    const component = Object.assign({}, this.props.component)
    component.props = Object.assign({}, component.props)
    component.props.updateDimensions = this.triggerUpdateDimensions

    return (
      <div className={`${styles.full_size} flex-none layout-row layout-align-center-center`}>
        <div className={`${styles.modal_background} ${styles.full_size}`} onClick={this.hide} />

        <div
          ref={(div) => { this.modal = div }}
          style={modalStyles}
          className={`${styles.modal} ${this.props.flexOptions || 'flex-none'}`}
        >
          { component }
        </div>
      </div>
    )
  }
}

Modal.propTypes = {
  component: PropTypes.node.isRequired,
  parentToggle: PropTypes.func.isRequired,
  minHeight: PropTypes.string,
  flexOptions: PropTypes.string,
  maxWidth: PropTypes.string,
  horizontalPadding: PropTypes.string,
  verticalPadding: PropTypes.string
}

Modal.defaultProps = {
  minHeight: '',
  flexOptions: '',
  maxWidth: '90%',
  horizontalPadding: '20px',
  verticalPadding: '20px'
}

export default Modal
