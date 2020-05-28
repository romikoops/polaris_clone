import * as React from 'react'
import { shallow } from 'enzyme'
import Form from '.'
import { hub, theme, identity } from '../../../../mocks/index'

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
  const wrapper = shallow(<Form {...propsBase} />)
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
  const wrapper = shallow(<Form {...adjustedProps} />)
  const instance = wrapper.instance()
  const normalisedHubs = Form.normalizeHubResults([adjustedHub])

  return expect(instance.searchHub('Cat Lai')).resolves.toEqual(normalisedHubs)
})
