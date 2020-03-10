import React from 'react'
import { has, isEmpty } from 'lodash'
import { withNamespaces } from 'react-i18next'
import { openConsentManager } from '@itsmycargo/consent-manager'

function FooterLinks (props) {
  const { tenant, t } = props
  const { scope } = tenant
  const { links } = scope

  const defaultLinks = {
    privacy: 'https://www.itsmycargo.com/en/privacy',
    about: 'https://www.itsmycargo.com/en/ourstory',
    legal: 'https://www.itsmycargo.com/en/contact',
    terms: 'https://www.itsmycargo.com/legal/terms-of-service'
  }

  let termsLink = ''
  tenant.slug ? termsLink = '/terms_and_conditions' : termsLink = defaultLinks.terms
  if (has(tenant, ['scope', 'links', 'terms'])) {
    termsLink = tenant.scope.links.terms
  }

  const aboutLink = links && !isEmpty(links.about) ? links.about : defaultLinks.about
  const legalLink = links && !isEmpty(links.legal) ? links.legal : defaultLinks.legal
  const privacyLink = links && !isEmpty(links.privacy) ? links.privacy : defaultLinks.privacy

  const openConsent = (event) => {
    event.preventDefault()

    openConsentManager()

    return false
  }

  return (
    <ul>
      <li>
        <a target="_parent" href={aboutLink}>
          {t('footer:about')}
        </a>
      </li>
      <li>
        <a target="_parent" href={legalLink}>
          {t('footer:imprint')}
        </a>
      </li>
      <li>
        <a target="_parent" href={termsLink}>
          {t('footer:terms')}
        </a>
      </li>
      <li>
        <a target="_parent" href={privacyLink}>
          {t('footer:privacy')}
        </a>
      </li>
      <li>
        <a href="" onClick={openConsent}>
          {t('footer:website_data_collection')}
        </a>
      </li>
    </ul>
  )
}
export default withNamespaces('footer')(FooterLinks)
