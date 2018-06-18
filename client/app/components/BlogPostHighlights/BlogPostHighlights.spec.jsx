import * as React from 'react'
import { shallow } from 'enzyme'
// eslint-disable-next-line
import BlogPostHighlights from './BlogPostHighlights'

test('shallow render', () => {
  expect(shallow(<BlogPostHighlights />)).toMatchSnapshot()
})
