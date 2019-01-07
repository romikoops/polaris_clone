import { numberSpacing } from './'

const smallDecimalValueFloat = 0.001
const smallDecimalValueString = '0.001'

const smallDecimalValueFloatResult = numberSpacing(smallDecimalValueFloat, 2)
const smallDecimalValueStringResult = numberSpacing(smallDecimalValueString, 2)

expect(smallDecimalValueFloatResult).toBe('0.001')
expect(smallDecimalValueStringResult).toBe('0.001')

test('it adds an extra decimal for values less than 0.01', () => {
  const smallDecimalValueFloat = 0.001
  const smallDecimalValueString = '0.001'

  const smallDecimalValueFloatResult = numberSpacing(smallDecimalValueFloat, 1)
  const smallDecimalValueStringResult = numberSpacing(smallDecimalValueString, 1)

  expect(smallDecimalValueFloatResult).toBe('0.001')
  expect(smallDecimalValueStringResult).toBe('0.001')
})

test('it maxes out at 3 decimal points', () => {
  const smallDecimalValueFloat = 0.0001
  const smallDecimalValueString = '0.0001'

  const smallDecimalValueFloatResult = numberSpacing(smallDecimalValueFloat, 2)
  const smallDecimalValueStringResult = numberSpacing(smallDecimalValueString, 2)

  expect(smallDecimalValueFloatResult).toBe('0.000')
  expect(smallDecimalValueStringResult).toBe('0.000')
})

test('it returns a string with the correct number of decimals', () => {
  const smallDecimalValueFloat = 0.1
  const smallDecimalValueString = '0.1'
  const decimalCount = 2

  const smallDecimalValueFloatResult = numberSpacing(smallDecimalValueFloat, decimalCount)
  const smallDecimalValueStringResult = numberSpacing(smallDecimalValueString, decimalCount)

  const smallDecimalValueFloatDecimalCount = smallDecimalValueFloatResult.split('.')[1].length
  const smallDecimalValueStringDecimalCount = smallDecimalValueStringResult.split('.')[1].length


  expect(smallDecimalValueFloatDecimalCount).toBe(2)
  expect(smallDecimalValueStringDecimalCount).toBe(2)
})