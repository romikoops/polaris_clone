import React from 'react'
import { translate } from 'react-i18next'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import styles from './LandingTop.scss'
import Header from '../Header/Header'
import ButtonSection from './ButtonSection'

const StyledTop = styled.div`
  background-image: linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)),
    url(${props => props.bg});
  height: 100vh;
  background-size: cover;
  background-attachment: fixed;
  background-position: center;
  padding-bottom: 120px;
  box-shadow: 0px 1px 15px rgba(0, 0, 0, 0.7);
  position: relative;
`

function LandingTop ({
  theme, user, tenant, bookNow, t
}) {
  const backgroundImage =
    theme && theme.background
      ? theme.background
      : 'https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg'

  const largeLogo = theme && theme.logoLarge ? theme.logoLarge : ''
  const whiteLogo = theme && theme.logoWhite ? theme.logoWhite : largeLogo
  const isQuote = (tenant && tenant.data && tenant.data.scope) &&
    (tenant.data.scope.closed_quotation_tool || tenant.data.scope.open_quotation_tool)

  function determineWelcomeTail () {
    if (theme && theme.welcome_text) {
      return theme.welcome_text
    } else if (isQuote) {
      return t('landing:welcomeTextQuoteTail')
    }

    return t('landing:welcomeTextShopTail')
  }

  const welcomeTextTail = determineWelcomeTail()

  const buttonSectionProps = {
    theme, user, tenant, bookNow
  }

  return (
    <StyledTop className="layout-row flex-100 layout-align-center" bg={backgroundImage}>
      <div className="layout-row flex-100 layout-wrap">
        <div className="flex-100 layout-row">
          <Header user={user} theme={theme} isLanding scrollable invert noMessages />
        </div>
        <div className="flex-50 layout-row layout-align-center layout-wrap">
          <div className={`${styles.content_wrapper} flex-100 layout-row layout-wrap layout-align-center-center`}>
            <div className={`flex-75 ${styles.banner_text}`}>
              <img
                src={whiteLogo}
                alt=""
                className={`flex-none ${styles.tenant_logo_landing}`}
              />
              <h2 className="flex-none">
                <b>{t('landing:welcomeTextHead')}</b> <br />
                <i> {tenant.data.name} </i> <b> <br />
                  {welcomeTextTail}</b>
              </h2>
              <div className={styles.wrapper_hr}>
                <hr />
              </div>
              <div className={styles.wrapper_h3}>
                {isQuote ? (
                  <h3 className="flex-none">
                    {t('landing:descriptionQuoteHead')}
                    <b>{t('landing:descriptionQuoteMiddle')}</b>
                    {t('landing:descriptionQuoteTail')}
                  </h3>
                ) : (
                  <h3 className="flex-none">
                    {t('landing:descriptionShopHead')}
                    <b>{t('landing:descriptionShopMiddle')}</b>
                    {t('landing:descriptionShopTail')}
                  </h3>
                )
                }
              </div>
            </div>
            <ButtonSection {...buttonSectionProps} hidden={window.innerHeight <= 750} />
          </div>
        </div>
        <div className="flex-50 layout-row layout-align-center layout-wrap">
          <ButtonSection {...buttonSectionProps} hidden={window.innerHeight > 750} />
        </div>
      </div>
    </StyledTop>
  )
}

LandingTop.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.user,
  tenant: PropTypes.tenant,
  t: PropTypes.func.isRequired,
  bookNow: PropTypes.func
}

LandingTop.defaultProps = {
  theme: null,
  user: null,
  tenant: null,
  bookNow: null
}

export default translate(['common', 'landing'])(LandingTop)
