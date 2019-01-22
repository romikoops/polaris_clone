import * as React from 'react'
import { shallow } from 'enzyme'
import CargoUnitBox from '.'
import { cargoItem } from '../../../../mocks'

const propsBase = {
  cargoUnit: cargoItem,
  i: 0,
  onDeleteUnit: null,
  onChangeCargoUnitInput: null,
  children: <div id="childen" />,
  uniqKey: 'UNIQ_KEY'
}

test('with empty props', () => {
  expect(shallow(<CargoUnitBox />)).toMatchSnapshot()
})

test('happy path', () => {
  expect(shallow(<CargoUnitBox {...propsBase} />)).toMatchSnapshot()
})
