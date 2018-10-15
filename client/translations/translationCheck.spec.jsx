import all from './all.json'
import en from '../i18n/en'

const language = all.en
const sortedBase = Object.keys(language).sort()
const sortedNameSpace = Object.keys(en).sort()

const nameSpacesCorrect = sortedBase.every(e => sortedNameSpace.includes(e)) &&
 sortedNameSpace.every(e => sortedBase.includes(e))

sortedBase.forEach((nameSpace) => {
  test('Translations should match', () => {
    expect(language[nameSpace]).toEqual(en[nameSpace])
  })
})

test('Namespaces should match', () => {
  expect(nameSpacesCorrect).toBe(true)
})
