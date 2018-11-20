import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, identity, user, address, change } from '../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('../../hocs/EditLocationWrapper', () => ({
  // eslint-disable-next-line react/prop-types
  EditLocationWrapper: ({ children }) => <div>{children}</div>
}))
jest.mock('./EditLocation', () => ({
  // eslint-disable-next-line react/prop-types
  EditLocation: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line import/first
import UserLocations from './UserLocations'

const createWrapper = propsInput => mount(<UserLocations {...propsInput} />)

const editedLocationPrimary = {
  address,
  user: {
    ...user,
    primary: true
  }
}

const editedLocation = {
  address,
  user: {
    ...user,
    primary: false
  }
}

const propsBase = {
  theme,
  user,
  setNav: identity,
  userDispatch: {
    makePrimary: identity,
    newUserLocation: identity,
    destroyLocation: identity
  },
  addresses: [editedLocation, editedLocationPrimary]
}

test('shallow render', () => {
  expect(shallow(<UserLocations {...propsBase} />)).toMatchSnapshot()
})

test('props.setNav is called', () => {
  const props = {
    ...propsBase,
    setNav: jest.fn()
  }

  createWrapper(props)
  expect(props.setNav).toHaveBeenCalled()
})

test.skip('props.userDispatch.makePrimary is called', () => {
  const props = change(
    propsBase,
    'userDispatch.makePrimary',
    jest.fn()
  )
  const selector = '.icon_primary > div > div'
  const wrapper = createWrapper(props)
  const clickableDiv = wrapper.find(selector).first()
  clickableDiv.simulate('click')

  expect(props.userDispatch.makePrimary).toHaveBeenCalled()
})
