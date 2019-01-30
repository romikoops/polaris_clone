import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../../mock'

import MandatoryChargeBox from './MandatoryChargeBox'

const propsBase = {
  theme,
  saveChanges: identity,
  mandatoryCharge: identity
}

test('shallow render', () => {
  expect(shallow(<MandatoryChargeBox {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<MandatoryChargeBox {...props} />)).toMatchSnapshot()
})

test('state.mandatoryChange.id is truthy', () => {
  const wrapper = shallow(<MandatoryChargeBox {...propsBase} />)
  wrapper.setState({ mandatoryCharge: { id: 1 } })

  expect(wrapper).toMatchSnapshot()
})

test('editHasOccured is true', () => {
  const wrapper = shallow(<MandatoryChargeBox {...propsBase} />)

  wrapper.setState({
    mandatoryCharge: {
      id: 1,
      import_charges: 'IMPORT_CHARGES'
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('state.confirm is truthy', () => {
  const wrapper = shallow(<MandatoryChargeBox {...propsBase} />)

  wrapper.setState({
    mandatoryCharge: { id: 1 },
    confirm: true
  })

  expect(wrapper).toMatchSnapshot()
})
