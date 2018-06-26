import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, location } from '../../mocks'

jest.mock('formsy-react', () => {
  // eslint-disable-next-line react/prop-types
  const Formsy = ({ children }) => <div>{children}</div>

  return {
    default: Formsy
  }
})
jest.mock('../../hocs/GmapsWrapper', () => {
  // eslint-disable-next-line react/prop-types
  const GmapsWrapper = ({ children }) => <div>{children}</div>

  return {
    default: GmapsWrapper
  }
})
jest.mock('../Maps/PlaceSearch', () => {
  // eslint-disable-next-line react/prop-types
  const PlaceSearch = ({ children }) => <div>{children}</div>

  return {
    default: PlaceSearch
  }
})
jest.mock('../FormsyInput/FormsyInput', () => {
  // eslint-disable-next-line react/prop-types
  const FormsyInput = props => <input {...props} />

  return {
    default: FormsyInput
  }
})
jest.mock('../RoundButton/RoundButton', () => {
  // eslint-disable-next-line react/prop-types
  const RoundButton = ({ children }) => <button>{children}</button>

  return {
    RoundButton
  }
})
// eslint-disable-next-line import/first
import { ShipmentContactForm } from './ShipmentContactForm'

const propsBase = {
  theme,
  close: identity,
  setContact: identity,
  handleChange: identity,
  contactData: {
    location,
    contact: { companyName: 'FOO_COMPANY' },
    type: 'FOO_TYPE'
  }
}

const createShallow = propsInput => shallow(<ShipmentContactForm {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})
