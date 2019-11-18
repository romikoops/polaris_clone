import { get } from 'lodash'
import reducer from './clients.reducer'
import { clientsConstants } from '../constants'

describe('clients.reducer', () => {
  test('exports a (reducer) function', () => {
    expect(reducer).toBeType('function')
  })

  test('it handles CLEAR_MARGINS_LIST', () => {
    const initialState = { 
      margins: { 
        page: 1,
        per_page: 10,
        marginData: [],
        numPages: 1
      }
    }
    const resultState = reducer(initialState, { 
      type: clientsConstants.CLEAR_MARGINS_LIST
    })
    expect(get(resultState, ['margins'])).toEqual({})
  })
})