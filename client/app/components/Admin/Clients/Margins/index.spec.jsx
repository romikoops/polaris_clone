import '../../../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, user, identity, tenant
} from '../../../../mocks/index'
import { moment } from '../../../../constants'
import AdminClientMargins from './index'

const propsBase = {
  tenant,
  theme,
  user,
  clientsDispatch: {
    getMarginsForList: () => [],
    clearMarginsList: () => [],
    updateMarginValues: () => [],
    deleteMargin: () => [],
    goTo: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminClientMargins {...propsBase} />)).toMatchSnapshot()
})

test('shallow render with margins', () => {
  const margins = [
    {
      effectiveDate: moment('2020-01-01T00:00:00.000Z'),
      expirationDate: moment('2020-12-31T023:59:59.000Z'),
      marginType: 'Freight',
      itineraryName: 'Gothenburg - Shanghai',
      serviceLevel: 'standard',
      cargoClass: 'lcl',
      modeOfTransport: 'ocean',
      value: '10',
      operator: '%'
    }
  ]
  const marginProps = {
    ...propsBase,
    margins
  }
  expect(shallow(<AdminClientMargins {...marginProps} />)).toMatchSnapshot()
})

describe('shouldShowLogin()', () => {
  it('lifecycle method should have been called', () => {
    const componentDidMount = jest.fn()
    const componentWillUnmount = jest.fn()

    // 1. First extends your class to mock lifecycle methods
    class AdminClientMarginsTest extends AdminClientMargins {
      constructor (props) {
        super(props)
        this.componentDidMount = componentDidMount
        this.componentWillUnmount = componentWillUnmount
      }

      render () {
        return (<AdminClientMargins />)
      }
    }

    // 2. shallow-render and test componentDidMount
    const wrapper = shallow(<AdminClientMarginsTest />)

    expect(componentDidMount.mock.calls.length).toBe(1)
    expect(componentWillUnmount.mock.calls.length).toBe(0)

    // 3. unmount and test componentWillUnmount
    wrapper.unmount()

    expect(componentDidMount.mock.calls.length).toBe(1)
    expect(componentWillUnmount.mock.calls.length).toBe(1)
  })
})
