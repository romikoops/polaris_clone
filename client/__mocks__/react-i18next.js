const { Component } = require('react')
const en = require('../locales/en/translations.json')

module.exports = {
  // this mock makes sure any components using the translate HoC receive the t function as a prop
  withNamespaces: () => Component => {
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
