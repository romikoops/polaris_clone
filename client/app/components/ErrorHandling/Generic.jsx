import React, { Component } from 'react'
import PropTypes from '../../prop-types'

class ErrorBoundary extends Component {
  static logErrorToMyService () {
    console.log(error)
    console.log(info)
  }
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
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return (
        <div className="flex layout-row layout-wrap layout-align-center-center">
          <div className="flex-100 layout-row layout-align-center-center">
            <h1 className="flex-none">Oh no!</h1>
          </div>
          <div className="flex-100 layout-row layout-align-center-center">
            <p className="flex-100">Something has gone wrong! A message has been sent to the development team and will be addressed shortly!</p>
            <p className="flex-100">Please rety and if this error keeps happening please contact your store representative</p>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

ErrorBoundary

export default ErrorBoundary
