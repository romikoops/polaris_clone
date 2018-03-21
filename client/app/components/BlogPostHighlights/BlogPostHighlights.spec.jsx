import * as React from 'react'
import { mount } from 'enzyme'

jest.mock('react-truncate', () => {
  // eslint-disable-next-line react/prop-types
  const Truncate = ({ children }) => <span>{children}</span>

  return Truncate
})
jest.mock('../RoundButton/RoundButton', () => {
  const RoundButton = () => <button />

  return {
    RoundButton
  }
})
// eslint-disable-next-line
import BlogPostHighlights from './BlogPostHighlights'

const expectedResult = ` Recent Blog News How Digitalisation is changing shipping   With the sheer amount of freight crossing the globe on a daily basis, our means of co-ordinating the massive flow of information ahs had to continuously evolve and adapt. Digitalisation has allowed companies, big and small to keep up with the ever  With greater supply and even higher demand, efficiency gains have never been more important   With the global freight market under pressure from both supply and demand sides, it has become increasingly important to eek out every last bit of productivity from your existing resources  Blockchain is coming: How you can begin to get ready for the next big leap in freight   The global shipping industry is the backbone upon which the modern world is built. However, fraud, theft and other problems continue to drive up prices for consumers around the world. A small group  of companies are working to bring the power and protection of blockchain technologies to the wolrd of freight `

const propsBase = {}

test('text content', () => {
  const wrapper = mount(<BlogPostHighlights {...propsBase} />)

  expect(wrapper.text()).toBe(expectedResult)
})
