import offerSorter from './offerSorter'
import { firstResult, secondResult } from '../mocks/results'

const defaultScope = {
  sorting: {
    offers: {
      primary: 'total',
      secondary: 'duration'
    }
  }
}
const offers = [firstResult, secondResult]

test('should sort the offers by total', () => {
  const sortedOffers = offerSorter(offers, defaultScope)
  expect(sortedOffers[0]).toEqual(secondResult)
  expect(sortedOffers[1]).toEqual(firstResult)
})

test('should sort the offers by duration', () => {
  const scope = {
    sorting: {
      offers: {
        primary: 'duration',
        secondary: 'total'
      }
    }
  }
  const sortedOffers = offerSorter(offers, scope)

  expect(sortedOffers[0]).toEqual(firstResult)
  expect(sortedOffers[1]).toEqual(secondResult)
})
