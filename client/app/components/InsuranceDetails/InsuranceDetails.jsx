import React from 'react'
import styles from './InsuranceDetails.scss'
import PropTypes from '../../prop-types'
import insuranceDetails from '../../static/insuranceDetails'
import Header from '../Header/Header'

export default function InsuranceDetails ({ tenant, user, theme }) {
  const subdomain = (tenant && tenant.slug) || 'def'
  const content = insuranceDetails[subdomain] || insuranceDetails.def
  return (
    <div className="flex-100 layout-row layout-wrap">
      <Header user={user} theme={theme} noMessages />
      <div className="flex-100 layout-row layout-align-center">
        <div className={`${styles.terms_and_conditions} content_width_booking`}>
          { content }
        </div>
      </div>
    </div>
  )
}

InsuranceDetails.propTypes = {
  tenant: PropTypes.tenant,
  user: PropTypes.user,
  theme: PropTypes.theme
}

InsuranceDetails.defaultProps = {
  tenant: null,
  user: null,
  theme: null
}
