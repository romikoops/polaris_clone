import React from 'react'
import { connect } from 'react-redux'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { cookieActions } from '../../actions'
import styles from './Footer.scss'
import SquareButton from '../SquareButton'

class Footer extends React.PureComponent {
  componentWillUnmount () {
    this.props.cookieDispatch.updateCookieHeight({ height: 0 })
  }

  render () {
    const {
      theme, tenant, width, t, cookieDispatch, bookNow
    } = this.props

    if (!tenant) {
      return ''
    }
    const primaryColor = {
      color: theme && theme.colors ? theme.colors.primary : 'black'
    }
    let logo = theme && theme.logoLarge ? theme.logoLarge : ''
    if (!logo && theme && theme.logoSmall) logo = theme.logoSmall
    const supportNumber = tenant && tenant.phones ? tenant.phones.support : ''
    const supportEmail = tenant && tenant.emails ? tenant.emails.support.general : ''
    const links = tenant && tenant.scope ? tenant.scope.links : {}
    const defaultLinks = {
      privacy: 'https://itsmycargo.com/en/privacy',
      about: 'https://www.itsmycargo.com/en/ourstory',
      legal: 'https://www.itsmycargo.com/en/contact'
    }
    let termsLink = ''
    tenant.subdomain ? termsLink = `https://${tenant.subdomain}.itsmycargo.com/terms_and_conditions` : termsLink = ''

    // TODO: implement Social Links
    const socialLinks = null

    return (
      <div
        className={`flex-100 layout-row layout-wrap ${styles.footer}`}
        ref={(div) => {
          if (!div) return
          cookieDispatch.updateCookieHeight({ height: div.offsetHeight })
        }}
      >
        <div className="flex-50 flex-gt-sm-40 flex-order--2 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100 layout-row layout-align-start-start">
            <img className={styles.logo} src={logo} />
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <h4 className={`flex-none ${styles.powered_by_padding}`}>
              {t('footer:poweredBy')}
            </h4>
            <div className="flex-5" />
            <a href="https://www.itsmycargo.com/" target="_blank">
              <img
                src="https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png"
                alt=""
                className={`flex-none pointy ${styles.powered_by_logo}`}
              />
            </a>
          </div>
          <div className={`flex-100 ${styles.contacts}`}>
            <a
              className="pointy"
              href={`mailto:${supportEmail}`}
            >
              <i className="fa fa-envelope" aria-hidden="true" style={primaryColor} />
              {supportEmail}
            </a>
            <div>
              <i className="fa fa-phone" aria-hidden="true" style={primaryColor} />
              {supportNumber}
            </div>
          </div>
        </div>
        <div className="flex-50 flex-gt-sm-20 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100">
            <a className={styles.title} target="_blank" href={links && links.about ? links.about : defaultLinks.about}>
              {t('footer:about')}
            </a>
          </div>
        </div>
        <div className="flex-50 flex-gt-sm-20 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100">
            <h4 className={styles.title}>
              {t('footer:legal')}
            </h4>
          </div>
          <ul>
            <li>
              <a target="_blank" href={links && links.legal ? links.legal : defaultLinks.legal}>
                {t('footer:imprint')}
              </a>
            </li>
            <li>
              <a target="_blank" href={termsLink}>
                {t('footer:terms')}
              </a>
            </li>
            <li>
              <a target="_blank" href={links && links.privacy ? links.privacy : defaultLinks.privacy}>
                {t('footer:privacy')}
              </a>
            </li>
          </ul>
        </div>
        <div
          className="
            flex-50 flex-gt-sm-20 flex-order--1 flex-order-gt-sm-4
            layout-row layout-wrap layout-align-start-start
          "
        >
          <div className="flex-100 layout-row layout-align-start">
            {
              socialLinks
                ? (
                  <h4 className={styles.title}>
                    {t('footer:social')}
                  </h4>
                )
                : (
                  <SquareButton
                    text={t('landing:callToAction')}
                    theme={theme}
                    active
                    handleNext={bookNow}
                    size="small"
                  />
                )
            }
          </div>
        </div>
      </div>
    )
  }
}

Footer.defaultProps = {
  theme: {},
  tenant: {},
  width: null
}

function mapDispatchToProps (dispatch) {
  return {
    cookieDispatch: bindActionCreators(cookieActions, dispatch)
  }
}

export default connect(null, mapDispatchToProps)(withNamespaces('footer')(Footer))
