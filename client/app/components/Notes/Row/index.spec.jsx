import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../mocks/index'

import NotesRow from '.'

const propsBase = {
  notes: [{
    level: 'important',
    header: 'HEADER',
    itineraryTitle: 'TITLE'
  }],
  theme
}

test('shallow render', () => {
  expect(shallow(<NotesRow {...propsBase} />)).toMatchSnapshot()
})

test('notes.length is 0', () => {
  const props = {
    ...propsBase,
    notes: []
  }
  expect(shallow(<NotesRow {...props} />)).toMatchSnapshot()
})
