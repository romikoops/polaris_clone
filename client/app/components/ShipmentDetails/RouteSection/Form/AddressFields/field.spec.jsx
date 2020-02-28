import * as React from 'react'
import { shallow } from 'enzyme'
import Field from './field'

const baseProps = {
  className: 'TestClassName',
  label: 'TestLabel',
  name: 'TestName',
  onBlur: () => {},
  validations: {},
  value: '1234'
}

describe('<Field>', () => {
  let props
  let wrapper

  beforeEach(() => {
    props = { ...baseProps }
    wrapper = shallow(<Field {...props} />)
  })

  it('renders correctly ', () => {
    expect(wrapper).toMatchSnapshot()
  })

  describe('context disabled', () => {
    beforeEach(() => {
      props = { ...baseProps, disabled: true }
      wrapper = shallow(<Field {...props} />)
    })

    it('renders correctly ', () => {
      expect(wrapper).toMatchSnapshot()
    })
  })
})
