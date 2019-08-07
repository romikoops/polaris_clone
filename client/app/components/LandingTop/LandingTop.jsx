import React from 'react'
import { withNamespaces } from 'react-i18next'
import styled from 'styled-components'
import styles from './LandingTop.scss'
import Header from '../Header/Header'
import ButtonSection from './ButtonSection'
import { isQuote, contentToHtml } from '../../helpers'
import withContent from '../../hocs/withContent'

const StyledTop = styled.div`
  background-image: linear-gradient(rgba(0, 0, 0, 0.3), rgba(0, 0, 0, 0.3)),
    url(${props => props.bg});
  height: 100vh;
  background-size: cover;
  background-attachment: fixed;
  background-position: center;
  padding-bottom: 150px;
  box-shadow: 0px 1px 15px rgba(0, 0, 0, 0.7);
  position: relative;
`

function LandingTop ({
  theme, user, tenant, bookNow, t, content
}) {
  const backgroundImage =
    theme && theme.background
      ? theme.background
      : 'https://assets.itsmycargo.com/assets/images/welcome/country/header.jpg'

  const largeLogo = theme && theme.logoLarge ? theme.logoLarge : ''
  const whiteLogo = theme && theme.logoWhite ? theme.logoWhite : largeLogo

  function determineWelcomeTail () {
    if (theme && theme.welcome_text) {
      return theme.welcome_text
    }

    if (isQuote(tenant)) {
      return t('landing:welcomeTextQuoteTail')
    }

    return t('landing:welcomeTextShopTail')
  }

  const welcomeTextTail = determineWelcomeTail()

  const buttonSectionProps = {
    theme, user, tenant, bookNow
  }
  const defaultContent = [
    (<img
      src={whiteLogo}
      alt=""
      className="flex-none tenant_logo_landing"
    />),
    (<h2 className="flex-none">
      <b>{t('landing:welcomeTextHead')}</b>
      <br />
      <i>
        {tenant.name}
      </i>
      <br />
      <b>
        {welcomeTextTail}
      </b>
    </h2>),
    (<div className="wrapper_hr">
      <hr />
    </div>),
    (<div className="wrapper_h3">
      {isQuote(tenant) ? (
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
    </div>)
  ]

  const contentToRender = content && content.welcome ? contentToHtml(content.welcome) : defaultContent

  return (
    <StyledTop className="layout-row flex-100 layout-align-center" bg={backgroundImage} tenant={tenant}>
      <div className="layout-row flex-100 layout-wrap">
        <div className="flex-100 layout-row">
          <Header user={user} theme={theme} isLanding scrollable invert noMessages />
        </div>
        <div className="flex-50 layout-row layout-align-center layout-wrap">
          <div className={`${styles.content_wrapper} flex-100 layout-row layout-wrap layout-align-center-center`}>
            <div className="flex-75 banner_text">
              { contentToRender }
            </div>
            <ButtonSection {...buttonSectionProps} className="hide_h_xxs" />
          </div>
        </div>
        <div className="flex-50 layout-row layout-align-center layout-wrap">
          <ButtonSection {...buttonSectionProps} className="hide_h_gt_xxs" />
        </div>
      </div>
    </StyledTop>
  )
}

LandingTop.defaultProps = {
  theme: null,
  user: null,
  tenant: null,
  bookNow: null
}
export const translatedLandingTop = withNamespaces(['common', 'landing'])(LandingTop)
const contentLandingTop = withContent(translatedLandingTop, 'LandingTop')
export default contentLandingTop
