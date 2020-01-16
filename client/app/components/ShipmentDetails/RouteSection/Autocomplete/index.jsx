import React, { PureComponent } from 'react'
import Fuse from 'fuse.js'
import { withNamespaces } from 'react-i18next'
import { camelCase, uniqBy } from 'lodash'
import { v4 as uuidv4 } from 'uuid'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import styles from './index.scss'
import listenerTools from '../../../../helpers/listeners'
import LoadingSpinner from '../../../LoadingSpinner/LoadingSpinner'
import addressFromPlace from './addressFromPlace'
import addressFromLocation from './addressFromLocation'
import { errorActions } from '../../../../actions'
import ResultsCards from './ResultCards'

class Autocomplete extends PureComponent {
  static filterResults (results, options) {
    let filteredResults
    if (!results) {
      filteredResults = []
    } else if (options.types) {
      filteredResults = results.filter(result => result.types.some(resultType => options.types.includes(resultType)))
    } else {
      filteredResults = results
    }

    return filteredResults
  }

  constructor (props) {
    super(props)
    this.state = {
      input: props.input,
      addressResults: [],
      hubResults: [],
      areaResults: [],
      hideResults: false,
      highlightIndex: 0,
      searchTimeout: {}
    }
    this.handleInputChange = this.handleInputChange.bind(this)
    this.shouldTriggerInputChange = this.shouldTriggerInputChange.bind(this)
    this.handleArea = this.handleArea.bind(this)
    this.handleAddress = this.handleAddress.bind(this)
    this.deltaHighlightIndex = this.deltaHighlightIndex.bind(this)
    this.handleKeyEvent = this.handleKeyEvent.bind(this)
    this.showResultsTimer = this.showResultsTimer.bind(this)
    this.handleHubFuse = this.handleHubFuse.bind(this)

    const { gMaps } = props
    if (gMaps) {
      this.addressService = new gMaps.places.AutocompleteService({
        types: ['address']
      })
    }
  }

  componentWillReceiveProps (nextProps) {
    if (typeof this.addressService === 'undefined') {
      const gMaps = nextProps.gMaps || this.props.gMaps
      this.addressService = new gMaps.places.AutocompleteService({
        types: ['address']
      })
    }
    if (
      this.props.input === nextProps.input ||
      this.state.input === nextProps.input
    ) { return }
    this.setState(() => (nextProps.input === ''
      ? {}
      : { input: nextProps.input, setFromProps: true }))
  }

