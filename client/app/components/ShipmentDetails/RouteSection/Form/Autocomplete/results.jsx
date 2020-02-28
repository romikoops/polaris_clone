import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'

import styles from './autocomplete.scss'

class AutocompleteResults extends Component {
  static defaultProps = {
    onChange: () => {},
    results: [],
    itemTemplate: (item) => item.label,
    inputRef: { current: null }
  }

  constructor (params) {
    super(params)

    this.state = {
      index: 0
    }

    this.onKeyDown = this.onKeyDown.bind(this)
    this.selectItem = this.selectItem.bind(this)
    this.reset = this.reset.bind(this)
  }

  componentDidMount () {
    const { inputRef } = this.props

    if (inputRef.current) {
      inputRef.current.addEventListener('keydown', this.onKeyDown)
    }
  }

  componentWillUnmount () {
    const { inputRef } = this.props

    if (inputRef.current) {
      inputRef.current.removeEventListener('keydown', this.onKeyDown)
    }
  }

  onKeyDown (event) {
    const { index } = this.state
    const keyName = event.key

    switch (keyName) {
      case 'ArrowDown':
      case 'Down':
        this.setIndex(index + 1)
        event.preventDefault()
        break

      case 'ArrowUp':
      case 'Up':
        this.setIndex(index - 1)
        event.preventDefault()
        break

      case 'Enter':
        this.selectItem(index)
        event.preventDefault()
        break

      case 'Escape':
        this.reset()
        event.preventDefault()
        break

      default:
        break
    }
  }

  setIndex (requestedIndex) {
    const { results } = this.props
    let newIndex = requestedIndex

    if (requestedIndex < 0) {
      newIndex = results.length
    }

    if (requestedIndex >= results.length) {
      newIndex = 0
    }

    this.setState({ index: newIndex })
  }

  reset () {
    const { onChange } = this.props

    this.setIndex(0)
    onChange(null)
  }

  selectItem (index) {
    const { onChange, results } = this.props
    const item = results[index]

    this.setIndex(index)
    onChange(item)
  }

  render () {
    const { itemTemplate, searching, results } = this.props
    const { index } = this.state

    if (!searching) {
      return null
    }

    const itemClassName = (idx, _item) => (idx === index ? styles.autocompleteResultsSelected : '')
    const listItems = results.map((item, idx) => (
      <li
        key={item.value}
        className={itemClassName(idx, item)}
        onClick={() => this.selectItem(idx)}
      >
        {itemTemplate(item)}
      </li>
    ))

    return (
      <ul className={styles.autocompleteResults}>
        {listItems}
        {results.length === 0 && <AutocompleteEmptyResults /> }
      </ul>
    )
  }
}

const EmptyResults = ({ t }) => <li>{t('common:noResults')}</li>
const AutocompleteEmptyResults = withNamespaces(['common'])(EmptyResults)

export default AutocompleteResults
