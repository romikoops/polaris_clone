import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipmentData, tenant, shipment } from '../../mocks'
import { ChooseOffer } from './ChooseOffer'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  theme,
  user,
  shipmentData,
  chooseOffer: identity,
  messages: ['FOO_MESSAGE', 'BAR_MESSAGE'],
  req: {},
  setStage: identity,
  prevRequest: {
    shipment
  },
  shipmentDispatch: {
    goTo: identity
  },
  tenant
}

let originalDate
const constantDate = new Date('2017-06-13T04:41:20')
beforeEach(() => {
  originalDate = Date
  // eslint-disable-next-line
  Date = class extends Date {
    constructor () {
      return constantDate
    }
  }
})

afterEach(() => {
  // eslint-disable-next-line
  Date = originalDate
})

test.skip('shallow render', () => {
  expect(shallow(<ChooseOffer {...propsBase} />)).toMatchSnapshot()
})

test.skip('state.selectedMoT.ocean is false', () => {
  const wrapper = shallow(<ChooseOffer {...propsBase} />)
  wrapper.setState({
    selectedMoT: {
      ocean: false,
      air: true,
      truck: true,
      rail: true
    }
  })
  expect(wrapper).toMatchSnapshot()
})

test('shipmentData is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: null
  }
  expect(shallow(<ChooseOffer {...props} />)).toMatchSnapshot()
})

test('shipmentData.schedules is falsy', () => {
  const props = {
    ...propsBase,
    shipmentData: {
      ...shipmentData,
      schedules: null
    }
  }
  expect(shallow(<ChooseOffer {...props} />)).toMatchSnapshot()
})
