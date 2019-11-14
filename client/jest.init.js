/* eslint-disable import/no-extraneous-dependencies */
const { toBeType } = require('jest-tobetype')
const expect = require('expect')
const Enzyme = require('enzyme')
const Adapter = require('enzyme-adapter-react-16')

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
window.scrollTo = () => { }

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
global.fetch = require('jest-fetch-mock')
