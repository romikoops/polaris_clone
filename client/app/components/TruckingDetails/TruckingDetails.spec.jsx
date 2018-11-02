import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, identity } from '../../mocks'
import TruckingDetails from './TruckingDetails'

const propsBase = {
  theme,
  target: 'on_carriage',
  trucking: {
    on_carriage: {
      truck: 'FOO_ON_CARRIAGE'
    },
    pre_carriage: {
      truck: 'FOO_PRE_CARRIAGE'
    }
  },
  truckTypes: ['FOO', 'BAR'],
  handleTruckingDetailsChange: identity
}
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const createWrapper = propsInput => mount(<TruckingDetails {...propsInput} />)

test('shallow render', () => {
  expect(shallow(<TruckingDetails {...propsBase} />)).toMatchSnapshot()
})

test('handleTruckingDetailsChange is called', () => {
  const props = {
    ...propsBase,
    handleTruckingDetailsChange: jest.fn()
  }
  const wrapper = createWrapper(props)
  const input = wrapper.find('input').first()

  expect(props.handleTruckingDetailsChange).not.toHaveBeenCalled()
  input.simulate('change', { target: { value: 'foo' } })
  expect(props.handleTruckingDetailsChange).toHaveBeenCalled()
})
