import React, { Component } from 'react'
import Raven from 'raven-js'
import PropTypes from '../../prop-types'
import styles from './errors.scss'

class GenericError extends Component {
  constructor (props) {
    super(props)
    this.state = { hasError: false }
  }

  componentDidCatch (error, info) {
    // Display fallback UI
    this.setState({ hasError: true, error })
    // You can also log the error to an error reporting service
    Raven.captureException(error, { extra: info })
  }

  render () {
    const { theme } = this.props
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return (
        <div className="layout-fill layout-row layout-wrap layout-align-center-center">
          <div className={`flex-none layout-row layout-wrap layout-padding ${styles.error_box}`}>
            <div className="flex-100 layout-row layout-align-center-center">
              <img className="flex-none" src={theme.logoLarge} alt={theme.logoSmall}/>
            </div>
            <div className="flex-100 layout-row layout-align-center-center">
              <h1 className="flex-none">Oh no!</h1>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-center">
              <p className="flex-100">Something has gone wrong! A message has been sent to the support team and will be addressed shortly!</p>
              <p className="flex-100">Please retry and if this error keeps happening please contact your store representative</p>
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

GenericError.propTypes = {
  children: PropTypes.node,
  theme: PropTypes.theme
}

GenericError.defaultProps = {
  children: [],
  theme: {}
}

export default GenericError
