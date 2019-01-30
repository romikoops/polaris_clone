import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../../mock'

import AdminHubForm from './AdminHubForm'

const propsBase = {
  saveHub: identity,
  close: identity,
  theme
}

test('shallow render', () => {
  expect(shallow(<AdminHubForm {...propsBase} />)).toMatchSnapshot()
})

test('state.location is truthy', () => {
  const wrapper = shallow(<AdminHubForm {...propsBase} />)
  wrapper.setState({ location: hub.location })

  expect(wrapper).toMatchSnapshot()
})
