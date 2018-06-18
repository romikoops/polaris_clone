import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../mocks'
// eslint-disable-next-line
import HelpContact from './'

const tenantBase = {
  data: {
    theme,
    emails: {
      support: {
        foo: 'foo@foo.com',
        bar: 'bar@bar.com',
        general: 'general@general.com'
      }
    }
  }
}

const propsBase = {
  tenant: tenantBase
}

test('shallow render', () => {
  expect(shallow(<HelpContact {...propsBase} />)).toMatchSnapshot()
})
