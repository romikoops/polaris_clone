import React from 'react'
import { connect } from 'react-redux'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import styles from './Footer.scss'
import { socialIcons, isQuote } from '../../helpers'
import SquareButton from '../SquareButton'
import FooterLinks from './FooterLinks'

class Footer extends React.PureComponent {
  render () {
    const {
      theme, tenant, t, bookNow
    } = this.props

    if (!tenant) {
      return ''
    }
    const checkTenantScope = tenant && tenant.scope
    let logo = theme && theme.logoWhite ? theme.logoWhite : ''
    if (!logo && theme && theme.logoSmall) logo = theme.logoSmall
    const supportNumber = tenant && tenant.phones ? tenant.phones.support : ''
    const supportEmail = tenant && tenant.emails ? tenant.emails.support.general : ''
    const links = checkTenantScope ? tenant.scope.links : {}
    const socialLinks = checkTenantScope ? tenant.scope.social_links : {}
    const isQuotationShop = isQuote(tenant)
    const home = links && links.home ? links.home : 'https://www.itsmycargo.com/en/'
    const filteredSocialLinks = socialLinks ? Object.entries(socialLinks).filter((array) => array[1] !== '') : []
    const oo = filteredSocialLinks.map((value) => {
      const social = value[0]
      const link = value[1]

      return socialIcons(social, link)
    })

    return (
      <div
        className={`flex-100 layout-row layout-wrap layout-align-center-start ${styles.footer}`}
      >
        <div className={`flex-20 flex-gt-sm-20 layout-row layout-wrap layout-align-center-center ${styles.banner_text}`}>
          {isQuotationShop ? '' : (
            <a
              href={home}
              target="_blank"
            >
              <img className={styles.logo} src={logo} />
            </a>
          ) }
          <div className="flex-100 flex-gt-sm-100 layout-align-center-center layout-row">
            <h4 className="flex-none">{t('footer:poweredBy')}</h4>
            <a
              className="layout-row flex-none layout-align-start-center"
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
        <div className="flex-25 flex-gt-sm-25 layout-row layout-wrap layout-align-start-start">
          <div className="flex-25 layout-wrap layout-row">
            <h4 className={styles.title}>
              {t('footer:contact')}
            </h4>
          </div>

          <div className={`flex-100 layout-row layout-wrap ${styles.contacts}`}>
            <a
              className="pointy flex-100 layout-row layout-align-start-center"
              href={`mailto:${supportEmail}`}
            >
              <i className="fa fa-envelope" aria-hidden="true" />
              {supportEmail}
            </a>
            <div className="flex-100 layout-row layout-align-start-center">
              <i className="fa fa-phone" aria-hidden="true" />
              {supportNumber}
            </div>
            <div className={`flex-100 layout-row ${styles.social_links}`}>
              {oo}
            </div>
          </div>
        </div>
        <div className="flex-25 flex-gt-sm-25 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100 layout-wrap layout-row">
            <h4 className={styles.title}>
              {t('footer:company')}
            </h4>
          </div>
          <FooterLinks
            tenant={tenant}
          />
        </div>
        <div
          className="
            flex-50 flex-gt-sm-20 flex-order--4 flex-order-gt-sm-4
            layout-row layout-wrap layout-align-start-start
          "
        >
          <div className="flex-100 layout-row layout-align-start">
            <SquareButton
              text={t('landing:callToAction')}
              theme={theme}
              active
              handleNext={bookNow}
              size="small"
            />
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

export default withNamespaces(['footer'])(Footer)
