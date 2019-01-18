import * as React from 'react'
import { shallow } from 'enzyme'
import CargoUnitBox from '.'
import { identity, cargoItem } from '../../../../mocks'

const propsBase = {
  cargoUnit: cargoItem,
  i: 0,
  onDeleteUnit: identity,
  onChangeCargoUnitInput: identity,
  children: <div id="childen" />,
  uniqKey: 'UNIQ_KEY'
}

test('with empty props', () => {
  expect(shallow(<CargoUnitBox />)).toMatchSnapshot()
})

test('happy path', () => {
  expect(shallow(<CargoUnitBox {...propsBase} />)).toMatchSnapshot()
})
