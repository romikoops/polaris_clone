import * as React from 'react'
import { shallow } from 'enzyme'
import { CardLinkRow } from './CardLinkRow'
import { theme, identity, cards } from '../../mocks'

const propsBase = {
  theme,
  cards,
  selectedType: 'SELECTED_TYPE',
  handleClick: identity
}

test('shallow render', () => {
  expect(shallow(<CardLinkRow {...propsBase} />)).toMatchSnapshot()
})
