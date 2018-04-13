import * as React from 'react'
import { shallow } from 'enzyme'

jest.mock('react-truncate', () => {
  // eslint-disable-next-line react/prop-types
  const Truncate = ({ children }) => <span>{children}</span>

  return Truncate
})
jest.mock('../RoundButton/RoundButton', () => {
  const RoundButton = () => <button />

  return {
    RoundButton
  }
})
// eslint-disable-next-line
import BlogPostHighlights from './BlogPostHighlights'

const propsBase = {}

test('shallow render', () => {
  expect(shallow(<BlogPostHighlights {...propsBase} />)).toMatchSnapshot()
})
