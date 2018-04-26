import React, { Component } from 'react'
import { StickyContainer, Sticky } from 'react-sticky'
import PropTypes from '../../prop-types'
import styles from './Alert.scss'

const ICON = 'fa fa-times close'

const alertClass = (type) => {
  const classes = {
    error: styles.danger,
    alert: styles.warning,
    notice: styles.info,
    success: styles.success
  }

  return classes[type] || classes.success
}

export class Alert extends Component {
  constructor (props) {
    super(props)
    this.close = this.close.bind(this)
  }
  componentDidMount () {
    this.timer = setTimeout(
      this.close,
      this.props.timeout
    )
  }
  componentWillUnmount () {
    clearTimeout(this.timer)
  }
  close () {
    this.props.onClose(this.props.message)
  }
  render () {
    const { message } = this.props
    const alertClassName = `alert fade in ${alertClass(message.type)}`
    const messageText = typeof message.text === 'object'
      ? 'An error occurred'
      : message.text

    return (
      <StickyContainer>
        <Sticky>
          {
            ({
              style
            }) => (
              <div
                className={alertClassName}
                style={style}
              >
                <div className={styles.alert_inner_wrapper} />
                { messageText }
                <i className={ICON} onClick={this.close} />
              </div>
            )
          }
        </Sticky>
      </StickyContainer>
    )
  }
}

/**
 * message.type can be one of 'error','alert','notice', 'success'
 */
Alert.propTypes = {
  onClose: PropTypes.func,
  timeout: PropTypes.number,
  message: PropTypes.shape({
    type: PropTypes.string,
    text: PropTypes.string
  }).isRequired
}

Alert.defaultProps = {
  onClose: () => console.log('Alert.onClose'),
  timeout: 5000
}

export default Alert
