import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user } from '../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('react-select', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x
}))
jest.mock('./index.jsx', () => ({
  // eslint-disable-next-line react/prop-types
  UserLocations: ({ children }) => <div>{children}</div>
}))
jest.mock('../Documents/Downloader', () =>
  // eslint-disable-next-line react/prop-types
  ({ props }) => <div {...props} />)
jest.mock('../Admin', () => ({
  // eslint-disable-next-line react/prop-types
  AdminClientTile: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ children }) => <button>{children}</button>
}))
// eslint-disable-next-line import/first
import { UserProfile } from './UserProfile'

const propsBase = {
  theme,
  user,
  setNav: identity,
  appDispatch: {
    setCurrency: identity
  },
  aliases: [],
  locations: [],
  authDispatch: {
    updateUser: identity
  },
  userDispatch: {
    makePrimary: identity,
    newAlias: identity,
    deleteAlias: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserProfile {...propsBase} />)).toMatchSnapshot()
})

test('props.user is falsy', () => {
  const props = {
    ...propsBase,
    user: false
  }
  expect(shallow(<UserProfile {...props} />)).toMatchSnapshot()
})

test('props.aliases is truthy', () => {
  const props = {
    ...propsBase,
    aliases: [{ foo: 0 }, { bar: 1 }]
  }
  expect(shallow(<UserProfile {...props} />)).toMatchSnapshot()
})

test('state.editBool is true', () => {
  const wrapper = shallow(<UserProfile {...propsBase} />)
  wrapper.setState({ editBool: true })

  expect(wrapper).toMatchSnapshot()
})