  componentWillUnmount () {
    listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)
  }

  getPlace (placeId, callback) {
    const service = new this.props.gMaps.places.PlacesService(this.props.map)
    service.getDetails({ placeId }, place => callback(place))
  }

  initKeyboardListener () {
    const { listenerSet } = this.state
    if (listenerSet) return
    this.setState({ listenerSet: true }, () => listenerTools.addHandler(document, 'keydown', this.handleKeyEvent))
  }

  handleKeyEvent (event) {
    const keyName = event.key
    switch (keyName) {
      case 'ArrowDown':
        this.deltaHighlightIndex(1)
        break
      case 'ArrowUp':
        this.deltaHighlightIndex(-1)
        break
      case 'Down':
        this.deltaHighlightIndex(1)
        break
      case 'Up':
        this.deltaHighlightIndex(-1)
        break
      case 'Enter':
        event.preventDefault()

        this.handleSelectFromIndex()
        break
      default:
        break
    }
  }

  showResultsTimer () {
    this.setState((prevState) => {
      const { resultsTimeout, hideResults } = prevState
      if (resultsTimeout) {
        clearTimeout(resultsTimeout)
      }
      if (hideResults) {
        const newTimeout = setTimeout(() => {
          this.setState({ hideResults: true })
        }, 10000)

        return {
          hideResults: false,
          resultsTimeout: newTimeout
        }
      }

      const newTimeout = setTimeout(() => {
        this.setState({ hideResults: true })
      }, 10000)

      return {
        hideResults,
        resultsTimeout: newTimeout
      }
    })
  }

  showErrorsTimer () {
    this.setState((prevState) => {
      const { errorTimeout, hasGoogleErrors } = prevState
      if (errorTimeout) {
        clearTimeout(errorTimeout)
      }
      if (!hasGoogleErrors) {
        const newTimeout = setTimeout(() => {
          this.setState({ hasGoogleErrors: false })
        }, 10000)

        return {
          hasGoogleErrors: true,
          errorTimeout: newTimeout
        }
      }

      const newTimeout = setTimeout(() => {
        this.setState({ hasGoogleErrors: false })
      }, 10000)

      return {
        hasGoogleErrors,
        errorTimeout: newTimeout
      }
    })
  }

  handleSelectFromIndex () {
    const { highlightIndex } = this.state
    const results = this.combinedResults()
    this.handleAddress(results[highlightIndex])
  }

  combinedResults () {
    const {
      areaResults, hubResults, addressResults
    } = this.state

    const { scope } = this.props

    const hasAddressResults = addressResults.length > 0
    const hasAreaResults = !scope.require_full_address && areaResults.length > 0
    const numResults = hasAddressResults && hasAreaResults ? 4 : 6

    const { t, target } = this.props
    const addressSeparator = [{ separator: true, label: target === 'origin' ? t('shipment:preCarriage') : t('shipment:onCarriage') }]
    const portSeparator = { separator: true, label: t('common:ports') }
    const addressResultSlice = areaResults.concat(addressResults).slice(0, numResults)
    const hubsResultsSliced = hubResults.slice(0, numResults)

    if (addressResultSlice.length === 0 && hubsResultsSliced.length === 0) {
      return []
    }

    const addressResultsWithHeader = addressSeparator.concat(addressResultSlice)
    if (hubsResultsSliced.length > 0) {
      return addressResultsWithHeader.concat(portSeparator).concat(hubsResultsSliced)
    }

    return addressResultsWithHeader
  }

  deltaHighlightIndex (delta) {
    const {
      highlightIndex
    } = this.state

    const combinedResults = this.combinedResults()
    const length = combinedResults.length - 1

    let newIndex = highlightIndex + delta

    if (newIndex > length) {
      newIndex = 0
    }

    if (combinedResults.length === 0) {
      return
    }

    if (combinedResults[newIndex].separator) {
      newIndex += delta
    }

    if (newIndex < 0) {
      newIndex = length
    }

    if (newIndex > length) {
      newIndex = 0
    }

    this.setState({ highlightIndex: newIndex })
  }

  shouldTriggerInputChange (event) {
    const { target } = event

    this.setState((prevState) => {
      const { value } = target
      const { searchTimeout, input } = prevState
      if (value === input) return {}
      const newTimeout = {}
      if (searchTimeout.address) clearTimeout(searchTimeout.address)
      if (searchTimeout.area) clearTimeout(searchTimeout.area)
      if (value) {
        newTimeout.address = setTimeout(
          () => this.handleInputChange(value),
          750
        )
      }

      return {
        input: value,
        searchTimeout: newTimeout
      }
    })
  }

  handleInputChange (input) {
    const { countries } = this.props
    const options = { input }
    const countryArrays = [[]]
    if (countries.length > 0) {
      let start = 0
      while (start < countries.length) {
        countryArrays.push(countries.slice(start, start + 5))
        start += 5
      }
    }
    const hubResults = this.handleHubFuse(input)
    countryArrays
      .filter(arr => arr.length > 0)
      .forEach((countryArray) => {
        if (countryArray.length > 0) {
          options.componentRestrictions = { country: countryArray }
        }
        const sameQuery = input.includes(this.state.prevInput)
        this.setState({ queryingGoogle: true, prevInput: input }, () => {
          this.addressService.getPlacePredictions(
            options,
            (results, status) => {
              if (['ZERO_RESULTS', 'OK'].includes(status)) {
                const filteredResults = Autocomplete.filterResults(results, {})
                this.setState(
                  (prevState) => {
                    const { addressResults } = prevState

                    const mergedAddressResults = sameQuery
                      ? uniqBy([...addressResults, ...filteredResults], 'id')
                      : filteredResults
                    const fuseOptions = {
                      shouldSort: true,
                      threshold: 0.6,
                      location: 0,
                      distance: 100,
                      maxPatternLength: 32,
                      minMatchCharLength: 1,
                      keys: ['description']
                    }

                    const fuse = new Fuse(mergedAddressResults, fuseOptions)
                    const truckingResults = fuse.search(input)

                    return {
                      hasGoogleErrors: false,
                      addressResults: truckingResults,
                      hubResults,
                      hideResults: false,
                      queryingGoogle: false,
                      noResults: status === 'ZERO_RESULTS'
                    }
                  },
                  () => {
                    this.initKeyboardListener()
                    this.showResultsTimer()
                  }
                )
              } else {
                this.autocompleteErrors(status)
              }
            }
          )
        })
      })
  }

  handleHubFuse (input) {
    const { hubOptions } = this.props

    const hubFuseOptions = {
      shouldSort: true,
      threshold: 0.1,
      location: 0,
      distance: 100,
      maxPatternLength: 32,
      minMatchCharLength: 1,
      keys: ['label']
    }
    const hubFuse = new Fuse(hubOptions, hubFuseOptions)

    return hubFuse.search(input)
  }

  handleAddress (result) {
    listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)
    const {
      target,
      onAutocompleteTrigger,
      onDropdownSelect,
      gMaps,
      map,
      handleHubSelect
    } = this.props

    if (result === undefined) {
      return
    }
    if (result.label !== undefined) {
      onDropdownSelect(target, result)
      handleHubSelect(true)
      this.setState({ hideResults: true, listenerSet: false })
    } else {
      this.getPlace(result.place_id, (place) => {
        addressFromPlace(place, gMaps, map, (address) => {
          onAutocompleteTrigger(target, address)
        })
      })
      handleHubSelect(false)
      this.setState({ hideResults: true, listenerSet: false })
    }
    this.setState({ input: result.label || result.description })
  }

  handleArea (location) {
    if (location) {
      listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)

      const { target, onAutocompleteTrigger } = this.props

      onAutocompleteTrigger(target, addressFromLocation(location))

      this.setState({ hideResults: true, listenerSet: false })
    }
  }

  shouldExpandResults () {
    listenerTools.addHandler(document, 'keydown', this.handleKeyEvent)
    this.setState({ hideResults: false })
  }

  autocompleteErrors (status) {
    const { errorDispatch, target } = this.props
    const { input } = this.state
    let errorKey = ''
    if (['REQUEST_DENIED', 'OVER_QUERY_LIMIT'].includes(status)) {
      errorKey = 'errors:unknownError'
    } else {
      errorKey = `errors:${camelCase(status)}`
    }
    const error = {
      component: 'RouteSection',
      code: '1101',
      target,
      side: target === 'origin' ? 'left' : 'right',
      targetAddress: input
    }
    errorDispatch.setError(error)
  }

  render () {
    const {
      t, theme, scope
    } = this.props
    const {
      addressResults,
      areaResults,
      input,
      highlightIndex,
      hideResults,
      queryingGoogle,
      noResults
    } = this.state
    const hasAddressResults = addressResults.length > 0
    const hasAreaResults = !scope.require_full_address && areaResults.length > 0
    const hasResults = hasAddressResults || hasAreaResults

    return (
      <div
        className={`auto_origin ccb_carriage flex-100 layout-row layout-wrap layout-align-center-center ${styles.autocomplete_container}`}
      >
        <div
          className={`flex-none ccb_backdrop ${
            !hideResults && hasResults ? styles.exit_click : styles.hidden
          }`}
          onClick={() => {
            this.setState({ hideResults: true, listenerSet: false })
            listenerTools.removeHandler(
              document,
              'keydown',
              this.handleKeyEvent
            )
          }}
        />
        <div
          className={`flex-100 layout-row input_box_full ${styles.autocomplete_input}`}
          onClick={() => this.shouldExpandResults()}
        >
          <input
            type="text"
            autoComplete={uuidv4()}
            name={`${uuidv4()}-fullAddress`}
            tabIndex={this.props.tabIndex}
            value={input}
            placeholder={t('shipment:portOrAddress')}
            onChange={this.shouldTriggerInputChange}
            onBlur={this.shouldTriggerInputChange}
            data-hj-whitelist
          />
        </div>
        <div
          className={`
          flex-100 layout-row layout-wrap results
          ${!hideResults ? styles.show_results : styles.hide_results}
        `}
        >
          <div
            className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.autocomplete_inner}`}
          >
            <div
              className={`flex-100 layout-row layout-wrap layout-align-start-start address
                ${styles.results_section} ${
        !hasAddressResults && !noResults ? styles.hide_results : ''
      }`}
            >
              {queryingGoogle ? (
                <LoadingSpinner size="small" />
              ) : (
                <ResultsCards
                  combinedResults={this.combinedResults()}
                  highlightIndex={highlightIndex}
                  theme={theme}
                  handleAddress={this.handleAddress}
                  t={t}
                  areaResults={areaResults}
                />)}
            </div>
          </div>
        </div>
      </div>
    )
  }
}

function mapDispatchToProps (dispatch) {
  return {
    errorDispatch: bindActionCreators(errorActions, dispatch)
  }
}

export default withNamespaces(['common', 'errors', 'shipment'])(
  connect(null, mapDispatchToProps)(Autocomplete)
)
