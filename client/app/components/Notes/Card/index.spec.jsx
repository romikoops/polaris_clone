import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../mocks'

// eslint-disable-next-line
import NotesCard from './'

const propsBase = {
  note: {
    level: 'important',
    header: 'FOO_HEADER',
    itineraryTitle: 'FOO_TITLE'
  },
  theme
}

test('shallow render', () => {
  expect(shallow(<NotesCard {...propsBase} />)).toMatchSnapshot()
})
