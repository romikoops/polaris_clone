import React from 'react'
import { translate } from 'react-i18next'
import styles from './Footer.scss'
import defs from '../../styles/default_classes.scss'
import PropTypes from '../../prop-types'

function Footer ({
  theme, tenant, isShop, width, t
}) {
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
  const tenantName = tenant ? tenant.name : ''
  const links = tenant && tenant.scope ? tenant.scope.links : {}
  const defaultLinks = {
    privacy: 'https://itsmycargo.com/en/privacy',
    about: 'https://www.itsmycargo.com/en/ourstory',
    legal: 'https://www.itsmycargo.com/en/contact'
  }
  let termsLink = ''
  tenant.subdomain ? termsLink = `https://${tenant.subdomain}.itsmycargo.com/terms_and_conditions` : termsLink = ''

  const widthStyle = width ? { width } : {}

  return (
    <div
      className={`flex-100 layout-row 
      layout-wrap ${styles.footer_wrapper} layout-align-start`}
      style={widthStyle}
    >
      {isShop
        ? <div />
        : <div className={`${styles.contact_bar}
         flex-100 layout-row layout-align-center-center`}
        >
          <div className={`flex-none ${defs.content_width} layout-row`}>
            <div className="flex-50 layout-row layout-align-start-center">
              <img src={logo} />
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              <a
                className={`flex-none layout-row layout-align-center-center pointy ${
                  styles.contact_elem
                }`}
                href={`mailto:${supportEmail}`}
              >
                <i className="fa fa-envelope" aria-hidden="true" style={primaryColor} />
                {supportEmail}
              </a>
              <div className={`flex-none layout-row layout-align-center-end
               ${styles.contact_elem}`}
              >
                <i className="fa fa-phone" aria-hidden="true" style={primaryColor} />
                {supportNumber}
              </div>
            </div>
          </div>
        </div>
      }
      <div className={`${styles.footer_shop} layout-row flex-100 layout-wrap`}>
        <div className="flex-100 layout-align-center">
          <div className={`flex-100 ${styles.buttons} ${styles.upper_footer} layout-row layout-align-space-around-center`}>
            <div className="flex-35 layout-row layout-align-center-center">
              <div className="flex-none layout-row layout-align-center-center">
                <h4 className={`flex-none ${styles.powered_by_padding}`}>
                  {t('footer:poweredBy')}
                </h4>                <div className="flex-5" />
                <a href="https://www.itsmycargo.com/" target="_blank">
                  <img
                    src="https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png"
                    alt=""
                    className={`flex-none pointy ${styles.powered_by_logo}`}
                  />
                </a>
              </div>
            </div>
            <div className="flex-15 layout-row layout-align-center-center">
              <a
                target="_blank"
                href={links && links.about ? links.about : defaultLinks.about}
              >
                {t('footer:about')}
              </a>
            </div>
            <div className="flex-15 layout-row layout-align-center-center">
              <a
                target="_blank"
                href={links && links.privacy ? links.privacy : defaultLinks.privacy}
              >
                {t('footer:privacy')}
              </a>
            </div>
            <div className="flex-15 layout-row layout-align-center-center">
              <a
                target="_blank"
                href={termsLink}
              >
                {t('footer:terms')}
              </a>
            </div>
            <div className="flex-15 layout-row layout-align-center-center">
              <a
                target="_blank"
                href={links && links.legal ? links.legal : defaultLinks.legal}
              >
                {t('footer:legal')}
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

Footer.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  tenant: PropTypes.tenant,
  isShop: PropTypes.bool,
  width: PropTypes.number
}

Footer.defaultProps = {
  theme: {},
  tenant: {},
  isShop: false,
  width: null
}

export default translate('footer')(Footer)
