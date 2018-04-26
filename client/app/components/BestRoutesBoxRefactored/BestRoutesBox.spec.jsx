import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipmentData } from '../../mocks'

jest.mock('../Price/Price', () => ({
  // eslint-disable-next-line react/prop-types
  Price: ({ children }) => <div>{children}</div>
}))
jest.mock('../../helpers', () => ({
  gradientGenerator: x => x
}))
jest.mock('../../constants', () => {
  const moment = x => ({
    diff: y => x - y
  })

  return { moment }
})
// eslint-disable-next-line import/first
import { BestRoutesBox } from './BestRoutesBox'

const propsBase = {
  theme,
  user,
  chooseResult: identity,
  shipmentData
}

test('shallow render', () => {
  expect(shallow(<BestRoutesBox {...propsBase} />)).toMatchSnapshot()
})
