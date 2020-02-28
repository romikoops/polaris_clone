import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'

import FooterLinks from './FooterLinks'

const tenant = {
  scope: {
    links: {
      about: '1',
      legal: '2',
      terms: '3',
      privacy: '4'
    }
  }
}

const noLinksTenant = {
  scope: {
    links: {}
  }
}

const defaultLinks = {
  privacy: 'https://itsmycargo.com/en/privacy',
  about: 'https://www.itsmycargo.com/en/ourstory',
  legal: 'https://www.itsmycargo.com/en/contact',
  terms: 'https://www.itsmycargo.com/legal/terms-of-service'
}

test('when props with links are passed', () => {
  const footerLinks = shallow(<FooterLinks tenant={tenant} />)
  const aboutLink = footerLinks.find('a').at(0).props().href
  const legalLink = footerLinks.find('a').at(1).props().href
  const termsLink = footerLinks.find('a').at(2).props().href
  const privacyLink = footerLinks.find('a').at(3).props().href

  expect(footerLinks).toMatchSnapshot()
  expect(aboutLink).toBe(tenant.scope.links.about)
  expect(legalLink).toBe(tenant.scope.links.legal)
  expect(termsLink).toBe(tenant.scope.links.terms)
  expect(privacyLink).toBe(tenant.scope.links.privacy)
})

test('when props with links are not passed', () => {
  const footerLinks = shallow(<FooterLinks tenant={noLinksTenant} />)
  const aboutLink = footerLinks.find('a').at(0).props().href
  const legalLink = footerLinks.find('a').at(1).props().href
  const termsLink = footerLinks.find('a').at(2).props().href
  const privacyLink = footerLinks.find('a').at(3).props().href

  expect(footerLinks).toMatchSnapshot()
  expect(aboutLink).toBe(defaultLinks.about)
  expect(legalLink).toBe(defaultLinks.legal)
  expect(termsLink).toBe(defaultLinks.terms)
  expect(privacyLink).toBe(defaultLinks.privacy)
})
