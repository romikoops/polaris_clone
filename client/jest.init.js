/* eslint-disable import/no-extraneous-dependencies */
import { toBeType } from 'jest-tobetype'
import expect from 'expect'

import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
/* eslint-enable import/no-extraneous-dependencies */

Enzyme.configure({ adapter: new Adapter() })

expect.extend({
  toBeType
})

const matchMediaPolyfill = () => ({
  matches: false,
  addListener: () => {},
  removeListener: () => {}
})

window.matchMedia = window.matchMedia || matchMediaPolyfill

class LocalStorageMock {
  constructor () {
    this.store = {}
  }

  clear () {
    this.store = {}
  }

  getItem (key) {
    return this.store[key] || null
  }

  setItem (key, value) {
    this.store[key] = value.toString()
  }

  removeItem (key) {
    delete this.store[key]
  }
}

global.localStorage = new LocalStorageMock()
