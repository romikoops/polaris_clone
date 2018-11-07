import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, address } from '../../mocks'

jest.mock('formsy-react', () => {
  // eslint-disable-next-line
  const Formsy = ({ children }) => <div>{children}</div>

  return {
    default: Formsy
  }
})
jest.mock('../../hocs/GmapsWrapper', () => {
  // eslint-disable-next-line
  const GmapsWrapper = ({ children }) => <div>{children}</div>

  return {
    default: GmapsWrapper
  }
})
jest.mock('../Maps/PlaceSearch', () => {
  // eslint-disable-next-line
  const PlaceSearch = ({ children }) => <div>{children}</div>

  return {
    default: PlaceSearch
  }
})
jest.mock('../FormsyInput/FormsyInput', () => {
  // eslint-disable-next-line
  const FormsyInput = props => <input {...props} />

  return {
    default: FormsyInput
  }
})

// eslint-disable-next-line
import ShipmentContactForm from './ShipmentContactForm'

const propsBase = {
  theme,
  close: identity,
  setContact: identity,
  handleChange: identity,
  contactData: {
    address,
    contact: { companyName: 'FOO_COMPANY' },
    type: 'FOO_TYPE'
  }
}

const createShallow = propsInput => shallow(<ShipmentContactForm {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})
