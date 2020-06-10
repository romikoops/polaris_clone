import * as React from 'react'
import { mount, shallow } from 'enzyme'
import Form from '.'
import { hub, theme, identity } from '../../../../mocks/index'
import { address, locationNexusMock } from '../../../../mock'
import AutocompleteResults from './Autocomplete/results'

let wrapper
const propsBase = {
  theme,
  hubs: [hub],
  hasHubs: true,
  hasTrucking: false,
  showAddress: false,
  loadIng: false,
  adddressFetch: identity,
  adddressSearch: identity,
  requiresFullAddress: false,
  value: {},
  onBlur: identity,
  onChange: identity,
  onFocus: identity
}

test('it finds the hub by locode', () => {
  wrapper = shallow(<Form {...propsBase} />)
  const instance = wrapper.instance()
  const normalisedHubs = Form.normalizeHubResults([hub])

  return expect(instance.searchHub('DEHAM')).resolves.toEqual(normalisedHubs)
})

test('it finds the hub by secondary name', () => {
  const adjustedHub = { ...hub, nexusName: 'Ho Chi Minh - Cat Lai' }
  const adjustedProps = {
    ...propsBase,
    hubs: [adjustedHub]
  }
  wrapper = shallow(<Form {...adjustedProps} />)
  const instance = wrapper.instance()
  const normalisedHubs = Form.normalizeHubResults([adjustedHub])

  return expect(instance.searchHub('Cat Lai')).resolves.toEqual(normalisedHubs)
})

describe('Context: Autocomplete Items', () => {
  const autocompleteResults = () => wrapper.find(AutocompleteResults)

  beforeAll(() => {
    wrapper = mount(<Form {...propsBase} />)
    wrapper.setState({ results: [address, locationNexusMock] })
  })

  it('renders the address icon', () => {
    const item = autocompleteResults().invoke('itemTemplate')({ ...address, type: 'address' })

    expect(item).toMatchSnapshot()
  })

  it('renders the port icon', () => {
    const item = autocompleteResults().invoke('itemTemplate')(locationNexusMock)

    expect(item).toMatchSnapshot()
  })
})

jest.mock('uuid', () => ({
  v1: () => '123456'
}))
