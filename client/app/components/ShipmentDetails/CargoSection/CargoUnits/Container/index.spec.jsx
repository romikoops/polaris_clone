import * as React from 'react'
import { shallow } from 'enzyme'
import Container from '.'
import { cargoItemContainer, cargoUnitProps } from '../../../mocks'

test('happy path', () => {
  const props = {
    ...cargoUnitProps,
    container: cargoItemContainer
  }
  expect(shallow(<Container {...props} />)).toMatchSnapshot()
})
