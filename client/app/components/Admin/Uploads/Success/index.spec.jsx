import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../../mock'

import AdminUploadsSuccess from '.'

const propsBase = {
  theme,
  data: {
    stats: {
      pricings: {
        number_created: 'NUMBER_CREATED',
        number_updated: 'NUMBER_UPDATED'
      }
    },
    result: {}
  },
  closeDialog: identity
}

test('shallow render', () => {
  expect(shallow(<AdminUploadsSuccess {...propsBase} />)).toMatchSnapshot()
})
