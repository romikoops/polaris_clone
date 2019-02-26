import * as React from 'react'
import { shallow } from 'enzyme'
import Container from '.'
import { cargoItemContainer, cargoUnitProps } from '../../../mocks'

test('with empty props', () => {
  expect(() => shallow(<Container />)).toThrow()
})

test('happy path', () => {
  const props = {
    ...cargoUnitProps,
    container: cargoItemContainer
  }
  expect(shallow(<Container {...props} />)).toMatchSnapshot()
})
