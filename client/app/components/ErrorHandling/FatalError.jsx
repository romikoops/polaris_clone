import React from 'react'
import { withNamespaces } from 'react-i18next'
import * as Sentry from '@sentry/browser'

import styles from './errors.scss'

const FatalError = (props) => {
  const { t, error } = props
  Sentry.captureException(error)

  return (
    <div className="layout-fill layout-row layout-wrap layout-align-center-center">
      <div className={`flex-30 layout-row layout-wrap layout-align-center-center layout-padding ${styles.error_box}`}>
        <div className="flex-100 layout-row layout-align-center-center" />
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

const translatedComponent = withNamespaces('errors')(FatalError)
export default translatedComponent
