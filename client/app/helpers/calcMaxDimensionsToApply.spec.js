import calcMaxDimensionsToApply from './calcMaxDimensionsToApply'

const maxDimensions = {
  general: 'GENERAL',
  air: 'AIR'
}
test('air as mot', () => {
  const result = calcMaxDimensionsToApply(
    ['air'],
    maxDimensions
  )
  expect(result).toBe('AIR')
})

test('ocean as mot', () => {
  const result = calcMaxDimensionsToApply(
    ['ocean'],
    maxDimensions
  )
  expect(result).toBe('GENERAL')
})

test('empty mot', () => {
  const result = calcMaxDimensionsToApply(
    [],
    maxDimensions
  )
  expect(result).toBe('GENERAL')
})
