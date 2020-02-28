import React, { Component } from 'react'
import { debounce } from 'lodash'
import { v1 } from 'uuid'

import AutocompleteResults from './results'
import styles from './autocomplete.scss'

class Autocomplete extends Component {
  static defaultProps = {
    onChange: () => {},
    onClear: () => {},
    results: [],
    search: () => {},
    value: ''
  }

  constructor (params) {
    super(params)

    const { value } = this.props
    this.inputRef = React.createRef()

    this.state = {
      currentValue: value,
      initialValue: value,
      isLoading: false,
      isSearching: false,
      version: v1() // disable browser field auto fill
    }

    this.search = debounce(this.search, 300)
  }

  static getDerivedStateFromProps (props, state) {
    const newState = { ...state }

    if (props.value !== state.initialValue) {
      newState.initialValue = props.value
      newState.currentValue = props.value
    }

    return newState
  }

  onInputChanged = (event) => {
    const { onClear } = this.props

    const { value } = event.target

    this.setIsSearching(true)
    this.setCurrentValue(value)

    if (value === '') {
      onClear()
      this.setIsSearching(false)

      return
    }

    this.search(value)
  }

  onResultsChanged = (item) => {
    const { onChange } = this.props

    this.setCurrentValue(item ? item.label : '')
    this.setIsSearching(false)

    onChange(item)
  }

  search = (value) => {
    const { search } = this.props

    this.setIsLoading(true)
    search(value).then(() => {
      this.setIsLoading(false)
    })
  }

  setCurrentValue = (value) => {
    this.setState({ currentValue: value })
  }

  setIsLoading = (value) => {
    this.setState({ isLoading: value })
  }

  setIsSearching = (value) => {
    this.setState({ isSearching: value })
  }

  render () {
    const {
      onBlur,
      onFocus,
      results,
      itemTemplate,
      placeholder
    } = this.props

    const {
      currentValue,
      isLoading,
      isSearching,
      version
    } = this.state

    return (
      <div className={styles.autocomplete}>
        <input
          autoComplete={version}
          type="text"
          placeholder={placeholder}
          className={styles.autocompleteField}
          onBlur={onBlur}
          onChange={this.onInputChanged}
          onFocus={onFocus}
          value={currentValue}
          ref={this.inputRef}
        />

        { isLoading && <span className={styles.loading}>Loading...</span>}

        <AutocompleteResults
          results={results}
          onChange={this.onResultsChanged}
          searching={isSearching}
          itemTemplate={itemTemplate}
          inputRef={this.inputRef}
        />

      </div>
    )
  }
}

export default Autocomplete
