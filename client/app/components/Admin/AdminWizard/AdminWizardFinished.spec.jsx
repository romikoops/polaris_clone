import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mock'
import AdminWizardFinished from './AdminWizardFinished'

const propsBase = {
  theme,
  adminTools: {
    goTo: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminWizardFinished {...propsBase} />)).toMatchSnapshot()
})
