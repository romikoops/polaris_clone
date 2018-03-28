import React from 'react'
import { v4 } from 'node-uuid'
import styles from '../RegistrationPage.scss'
import { Checkbox } from '../../../components/Checkbox/Checkbox'
import PropTypes from '../../../prop-types'
import termsAndConditionsSummaryBullets from '../../../static/termsAndConditionsSummaryBullets'

export default function TermsAndConditionsSummary (props) {
  const {
    theme, handleChange, accepted, goToTermsAndConditions, tenant
  } = props

  const subdomain = tenant && tenant.data && tenant.data.subdomain
  const bulletTexts = termsAndConditionsSummaryBullets[subdomain] || []
  const bullets = bulletTexts.map(bulletText => <li key={v4()}> { bulletText } </li>)
  const bulletsJSX = bullets.length > 0
    ? (
      <div>
        <h3> Before registering your account, please consider the following: </h3>
        <ul>
          {bullets}
        </ul>
      </div>
    )
    : ''

  return (
    <div className={styles.terms_and_conditions_summary}>
      {bulletsJSX}
      <div className="flex-90 layout-row layout-align-center-center">
        <div className="flex-5 layout-row layout-align-start-start">
          <Checkbox
            theme={theme}
            onChange={handleChange}
            checked={accepted}
            size="18px"
            name="accept_terms_and_conditions"
          />
        </div>
        <div className="flex">
          <p style={{ margin: 0, fontSize: '13px' }}>
            I hereby indicate that I have read and agree to the{' '}
            <span
              className="emulate_link blue_link"
              onClick={goToTermsAndConditions}
            >
              terms and conditions
            </span>
            .
          </p>
        </div>
      </div>

    </div>
  )
}

TermsAndConditionsSummary.propTypes = {
  theme: PropTypes.theme,
  tenant: PropTypes.tenant,
  handleChange: PropTypes.func.isRequired,
  accepted: PropTypes.bool,
  goToTermsAndConditions: PropTypes.func.isRequired
}

TermsAndConditionsSummary.defaultProps = {
  theme: null,
  tenant: null,
  accepted: PropTypes.false
}
