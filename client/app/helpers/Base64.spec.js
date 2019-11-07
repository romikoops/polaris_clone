import { Base64decode, Base64encode } from './Base64'

const targetString = "{ test: 'value', test1: 1, test2: 3.1 }"
const targetEncoded = 'eyB0ZXN0OiAndmFsdWUnLCB0ZXN0MTogMSwgdGVzdDI6IDMuMSB9';

describe('#Base64decode', () => {
  test('it should decode data properly', () => {
    const result = Base64decode(targetEncoded)

    expect(result).toEqual(targetString);
  });

  test('it should not throw error on empty string', () => {
    const result = Base64decode('')

    expect(result).toBeNull();
  })

  test('it should not throw error on null', () => {
    const result = Base64decode(null)

    expect(result).toBeNull();
  })

  test('it should not throw error on empty object', () => {
    const result = Base64decode(null)

    expect(result).toBeNull();
  })
})


describe('#Base64encode', () => {
  test('it should encode data properly', () => {
    const result = Base64encode(targetString);

    expect(result).toBe(targetEncoded);
  })

  test('it should not throw error on empty string', () => {
    const result = Base64encode('')

    expect(result).toBeNull();
  })

  test('it should not throw error on null', () => {
    const result = Base64encode(null)

    expect(result).toBeNull();
  })

  test('it should not throw error on empty object', () => {
    const result = Base64encode(null)

    expect(result).toBeNull();
  })
})
