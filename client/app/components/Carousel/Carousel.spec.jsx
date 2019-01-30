import * as React from 'react'
import { shallow } from 'enzyme'
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

test('shallow render', () => {
  expect(shallow(<Carousel {...propsBase} />)).toMatchSnapshot()
})

test('props.fade is true', () => {
  const props = {
    ...propsBase,
    fade: true
  }
  expect(shallow(<Carousel {...props} />)).toMatchSnapshot()
})

test('slides is falsy', () => {
  const props = {
    ...propsBase,
    slides: null
  }
  expect(shallow(<Carousel {...props} />)).toMatchSnapshot()
})

test('noSlides is falsy', () => {
  const props = {
    ...propsBase,
    noSlides: null
  }
  expect(shallow(<Carousel {...props} />)).toMatchSnapshot()
})
