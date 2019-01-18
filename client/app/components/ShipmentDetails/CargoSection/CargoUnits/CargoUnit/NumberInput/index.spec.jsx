import * as React from 'react'
import { shallow } from 'enzyme'
import CargoUnitBox from '.'
import { identity, maxDimensionsToApply } from '../../../../mocks'

const propsBase = {
  value: 11,
  name: '0-cargo_item',
  onChange: identity,
  onBlur: identity,
  onExcessDimensionsRequest: identity,
  maxDimension: maxDimensionsToApply,
  maxDimensionsErrorText: 'DIMENSIONS_ERROR_TEXT',
  labelText: 'LABEL_TEXT',
  className: 'flex-85-mock',
  unit: 'sm',
  image: <img id="mock" src="mock" />,
  tooltip: <div id="tooltip" />
}

test('with empty props', () => {
  expect(shallow(<CargoUnitBox />)).toMatchSnapshot()
})

test('happy path', () => {
  expect(shallow(<CargoUnitBox {...propsBase} />)).toMatchSnapshot()
})
