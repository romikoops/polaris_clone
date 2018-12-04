import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { StickyContainer, Sticky } from 'react-sticky'
import PropTypes from '../../prop-types'
import styles from './Alert.scss'

class Alert extends Component {
  static alertClass (type) {
    const classes = {
      error: styles.danger,
      alert: styles.warning,
      notice: styles.info,
      success: styles.success
    }

    return classes[type] || classes.success
  }

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

  getText () {
    const { message, t } = this.props
    if (typeof message.text === 'object') return t('errors:errorOccured')

    return message.text
  }

  close () {
    const { onClose, message } = this.props
    onClose(message)
  }

  render () {
    const { message } = this.props
    const alertClassName = `alert ${Alert.alertClass(message.type)} fade in`

    return (
      <StickyContainer>
        <Sticky>
          {
            ({
              style
            }) => (
              <div className={alertClassName} style={style}>
                <div className={styles.alert_inner_wrapper} />
                { this.getText() }
                <i className="fa fa-times close" onClick={this.close} />
              </div>
            )
          }
        </Sticky>
      </StickyContainer>
    )
  }
}

Alert.propTypes = {
  onClose: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired,
  timeout: PropTypes.number,
  message: PropTypes.shape({
    type: PropTypes.string,
    text: PropTypes.string
  }).isRequired
}

Alert.defaultProps = {
  timeout: 5000
}

export default withNamespaces('errors')(Alert)
