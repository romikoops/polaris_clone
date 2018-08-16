const React = require('react')
const reactI18next = require('react-i18next')
const { en } = require('../translations/all.json')

module.exports = {
  translate: () => (Component, o) => {
    Component.defaultProps = {
      ...Component.defaultProps,
      t: (key) => {
        const [scope, id] = key.split(':')
        if (!en[scope] || !en[scope][id]) {
          return `NO_TRANSLATION | key "${key}"`
        }

        return en[scope][id]
      }
    }

    return Component
  }
}
