import reducer from './authentication.reducer'
import constants from '../constants/authentication.constants'

describe('authentication.reducer', () => {
  test('exports a (reducer) function', () => {
    expect(reducer).toBeType('function')
  })

  Object.keys(constants).forEach((k) => {
    const type = constants[k]
    test(`successfully executes the <${k}> reducer with an empty state`, () => {
      const result = reducer(null, { type })
      expect(result).toBeType('object')
    })
  })

  test('ignores unkown methods and returns the original object', () => {
    const state = { test: true }
    const result = reducer(state, { type: '' })
    expect(result).toBe(state)
  })

  test('ignores an invalid type', () => {
    const state = { test: true }
    const result = reducer(state, '')
    expect(result).toBe(state)
  })

  test('throws on an invalid state', () => {
    expect(() => reducer('invalid', { type: '' })).toThrow()
  })
})
