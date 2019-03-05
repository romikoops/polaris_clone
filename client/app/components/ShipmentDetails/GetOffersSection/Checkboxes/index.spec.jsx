import * as React from 'react'
import { shallow } from 'enzyme'
import Checkboxes from '.'
import { theme } from '../../mocks'

const propsBase = {
  theme,
  noDangerousGoodsConfirmed: null,
  stackableGoodsConfirmed: true,
  onChangeNoDangerousGoodsConfirmation: true,
  onChangeStackableGoodsConfirmation: true,
  onClickDangerousGoodsInfo: true,
  shakeClass: {
    noDangerousGoodsConfirmed: 'SHAKE_CLASS_DANGEROUS',
    stackableGoodsConfirmed: 'SHAKE_CLASS_STACKABLE'
  },
  show: true
}

test('with empty props', () => {
  expect(() => shallow(<Checkboxes />)).toThrow()
})

test('renders correctly', () => {
  expect(shallow(<Checkboxes {...propsBase} />)).toMatchSnapshot()
})
