import React from 'react'
import { connect } from 'react-redux'
import { push } from 'react-router-redux'
import { bindActionCreators } from 'redux'
import { withNamespaces } from 'react-i18next'
import styles from './LandingTop.scss'
import { get } from 'lodash'
import SquareButton from '../SquareButton'
import { adminActions } from '../../actions'

const MyAccount = connect(null, (dispatch) => (
  { toAccount: () => dispatch(push('/account')) }
))(withNamespaces(['common'])(({
  user, tenant, theme, toAccount, t
}) => (
  ['shipper', 'agent', 'agency_manager'].includes(get(user, ['role', 'name'])) &&
    !user.guest &&
    !(get(tenant, 'scope.closed_quotation_tool')) && (
    <div className="layout-row flex-100 flex-gt-sm-50 margin_bottom">
      <SquareButton
        text={t('common:accountTitle')}
        theme={theme}
        handleNext={toAccount}
        size="small"
        active
      />
    </div>
  )
)))

const ToAdmin = connect(null, (dispatch) => (
  { adminDispatch: bindActionCreators(adminActions, dispatch) }
))(withNamespaces(['landing'])(({
  user, theme, adminDispatch, t
}) => (
  ['admin', 'sub_admin', 'super_admin'].includes(get(user, ['role', 'name'])) && (
    <div className="layout-row flex-100 flex-gt-sm-50 margin_bottom">
      <SquareButton
        text={t('landing:adminDashboard')}
        theme={theme}
        handleNext={() => adminDispatch.getDashboard(true)}
        size="small"
        active
      />
    </div>
  )
)))

const FindRates = withNamespaces(['landing'])(({
  user, theme, bookNow, t
}) => (
  (!user || ['shipper', 'agent', 'agency_manager'].includes(get(user, ['role', 'name']))) && (
    <div className="layout-row flex-100 flex-gt-sm-50 margin_bottom">
      <SquareButton text={t('landing:callToAction')} classNames="ccb_find_rates" theme={theme} handleNext={bookNow} size="small" active />
    </div>
  )
))

const ButtonSection = ({
  user, tenant, theme, bookNow, className, t, showLogo
}) => {
  const buttonProps = { user, tenant, theme }

  return (
    <div className={`
      ${styles.content_wrapper} ${className} flex-100 layout-row layout-wrap layout-align-center-center
    `}
    >
      <div className={`layout-row layout-wrap layout-align-start-center ${styles.wrapper_btns} flex-75`}>
        <MyAccount {...buttonProps} />
        <ToAdmin {...buttonProps} />
        <FindRates {...buttonProps} bookNow={bookNow} />
      </div>
      <div className={`flex-75 ${styles.banner_text}`}>
        {showLogo ? (
          <div className="flex layout-row flex-100 banner_text">
            <div className="flex-none layout-row layout-align-start-center">
              <h4 className="flex-none">{t('landing:poweredBy')}</h4>
              <a
                className="layout-row flex-offset-10 layout-align-center-center"
                href="https://www.itsmycargo.com/"
                target="_blank"
              >
                <img
                  src="https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png"
                  alt=""
                  className={`flex-none pointy ${styles.powered_by_logo}`}
                />
              </a>
            </div>
          </div>
        ) : ''}
      </div>
    </div>
  )
}

ButtonSection.defaultProps = {
  theme: null,
  user: null,
  tenant: null,
  bookNow: null,
  className: '',
  showLogo: true
}

export default withNamespaces(['landing'])(ButtonSection)
