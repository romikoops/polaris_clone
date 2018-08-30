import * as React from 'react'
import { shallow, mount } from 'enzyme'
import GreyBox from './GreyBox'
import styles from './GreyBox.scss'

const propsBase = {
  content: <div>FOO_CONTENT</div>,
  wrapperClassName: 'FOO_WRAPPER_CLASS_NAME',
  contentClassName: 'FOO_CONTENT_CLASS_NAME'
}

const createShallow = propsInput => shallow(<GreyBox {...propsInput} />)
const createWrapper = propsInput => mount(<GreyBox {...propsInput} />)

test('shallow render', () => {
  const props = {
    ...propsBase,
    title: 'FOO_TITLE'
  }
  expect(createShallow(props)).toMatchSnapshot()
})

test('title is falsy', () => {
  const props = {
    ...propsBase,
    title: ''
  }
  expect(createShallow(props)).toMatchSnapshot()
})

test('title to create title', () => {
  const props = {
    ...propsBase,
    title: 'FOO_TITLE'
  }

  const wrapper = createWrapper(props)
  const content = wrapper.find('.FOO_CONTENT_CLASS_NAME > div > p').first()
  expect(content.text()).toEqual(props.title)
})

test('paddingBool adds padding', () => {
  const props = {
    ...propsBase,
    padding: true
  }
  const wrapper = createShallow(props)
  const content = wrapper.find('.FOO_WRAPPER_CLASS_NAME').first()
  expect(content.hasClass(styles.boxpadding)).toEqual(true)
})

test('isBoxBool adds classes', () => {
  const props = {
    ...propsBase,
    isBox: true
  }
  const wrapper = createShallow(props)
  const content = wrapper.find('.FOO_WRAPPER_CLASS_NAME').first()
  expect(content.hasClass('layout-row flex-sm-100 flex-xs-100 layout-align-center-center')).toEqual(true)
})

test('fullWidth adds styles.fullwidth', () => {
  const props = {
    ...propsBase,
    fullWidth: true
  }
  const wrapper = createShallow(props)
  const content = wrapper.find('.FOO_WRAPPER_CLASS_NAME').first()
  expect(content.hasClass(styles.fullWidth)).toEqual(true)
})