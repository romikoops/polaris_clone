import * as React from 'react'
import { shallow } from 'enzyme'
import CargoUnits from '.'
import { change } from '../../../../mocks'
import { importedProps } from '../../mocks'

test('with empty props', () => {
  expect(shallow(<CargoUnits />)).toMatchSnapshot()
})

test('with imported props', () => {
  expect(shallow(<CargoUnits {...importedProps} />)).toMatchSnapshot()
})
