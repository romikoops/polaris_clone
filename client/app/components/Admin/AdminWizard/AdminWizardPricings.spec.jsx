import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mocks'
import AdminWizardPricings from './AdminWizardPricings'

const propsBase = {
  theme,
  adminTools: {
    goTo: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminWizardPricings {...propsBase} />)).toMatchSnapshot()
})
