import React from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import styles from './UserAccount.scss'
import { NamedSelect } from '../NamedSelect/NamedSelect'

const EditProfileBox = ({
  user,
  handleChange,
  style,
  currentCurrency,
  currencyOptions,
  handleCurrencyChange,
  t,
  hide,
  scope
}) => {
  const restrictions = get(scope, ['user_restrictions', 'profile'])

  return !hide && (
    <div className={`flex-100 layout-row layout-align-start-start layout-wrap section_padding ${styles.content_details}`}>
      {!restrictions.name && (
        <div
          className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.margin_top} margin_bottom`}
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
      )}
      {!restrictions.name && (
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
      )}
      {!restrictions.name && (
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
      )}
      {!restrictions.company && (
        <div className="flex-50 layout-row layout-align-start-start layout-wrap margin_bottom">
          <div className="flex-100 layout-row layout-align-start-start ">
            <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
              {t('user:vatNo')}
            </sup>
          </div>
          <div className="input_box flex-100 layout-row layout-align-start-center ">
            <input
              className={`flex-none ${styles.input_style}`}
              type="text"
              value={user.vat_number}
              onChange={handleChange}
              name="vat_number"
            />
          </div>
        </div>
      )}
      {!restrictions.company && (
        <div className="flex-50 layout-row layout-align-start-start layout-wrap margin_bottom">
          <div className="flex-100 layout-row layout-align-start-start ">
            <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
              {t('user:companyNumber')}
            </sup>
          </div>
          <div className="input_box flex-100 layout-row layout-align-start-center ">
            <input
              className={`flex-none ${styles.input_style}`}
              type="text"
              value={user.company_number}
              onChange={handleChange}
              name="company_number"
            />
          </div>
        </div>
      )}
      {!restrictions.email && (
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
        </div>)}
      {!restrictions.phone && (
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
      )}
      {(!scope.fixed_currency && !restrictions.currency) && (
        <div className="flex-50 layout-row layout-align-start-start layout-wrap">
          <div className="flex-100 layout-row layout-align-start-start ">
            <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
              {t('common:currency')}
            </sup>
          </div>
          <div className="input_box flex-100 layout-row layout-align-start-center ">
            <NamedSelect
              className="flex-100"
              options={currencyOptions}
              value={currentCurrency}
              placeholder={t('common:selectCurrency')}
              onChange={e => handleCurrencyChange(e)}
            />
          </div>
        </div>) }
    </div>
  )
}

EditProfileBox.defaultProps = {
  style: {},
  theme: null
}

export default withNamespaces('user')(EditProfileBox)
