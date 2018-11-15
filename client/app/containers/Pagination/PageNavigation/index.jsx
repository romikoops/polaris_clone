import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './PageNavigation.scss'

function PageNavigation ({
  page, numPages, nextPage, prevPage, t
}) {
  return (
    <div className={`layout-row layout-align-center-center ${styles.page_navigation}`}>
      <div
        className={`
          flex-15 layout-row layout-align-center-center pointy
          ${styles.navigation_button} ${+page > 1 ? '' : styles.disabled}
        `}
        onClick={+page > 1 ? prevPage : null}
      >
        <i className="fa fa-chevron-left" />
        <p className={`${styles.back}`}>
          {t('common:basicBack')}
        </p>
      </div>
      <p>{page} / {numPages} </p>
      <div
        className={`
          flex-15 layout-row layout-align-center-center pointy
          ${styles.navigation_button} ${+page < numPages ? '' : styles.disabled}
        `}
        onClick={+page < numPages ? nextPage : null}
      >
        <p className={`${styles.forward}`}>{t('common:next')}</p>
        <i className="fa fa-chevron-right" />
      </div>
    </div>
  )
}

export default withNamespaces('common')(PageNavigation)
