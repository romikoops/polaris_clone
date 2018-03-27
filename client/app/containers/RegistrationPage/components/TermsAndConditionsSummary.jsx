import React from 'react'
import { v4 } from 'node-uuid'
import styles from '../RegistrationPage.scss'
import { Checkbox } from '../../../components/Checkbox/Checkbox'
import PropTypes from '../../../prop-types'

export default function TermsAndConditionsSummary (props) {
  const {
    theme, handleChange, accepted, goToTermsAndConditions
  } = props
  const bulletTexts = [
    'Exporting or importing company must be registered and approved by local country ' +
    'authorities. Financial rating will be checked and evaluated before arranging the shipment.',

    'After sending your booking request, the request will be reviewed by Greencarrier ' +
    'and confirmation will be sent.',

    'Pricing in booking request is only valid for commercial cargo. ' +
    'Personal effect shipments are not accepted. ' +
    'Restricted cargo, weapons, explosives, temperature control and live animals are not accepted.'
  ]

  const bullets = bulletTexts.map(bulletText => <li key={v4()}> { bulletText } </li>)

  return (
    <div className={styles.terms_and_conditions_summary}>
      <h3> Before registering your account, please consider the following: </h3>
      <ul>
        {bullets}
      </ul>
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
  handleChange: PropTypes.func.isRequired,
  accepted: PropTypes.bool,
  goToTermsAndConditions: PropTypes.func.isRequired
}

TermsAndConditionsSummary.defaultProps = {
  theme: null,
  accepted: PropTypes.false
}
