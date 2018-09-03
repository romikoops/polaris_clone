import React from 'react'
import styles from './Footer.scss'
import defs from '../../styles/default_classes.scss'
import PropTypes from '../../prop-types'
import { moment } from '../../constants'
import { ROW, ALIGN_CENTER, trim } from '../../classNames'

const CONTAINER = `FOOTER flex-100 layout-row layout-wrap ${styles.footer_wrapper}`
const ENVELOPE_ICON = 'fa fa-envelope'
const PHONE_ICON = 'fa fa-phone'

export function Footer ({ theme, tenant, isShop }) {
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

  return (
    <div className={CONTAINER} >
      {isShop
        ? <div />
        : <div className={`${styles.contact_bar} ${ROW(100)} ${ALIGN_CENTER}`}>
          <div className={`${ROW('none')} ${defs.content_width}`}>
            <div className="flex-50 layout-row layout-align-start-center">
              <img src={logo} />
            </div>

            <div className="flex-50 layout-row layout-align-end-end">
              <a
                className={trim(`
                  ${ROW('none')} 
                  ${ALIGN_CENTER}
                  pointy 
                  ${styles.contact_elem}
                `)}
                href={`mailto:${supportEmail}`}
              >
                <i className={ENVELOPE_ICON} aria-hidden="true" style={primaryColor} />
                {supportEmail}
              </a>

              <div className={trim(`
                ${ROW('none')} 
                layout-align-center-end
               ${styles.contact_elem}
               `)}
              >
                <i className={PHONE_ICON} aria-hidden="true" style={primaryColor} />
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
  isShop: PropTypes.bool
}

Footer.defaultProps = {
  theme: {},
  tenant: {},
  isShop: false
}

export default Footer
