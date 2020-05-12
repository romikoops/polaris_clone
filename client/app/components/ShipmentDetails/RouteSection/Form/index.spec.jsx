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

  expect(instance.searchHub('DEHAM')).resolves.toEqual(normalisedHubs)
})
