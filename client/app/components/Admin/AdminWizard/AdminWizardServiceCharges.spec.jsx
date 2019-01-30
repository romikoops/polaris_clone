import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mock'
import AdminWizardServiceCharges from './AdminWizardServiceCharges'

const propsBase = {
  theme,
  adminTools: {
    wizardSCharge: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminWizardServiceCharges {...propsBase} />)).toMatchSnapshot()
})
