import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './UserAccount.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { LoadingSpinner } from '../LoadingSpinner/LoadingSpinner'

const EditProfileBox = ({
  user, handleChange, onSave, close, style, theme, handlePasswordChange, passwordResetSent, passwordResetRequested, t, hide
}) => !hide && (
  <div className={`flex-100 layout-row layout-align-start-start layout-wrap section_padding ${styles.content_details}`}>
    <div className="layout-row flex-90" />
    <div className="flex-10 layout-row layout-align-end-center layout-wrap">
      <span className="layout-row flex-100 layout-align-center-stretch">
        <div
          onClick={onSave}
          className={`layout-row flex-50 ${styles.save} layout-align-center-center`}
        >
          <i className="fa fa-check" />
        </div>
        <div
          onClick={close}
          className={`layout-row flex-50 ${styles.cancel} layout-align-center-center`}
        >
          <i className="fa fa-times" />
        </div>
      </span>
    </div>
    <div
      className={`flex-100 layout-row layout-align-start-start layout-wrap
      ${styles.margin_top} margin_bottom`}
    >
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
          {t('user:company')}
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-90 ${styles.input_style}`}
          type="text"
          value={user.company_name}
          onChange={handleChange}
          name="company_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap margin_bottom">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
          {t('user:firstName')}
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-none ${styles.input_style}`}
          type="text"
          value={user.first_name}
          onChange={handleChange}
          name="first_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap margin_bottom">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
          {t('user:lastName')}
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-none ${styles.input_style}`}
          type="text"
          value={user.last_name}
          onChange={handleChange}
          name="last_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap margin_bottom">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
          {t('user:email')}
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-none ${styles.input_style}`}
          type="text"
          value={user.email}
          onChange={handleChange}
          name="email"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
          {t('user:phone')}
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-none ${styles.input_style}`}
          type="text"
          value={user.phone}
          onChange={handleChange}
          name="phone"
        />
      </div>
    </div>
    <div
      className={`flex-100 layout-row layout-align-center layout-wrap padding_top ${styles.form_group_submit_btn}`}
    >
      <div className="flex-50 layout-row layout-align-start-center">
        <RoundButton
          theme={theme}
          size="medium"
          active
          text={t('user:changeMyPassword')}
          handleNext={handlePasswordChange}
        />
      </div>
      <div className={`${styles.spinner} flex-50 layout-row layout-align-start-start`}>
        {passwordResetRequested &&
        <LoadingSpinner
          size="extra_small"
        />}
      </div>
      { passwordResetSent && (
        <div className="flex-100 layout-row layout-align-center-start padding_top">
          <p>
            {t('user:checkForPassword')}
          </p>
        </div>
      )}
    </div>
  </div>
)

EditProfileBox.propTypes = {
  user: PropTypes.user.isRequired,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  handleChange: PropTypes.func.isRequired,
  onSave: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  style: PropTypes.objectOf(PropTypes.string),
  handlePasswordChange: PropTypes.func.isRequired,
  passwordResetSent: PropTypes.bool.isRequired,
  passwordResetRequested: PropTypes.bool.isRequired,
  hide: PropTypes.bool.isRequired
}

EditProfileBox.defaultProps = {
  style: {},
  theme: null
}

export default withNamespaces('user')(EditProfileBox)
