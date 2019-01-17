import * as React from 'react'
import { shallow } from 'enzyme'
import Container from '.'
import { cargoItemContainer, importedProps } from '../../../mocks'

test('happy path', () => {
  const props = {
    ...importedProps,
    container: cargoItemContainer
  }
  expect(shallow(<Container {...props} />)).toMatchSnapshot()
})
