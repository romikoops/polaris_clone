import * as React from 'react'
import { shallow } from 'enzyme'

import BlogPostHighlights from './BlogPostHighlights'

test('shallow render', () => {
  expect(shallow(<BlogPostHighlights />)).toMatchSnapshot()
})
