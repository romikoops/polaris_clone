import * as React from 'react'
import { shallow } from 'enzyme'
import { CardLinkRow } from './CardLinkRow'
import { theme, identity } from '../../mocks'

const cardFirst = {
  name: 'FOO_NAME1',
  img: 'FOO_IMG1',
  url: 'FOO_URL1',
  handleClick: identity,
  options: {}
}
const cardSecond = {
  ...cardFirst,
  name: 'FOO_NAME2',
  img: 'FOO_IMG2',
  url: 'FOO_URL2'
}

const propsBase = {
  theme,
  cards: [cardFirst, cardSecond],
  selectedType: 'FOO_SELECTED_TYPE',
  handleClick: identity
}

test('shallow render', () => {
  expect(shallow(<CardLinkRow {...propsBase} />)).toMatchSnapshot()
})
