import React from 'react'
import styles from './TermsAndConditions.scss'
import PropTypes from '../../prop-types'
import termsAndConditions from '../../static/termsAndConditions'
import Header from '../Header/Header'

export default function TermsAndConditions ({ tenant, user, theme }) {
  const subdomain = (tenant && tenant.slug) || 'def'
  const content = termsAndConditions[subdomain] || termsAndConditions.def

  return (
    <div className="flex-100 layout-row layout-wrap">
      <Header user={user} theme={theme} noMessages />
      <div className="flex-100 layout-row layout-align-center">
        <div className={`${styles.terms_and_conditions} content_width_booking`}>
          {content}
        </div>
      </div>
    </div>
  )
}

TermsAndConditions.propTypes = {
  tenant: PropTypes.tenant,
  user: PropTypes.user,
  theme: PropTypes.theme
}

TermsAndConditions.defaultProps = {
  tenant: null,
  user: null,
  theme: null
}
