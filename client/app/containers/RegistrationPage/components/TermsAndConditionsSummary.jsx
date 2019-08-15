import React from 'react'
import { v4 } from 'uuid'
import styles from '../RegistrationPage.scss'
import Checkbox from '../../../components/Checkbox/Checkbox'
import PropTypes from '../../../prop-types'
import termsAndConditionsSummaryBullets from '../../../static/termsAndConditionsSummaryBullets'
import { capitalize } from '../../../helpers'

export default function TermsAndConditionsSummary (props) {
  const {
    theme, handleChange, accepted, goToTermsAndConditions,
    goToImcTermsAndConditions, tenant, shakeClass
  } = props

  const subdomain = tenant && tenant.slug
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
      <div
        className={`${shakeClass.tenant} flex-100 layout-row layout-align-center-center`}
        style={{ marginBottom: '8px' }}
      >
        <div className="flex-5 layout-row layout-align-start-start">
          <Checkbox
            id="tenant-accept_terms_and_conditions"
            theme={theme}
            onChange={handleChange}
            checked={accepted.tenant}
            size="18px"
            name="tenant-accept_terms_and_conditions"
          />
        </div>
        <div className="flex layout-padding" >
          <label className="pointy" htmlFor="tenant-accept_terms_and_conditions">
            <p style={{ margin: 0, fontSize: '13px' }}>
              I hereby confirm that I have read and agree to the {capitalize(subdomain)} {' '}
              <span
                className="emulate_link blue_link"
                onClick={goToTermsAndConditions}
              >
                terms and conditions
              </span>
              .
            </p>
          </label>
        </div>
      </div>

      <div className={`${shakeClass.imc} flex-90 layout-row layout-align-center-center`}>
        <div className="flex-5 layout-row layout-align-start-start">
          <Checkbox
            id="imc-accept_terms_and_conditions"
            theme={theme}
            onChange={handleChange}
            checked={accepted.imc}
            size="18px"
            name="imc-accept_terms_and_conditions"
          />
        </div>
        <div className="flex layout-padding">
          <label className="pointy" htmlFor="imc-accept_terms_and_conditions">
            <p style={{ margin: 0, fontSize: '13px' }}>
              I hereby confirm that I have read and agree to the ItsMyCargo  {' '}
              <span
                className="emulate_link blue_link"
                onClick={goToImcTermsAndConditions}
              >
                terms and conditions
              </span>
              .
            </p>
          </label>
        </div>
      </div>

    </div>
  )
}

TermsAndConditionsSummary.propTypes = {
  theme: PropTypes.theme,
  tenant: PropTypes.tenant,
  handleChange: PropTypes.func.isRequired,
  accepted: PropTypes.shape({
    imc: PropTypes.bool,
    tenant: PropTypes.bool
  }),
  shakeClass: PropTypes.shape({
    imc: PropTypes.bool,
    tenant: PropTypes.bool
  }),
  goToTermsAndConditions: PropTypes.func.isRequired,
  goToImcTermsAndConditions: PropTypes.func.isRequired
}

TermsAndConditionsSummary.defaultProps = {
  theme: null,
  tenant: null,
  accepted: {
    imc: false,
    tenant: false
  },
  shakeClass: {
    imc: false,
    tenant: false
  }
}
