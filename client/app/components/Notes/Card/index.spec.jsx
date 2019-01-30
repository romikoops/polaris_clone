import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../mocks'

import NotesCard from '.'

const levels = [
  null,
  'urgent',
  'important',
  'notification',
  'alert'
]

levels.forEach((level) => {
  test(`when level is ${level}`, () => {
    const props = {
      note: {
        header: 'HEADER',
        itineraryTitle: 'TITLE',
        level
      },
      theme
    }
    expect(shallow(<NotesCard {...props} />)).toMatchSnapshot()
  })
})
