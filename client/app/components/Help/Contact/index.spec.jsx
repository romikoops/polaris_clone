import * as React from 'react'
import { shallow } from 'enzyme'
import { tenant, turnFalsy } from '../../../mocks'
import HelpContact from '.'

test('shallow render', () => {
  expect(shallow(<HelpContact tenant={tenant} />)).toMatchSnapshot()
})

test('tenant.phone.support is falsy', () => {
  const newTenant = turnFalsy(
    tenant,
    'phones.support'
  )
  expect(shallow(<HelpContact tenant={newTenant} />)).toMatchSnapshot()
})
