import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, user, scope
} from '../../mocks/index'

import EditProfileBox from './EditProfileBox'

const propsBase = {
  theme,
  user,
  scope,
  t: identity,
  handleChange: identity,
  handleCurrencyChange: identity,
  currentCurrency: 'EUR',
  currencyOptions: [],
  hide: false
}

test('shallow render', () => {
  expect(shallow(<EditProfileBox {...propsBase} />)).toMatchSnapshot()
})

test('editing name is falsy', () => {
  const props = {
    ...propsBase,
    scope: {
      user_restrictions: {
        profile: {
          name: true
        }
      }
    }
  }
  expect(shallow(<EditProfileBox {...props} />)).toMatchSnapshot()
})

test('editing company is falsy', () => {
  const props = {
    ...propsBase,
    scope: {
      user_restrictions: {
        profile: {
          company: true
        }
      }
    }
  }
  expect(shallow(<EditProfileBox {...props} />)).toMatchSnapshot()
})

test('editing email is falsy', () => {
  const props = {
    ...propsBase,
    scope: {
      user_restrictions: {
        profile: {
          email: true
        }
      }
    }
  }
  expect(shallow(<EditProfileBox {...props} />)).toMatchSnapshot()
})
