import * as React from 'react'
import { shallow } from 'enzyme'
import Autocomplete from './autocomplete'

jest.mock('uuid', () => {
  const v1 = () => 'RANDOM_KEY'

  return { v1 }
})

const baseProps = {
  onChange: () => {},
  search: () => {},
  value: '',
  results: []
}

const results = [
  { label: 'abc', value: 1 },
  { label: 'abc2', value: 2 }
]

describe('<Autocomplete />', () => {
  let props
  let wrapper

  describe('context default props', () => {
    beforeEach(() => {
      props = { ...baseProps }
      wrapper = shallow(<Autocomplete {...props} />)
    })

    it('renders correctly ', () => {
      expect(wrapper).toMatchSnapshot()
    })
  })

  describe('context with text typed', () => {
    beforeEach(() => {
      props = { ...baseProps, value: 'text' }
      wrapper = shallow(<Autocomplete {...props} />)
    })

    it('renders correctly ', () => {
      expect(wrapper).toMatchSnapshot()
    })
  })

  describe('context with results', () => {
    beforeEach(() => {
      props = { ...baseProps, results }
      wrapper = shallow(<Autocomplete {...props} />)
    })

    it('renders correctly ', () => {
      expect(wrapper).toMatchSnapshot()
    })
  })

  describe('context with empty results', () => {
    beforeEach(() => {
      props = { ...baseProps }
      wrapper = shallow(<Autocomplete {...props} />)
    })

    it('renders correctly ', () => {
      expect(wrapper).toMatchSnapshot()
    })
  })
})
