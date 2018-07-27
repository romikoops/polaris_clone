import * as React from 'react'
import { shallow } from 'enzyme'
import Tabs from './Tabs'

test('shallow rendering', () => {
  expect(shallow(<Tabs>
    <div>foo</div>
    <div>bar</div>
  </Tabs>)).toMatchSnapshot()
})
