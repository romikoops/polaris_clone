import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, tenant, theme, user } from '../../mocks'

jest.mock('../../helpers', () => ({
  authHeader: x => x
}))
// eslint-disable-next-line
import HSCodeRow from './HSCodeRow'

const containerBase = {
  cargo_group_id: 1,
  payload_in_kg: 177,
  tare_weight: 85
}

const propsBase = {
  tenant,
  theme,
  user,
  hsCodes: [],
  setCode: identity,
  deleteCode: identity,
  containers: [containerBase],
  cargoItems: [{
    cargo_group_id: 9
  }],
  hsTexts: {},
  handleHsTextChange: identity
}

test('shallow render', () => {
  expect(shallow(<HSCodeRow {...propsBase} />)).toMatchSnapshot()
})

test('variable textInputBool is true', () => {
  const props = {
    ...propsBase,
    tenant: {
      scope: {
        ...tenant.scope,
        cargo_info_level: 'text'
      }
    }
  }
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})

test('containers is falsy', () => {
  const props = {
    ...propsBase,
    containers: null
  }
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})

test('cargoItems is falsy', () => {
  const props = {
    ...propsBase,
    cargoItems: null
  }
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})

test('state.showPaste is true', () => {
  const wrapper = shallow(<HSCodeRow {...propsBase} />)
  wrapper.setState({ showPaste: true })

  expect(wrapper).toMatchSnapshot()
})

test('cont.dangerousGoods is true', () => {
  const container = {
    ...containerBase,
    dangerousGoods: true
  }
  const props = {
    ...propsBase,
    containers: [container]
  }
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})
