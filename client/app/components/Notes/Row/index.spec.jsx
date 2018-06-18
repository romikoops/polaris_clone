import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../mocks'

// eslint-disable-next-line
import NotesRow from './'

const propsBase = {
  notes: [{
    level: 'important',
    header: 'FOO_HEADER',
    itineraryTitle: 'FOO_TITLE'
  }],
  theme
}

test('shallow render', () => {
  expect(shallow(<NotesRow {...propsBase} />)).toMatchSnapshot()
})
