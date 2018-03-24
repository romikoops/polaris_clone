import * as React from 'react'
import { mount } from 'enzyme'

jest.mock('react-slick', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <span>{children}</span>)

// eslint-disable-next-line
import { Carousel } from './Carousel'

const slideFirst = {
  image: 'FOO_IMAGE1',
  header: 'FOO_HEADER1',
  subheader: 'FOO_SUBHEADER1'
}
const slideSecond = {
  image: 'FOO_IMAGE2',
  header: 'FOO_HEADER2',
  subheader: 'FOO_SUBHEADER2'
}

const propsBase = {
  slides: [
    slideFirst,
    slideSecond
  ],
  noSlides: 1,
  fade: false
}

let wrapper

const createWrapper = propsInput => mount(<Carousel {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('additional divs when props.fade is true', () => {
  const withFade = createWrapper({
    ...propsBase,
    fade: true
  })

  const numDivNoFade = wrapper.find('div').length
  const numDivWithFade = withFade.find('div').length

  /**
   * Difference is 2 as we have 2 slide and each
   * generates 1 additional div
   */
  expect(numDivNoFade).toBe(numDivWithFade - 2)
})

test('header in slides is correctly rendered', () => {
  const headerFirst = wrapper.find('h2.slick_city').at(0)
  const headerSecond = wrapper.find('h2.slick_city').at(1)

  expect(headerFirst.text().includes(slideFirst.header)).toBeTruthy()
  expect(headerSecond.text().includes(slideSecond.header)).toBeTruthy()
})

test('subheader in slides is correctly rendered', () => {
  const subheaderFirst = wrapper.find('h5.slick_country').at(0)
  const subheaderSecond = wrapper.find('h5.slick_country').at(1)

  expect(subheaderFirst.text().includes(slideFirst.subheader)).toBeTruthy()
  expect(subheaderSecond.text().includes(slideSecond.subheader)).toBeTruthy()
})
