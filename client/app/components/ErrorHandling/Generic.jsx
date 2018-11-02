import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import * as Sentry from '@sentry/browser'
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
    Sentry.captureException(error, { extra: info })
  }

  render () {
    const { theme, t } = this.props
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return (
        <div className="layout-fill layout-row layout-wrap layout-align-center-center">
          <div className={`flex-none layout-row layout-wrap layout-padding ${styles.error_box}`}>
            <div className="flex-100 layout-row layout-align-center-center">
              <img className="flex-none" src={theme.logoLarge} alt={theme.logoSmall} />
            </div>
            <div className="flex-100 layout-row layout-align-center-center">
              <h1 className="flex-none">{t('errors:ohNo')}</h1>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-center">
              <p className="flex-100">{t('errors:somethingWrong')}</p>
              <p className="flex-100">{t('errors:pleaseRetry')}</p>
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
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme
}

GenericError.defaultProps = {
  children: [],
  theme: {}
}

export default withNamespaces('errors')(GenericError)
