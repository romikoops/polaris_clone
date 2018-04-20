import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, tenant, theme, user } from '../../mocks'

// import { bindActionCreators } from 'redux'
jest.mock('../NamedSelect/NamedAsync', () => ({
  // eslint-disable-next-line react/prop-types
  NamedAsync: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <h2>{children}</h2>
}))
jest.mock('../Tooltip/Tooltip', () => ({
  // eslint-disable-next-line react/prop-types
  Tooltip: ({ children }) => <div>{children}</div>
}))
jest.mock('../../helpers', () => ({
  authHeader: x => x
}))
// eslint-disable-next-line
import HSCodeRow from './HSCodeRow'

const propsBase = {
  tenant,
  theme,
  user,

  hsCodes: [],
  setCode: identity,
  deleteCode: identity,
  containers: [{
    cargo_group_id: 1,
    payload_in_kg: 177,
    tare_weight: 85
  }],
  cargoItems: [{
    cargo_group_id: 9
  }],
  hsTexts: {},
  handleHsTextChange: identity
}

test('shallow render', () => {
  expect(shallow(<HSCodeRow {...propsBase} />)).toMatchSnapshot()
})
