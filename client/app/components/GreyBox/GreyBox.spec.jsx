import * as React from 'react'
import { shallow } from 'enzyme'
import GreyBox from './GreyBox'

const propsBase = {
  flexGtLg: 0,
  flexMd: 0,
  fullWidth: false,
  isBox: false,
  padding: false,
  borderStyle: '',
  content: ['CONTENT'],
  titleAction: false,
  wrapperClassName: 'WRAPPER_CLASSNAME',
  contentClassName: 'CONTENT_CLASSNAME',
  title: 'TITLE'
}

test('shallow render', () => {
  expect(shallow(<GreyBox {...propsBase} />)).toMatchSnapshot()
})

test('title is falsy', () => {
  const props = {
    ...propsBase,
    title: null
  }
  expect(shallow(<GreyBox {...props} />)).toMatchSnapshot()
})

test('flex > 0', () => {
  const props = {
    ...propsBase,
    flex: 10
  }
  expect(shallow(<GreyBox {...props} />)).toMatchSnapshot()
})

test('flexGtLg > 0', () => {
  const props = {
    ...propsBase,
    flexGtLg: 10
  }
  expect(shallow(<GreyBox {...props} />)).toMatchSnapshot()
})

test('flexMd > 0', () => {
  const props = {
    ...propsBase,
    flexMd: 10
  }
  expect(shallow(<GreyBox {...props} />)).toMatchSnapshot()
})

test('isBox is true', () => {
  const props = {
    ...propsBase,
    isBox: true
  }
  expect(shallow(<GreyBox {...props} />)).toMatchSnapshot()
})

test('padding is true', () => {
  const props = {
    ...propsBase,
    padding: true
  }
  expect(shallow(<GreyBox {...props} />)).toMatchSnapshot()
})

test('fullWidth is true', () => {
  const props = {
    ...propsBase,
    fullWidth: true
  }
  expect(shallow(<GreyBox {...props} />)).toMatchSnapshot()
})
