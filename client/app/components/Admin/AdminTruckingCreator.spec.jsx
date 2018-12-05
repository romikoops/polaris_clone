import * as React from 'react'
import { shallow } from 'enzyme'
import { hub, identity, theme } from '../../mocks'

import AdminTruckingCreator from './AdminTruckingCreator'

jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x
}))

const propsBase = {
  theme,
  adminDispatch: {},
  closeForm: identity,
  hub
}

test('shallow render', () => {
  expect(shallow(<AdminTruckingCreator {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminTruckingCreator {...props} />)).toMatchSnapshot()
})

test('state.nexus is truthy', () => {
  const wrapper = shallow(<AdminTruckingCreator {...propsBase} />)
  wrapper.setState({ nexus: { label: 'LABEL' } })
  expect(wrapper).toMatchSnapshot()
})

test('state.steps.direction is true', () => {
  const wrapper = shallow(<AdminTruckingCreator {...propsBase} />)
  wrapper.setState({ steps: { direction: true } })
  expect(wrapper).toMatchSnapshot()
})

test('state.steps.fees is true', () => {
  const wrapper = shallow(<AdminTruckingCreator {...propsBase} />)
  wrapper.setState({ steps: { fees: true } })
  expect(wrapper).toMatchSnapshot()
})

test('steps.cellSteps && steps.fees', () => {
  const wrapper = shallow(<AdminTruckingCreator {...propsBase} />)
  wrapper.setState({ steps: { fees: true, cellSteps: true } })
  expect(wrapper).toMatchSnapshot()
})

test('state.cells has length', () => {
  const wrapper = shallow(<AdminTruckingCreator {...propsBase} />)
  wrapper.setState({ cells: [{}] })
  expect(wrapper).toMatchSnapshot()
})
