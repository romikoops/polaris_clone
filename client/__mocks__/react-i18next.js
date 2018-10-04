const React = require('react')
const reactI18next = require('react-i18next')
const { en } = require('../translations/all.json')

module.exports = {
  // this mock makes sure any components using the translate HoC receive the t function as a prop
  translate: () => (Component, o) => {
    Component.defaultProps = {
      ...Component.defaultProps,
      t: (key) => {
        const [scope, id] = key.split(':')

        return en[scope] && en[scope][id]
          ? en[scope][id]
          : `NO_TRANSLATION | key "${key}"`
      }
    }

    return Component
  }
}
