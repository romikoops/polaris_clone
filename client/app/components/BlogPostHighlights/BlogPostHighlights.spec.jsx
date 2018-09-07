import * as React from 'react'
import { shallow } from 'enzyme'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line
import BlogPostHighlights from './BlogPostHighlights'

test('shallow render', () => {
  expect(shallow(<BlogPostHighlights />)).toMatchSnapshot()
})
