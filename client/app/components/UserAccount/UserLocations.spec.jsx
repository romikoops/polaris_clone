import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, identity, user, location } from '../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

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
import { UserLocations } from './UserLocations'

const createWrapper = propsInput => mount(<UserLocations {...propsInput} />)

const editedLocationPrimary = {
  location,
  user: {
    ...user,
    primary: true
  }
}

const editedLocation = {
  location,
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
  locations: [editedLocation, editedLocationPrimary]
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

test('props.userDispatch.makePrimary is called', () => {
  const props = {
    ...propsBase,
    userDispatch: {
      ...propsBase,
      makePrimary: jest.fn()
    }
  }
  const selector = 'div[className="layout-row flex-20 layout-align-end"] > div'

  const wrapper = createWrapper(props)
  const clickableDiv = wrapper.find(selector).first()

  clickableDiv.simulate('click')
  expect(props.userDispatch.makePrimary).toHaveBeenCalled()
})
