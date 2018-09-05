import React from 'react'
import styles from './Footer.scss'
import defs from '../../styles/default_classes.scss'
import PropTypes from '../../prop-types'
import { moment } from '../../constants'

export function Footer ({
  theme, tenant, isShop, width
}) {
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
            <div className="flex-50 layout-row layout-align-end-end">
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
      <div className={`${isShop ? styles.footer_shop : styles.footer
      } layout-row flex-100 layout-wrap`}
      >
        <div className={`flex-100 ${styles.button_row}
         layout-row layout-align-end-center`}
        >
          <div className={`flex-50 ${styles.buttons}
           layout-row layout-align-center-center`}
          >
            <div className="flex-50 layout-row layout-align-start-center">
              <div className="flex-5" />
              <p className="flex-none">powered by</p>
              <div className="flex-5" />
              <img
                src="https://assets.itsmycargo.com/assets/logos/Logo_transparent_white.png"
                alt=""
                className={`flex-none ${styles.powered_by_logo}`}
              />
            </div>
          </div>
          <div className={`flex-50 ${styles.buttons} layout-row layout-align-end-center`}>
            <div className="flex-25 layout-row layout-align-center-center">
              <a
                target="_blank"
                href={links && links.about ? links.about : defaultLinks.about}
              >
                About Us
              </a>
            </div>
            <div className="flex-25 layout-row layout-align-center-center">
              <a
                target="_blank"
                href={links && links.privacy ? links.privacy : defaultLinks.privacy}
              >
                Privacy Policy
              </a>
            </div>
            <div className="flex-25 layout-row layout-align-center-center">
              <a
                target="_blank"
                href={`https://${tenant.subdomain}.itsmycargo.com/terms_and_conditions`}
              >
                Terms and Conditions
              </a>
            </div>
            <div className="flex-25 layout-row layout-align-center-center">
              <a
                target="_blank"
                href={links && links.legal ? links.legal : defaultLinks.legal}
              >
                Legal
              </a>
            </div>
          </div>
          { isShop
            ? <div className={`flex-20 ${styles.copyright_shop}`}>
              <p className="flex-none">
                  Copyright © {moment().format('YYYY')} {tenantName}
              </p>
            </div>
            : <div className="flex-20" />
          }
        </div>
        { isShop
          ? <div />
          : <div className={`flex-100 layout-row 
            ${styles.copyright}`}
          >
            <div className="flex-80 layout-row layout-align-end-center">
              <p className="flex-none">
                Copyright © {moment().format('YYYY')} {tenantName}
              </p>
            </div>
            <div className="flex-20" />
          </div>
        }
      </div>
    </div>
  )
}

Footer.propTypes = {
  theme: PropTypes.theme,
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

export default Footer
