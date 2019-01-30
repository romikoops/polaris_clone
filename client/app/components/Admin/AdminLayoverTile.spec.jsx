import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, hub, change, identity
} from '../../mock'
import AdminLayoverTile from './AdminLayoverTile'

jest.mock('../../constants', () => {
  const format = () => 19
  const subtract = () => ({ format })
  const add = () => ({ format })

  const moment = () => ({
    format,
    subtract,
    add
  })

  return { moment }
})

const propsBase = {
  theme,
  hub,
  navFn: identity,
  handleClick: identity,
  target: 'TARGET',
  layoverData: {
    layover: {
      eta: 'ETA'
    },
    hub: {}
  }
}

test('shallow render', () => {
  expect(shallow(<AdminLayoverTile {...propsBase} />)).toMatchSnapshot()
})

test('layoverData is falsy', () => {
  const props = {
    ...propsBase,
    layoverData: null
  }

  expect(shallow(<AdminLayoverTile {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }

  expect(shallow(<AdminLayoverTile {...props} />)).toMatchSnapshot()
})

test('hub.photo is truthy', () => {
  const props = change(
    propsBase,
    'layoverData.hub',
    { photo: 'PHOTO' }
  )

  expect(shallow(<AdminLayoverTile {...props} />)).toMatchSnapshot()
})
