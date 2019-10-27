import * as React from 'react'
import { shallow } from 'enzyme'
import CargoUnitBox from '.'
import { maxDimensionsToApply } from '../../../../mocks'
import { scope } from '../../../../../../mocks/index'

const propsBase = {
  value: 11,
  name: '0-cargo_item',
  onChange: null,
  onBlur: null,
  onExcessDimensionsRequest: null,
  maxDimension: maxDimensionsToApply,
  maxDimensionsErrorText: 'DIMENSIONS_ERROR_TEXT',
  labelText: 'LABEL_TEXT',
  className: 'flex-85-mock',
  unit: 'sm',
  image: <img id="mock" src="mock" />,
  tooltip: <div id="tooltip" />,
  scope
}

test('with empty props', () => {
  expect(shallow(<CargoUnitBox />)).toMatchSnapshot()
})

test('renders correctly', () => {
  expect(shallow(<CargoUnitBox {...propsBase} />)).toMatchSnapshot()
})
