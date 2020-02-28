module.exports = {
  extends: '@itsmycargo/stylelint',
  rules: {
    'selector-pseudo-class-no-unknown': [true, {
      ignorePseudoClasses: ['/global/', '/local/']
    }]
  }
}
