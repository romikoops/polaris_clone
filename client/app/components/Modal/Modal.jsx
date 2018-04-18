import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './Modal.scss'
import { dimentionToPx } from '../../helpers/dimentionToPx'

export class Modal extends Component {
  constructor (props) {
    super(props)
    this.state = {
      height: '0',
      width: '0',
      windowHeight: '0',
      hidden: false
    }
    this.hide = this.hide.bind(this)
    this.updateDimentions = this.updateDimentions.bind(this)
    this.triggerUpdateDimentions = this.triggerUpdateDimentions.bind(this)
    this.updatedDimentions = false
  }

  componentDidMount () {
    this.updateDimentions()
    window.addEventListener('resize', this.updateDimentions)
  }

  componentDidUpdate () {
    if (!this.updatedDimentions) {
      this.updateDimentions()
      this.updatedDimentions = true
    }
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.updateDimentions)
  }
  triggerUpdateDimentions () {
    this.updatedDimentions = false
    this.forceUpdate()
  }

  updateDimentions () {
    this.setState({
      height: this.modal.clientHeight,
      width: this.modal.clientWidth,
      windowHeight: window.innerHeight
    })
  }

  hide () {
    this.setState({
      hidden: true
    })
    this.props.parentToggle()
  }

  render () {
    if (this.state.hidden) return ''

    const { width, height, windowHeight } = this.state

    const propsMinHeight = dimentionToPx({
      value: this.props.minHeight,
      windowHeight
    })
    const minHeight = propsMinHeight || 0
    const minTop = Math.max(windowHeight / 2 - height, 100)

    const modalStyles = {
      top: `${Math.max(windowHeight * 0.5 - this.state.height / 2, minTop)}px`,
      minHeight,
      maxHeight: `calc(${windowHeight * 0.9}px - (${this.props.verticalPadding} * 2))`,
      maxWidth: '90%',
      left: `calc(50% - ${width}px/2)`,
      padding: `${this.props.verticalPadding} ${this.props.horizontalPadding}`,
      overflowY: 'auto'
    }

    const component = Object.assign({}, this.props.component)
    component.props = Object.assign({}, component.props)
    component.props.updateDimentions = this.triggerUpdateDimentions

    return (
      <div>
        <div className={`${styles.modal_background} ${styles.full_size}`} onClick={this.hide} />

        <div
          ref={(div) => { this.modal = div }}
          style={modalStyles}
          className={styles.modal}
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
  horizontalPadding: PropTypes.string,
  verticalPadding: PropTypes.string
}

Modal.defaultProps = {
  minHeight: '',
  horizontalPadding: '20px',
  verticalPadding: '20px'
}

export default Modal
