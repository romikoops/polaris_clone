import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './index.scss'
import TextHeading from '../../../TextHeading/TextHeading'
import { RoundButton } from '../../../RoundButton/RoundButton'

function AdminPromptConfirm ({
  heading, theme, text, confirm, deny, t
}) {
  return (
    <div className={`${styles.confirm_backdrop} flex-none layout-row layout-align-center-center`}>
      <div
        className={`${styles.confirm_fade} flex-none layout-row layout-align-center-center`}
        onClick={e => deny(e)}
      />
      <div
        className={`${
          styles.confirm_box
        } flex-none layout-row layout-wrap layout-align-center-space-around`}
      >
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <TextHeading theme={theme} text={heading} size={3} />
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <p className="flex-none">{text}</p>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <div className="flex-50 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="small"
              text={t('common:cancel')}
              handleNext={e => deny(e)}
              iconClass="fa-ban"
            />
          </div>
          <div className="flex-50 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="small"
              active
              text={t('admin:confirm')}
              handleNext={e => confirm(e)}
              iconClass="fa-check"
            />
          </div>
        </div>
      </div>
    </div>
  )
}
AdminPromptConfirm.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme.isRequired,
  heading: PropTypes.string,
  text: PropTypes.string,
  confirm: PropTypes.func.isRequired,
  deny: PropTypes.func.isRequired
}

AdminPromptConfirm.defaultProps = {
  heading: '',
  text: ''
}

export default withNamespaces('admin')(AdminPromptConfirm)
