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
import { moment } from '../../../../constants'
import addressFromPlace from './addressFromPlace'
import addressFromLocation from './addressFromLocation'
import searchLocations from './searchLocations'
import { errorActions } from '../../../../actions'

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
      areaResults: [],
      hideResults: false,
      highlightIndex: 0,
      highlightSection: 'area',
      searchTimeout: {}
    }
    this.handleInputChange = this.handleInputChange.bind(this)
    this.shouldTriggerInputChange = this.shouldTriggerInputChange.bind(this)
    this.handleArea = this.handleArea.bind(this)
    this.handleAddress = this.handleAddress.bind(this)
    this.deltaHighlightIndex = this.deltaHighlightIndex.bind(this)
    this.handleKeyEvent = this.handleKeyEvent.bind(this)
    this.showResultsTimer = this.showResultsTimer.bind(this)

    const { gMaps } = props
    if (gMaps) {
      this.addressService = new gMaps.places.AutocompleteService({ types: ['address'] })
    }
  }

  componentWillReceiveProps (nextProps) {
    if (typeof this.addressService === 'undefined') {
      const gMaps = nextProps.gMaps || this.props.gMaps
      this.addressService = new gMaps.places.AutocompleteService({ types: ['address'] })
    }
    if ((this.props.input === nextProps.input) || (this.state.input === nextProps.input)) return
    this.setState(() => (nextProps.input === '' ? {} : { input: nextProps.input, setFromProps: true }))
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
    this.setState(
      { listenerSet: true },
      () => listenerTools.addHandler(document, 'keydown', this.handleKeyEvent)
    )
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
    const { highlightSection, highlightIndex } = this.state
    const results = this.state[`${highlightSection}Results`]

    if (highlightSection === 'area') {
      this.handleArea(results[highlightIndex])
    } else {
      this.handleAddress(results[highlightIndex])
    }
  }

  deltaHighlightIndex (delta) {
    const { highlightIndex, highlightSection } = this.state
    const altSection = highlightSection === 'area' ? 'address' : 'area'
    const results = this.state[`${highlightSection}Results`]
    const altResults = this.state[`${altSection}Results`]
    let newIndex = highlightIndex + delta
    let newSection = highlightSection
    if (newIndex > results.length - 1) {
      newIndex = 0
      newSection = highlightSection === 'area' ? 'address' : 'area'
    } else if (newIndex < 0) {
      newIndex = altResults.length - 1
      newSection = highlightSection === 'address' ? 'area' : 'address'
    }
    this.setState({ highlightIndex: newIndex, highlightSection: newSection })
  }

  shouldTriggerInputChange (event) {
    const { target } = event
    const { scope } = this.props

    this.setState((prevState) => {
      const { value } = target
      const { searchTimeout, input } = prevState
      if (value === input) return {}
      const newTimeout = {}
      if (searchTimeout.address) clearTimeout(searchTimeout.address)
      if (searchTimeout.area) clearTimeout(searchTimeout.area)
      if (value) {
        newTimeout.address = setTimeout(() => this.handleInputChange(value), 750)
        newTimeout.area = scope.require_full_address ? null : setTimeout(() => this.handleAreaInputChange(value), 750)
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

    countryArrays.filter(arr => arr.length > 0).forEach((countryArray) => {
      if (countryArray.length > 0) {
        options.componentRestrictions = { country: countryArray }
      }
      const sameQuery = input.includes(this.state.prevInput)
      this.setState({ queryingGoogle: true, prevInput: input }, () => {
        this.addressService.getPlacePredictions(options, (results, status) => {
          if (['ZERO_RESULTS', 'OK'].includes(status)) {
            const filteredResults = Autocomplete.filterResults(results, {})
            this.setState((prevState) => {
              const { addressResults } = prevState

              const mergedAddressResults = sameQuery ? uniqBy([...addressResults, ...filteredResults], 'id') : filteredResults
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
              const realResults = fuse.search(input)

              return {
                hasGoogleErrors: false,
                addressResults: realResults,
                hideResults: false,
                queryingGoogle: false,
                noResults: status === 'ZERO_RESULTS'
              }
            }, () => {
              this.initKeyboardListener()
              this.showResultsTimer()
            })
          } else {
            this.autocompleteErrors(status)
          }
        })
      })
    })
  }

  handleAreaInputChange (input) {
    const countries = this.props.countries.filter(cc => cc !== 'nl')
    if (countries.length > 0) {
      const timestamp = moment().format('x')
      this.setState({ queryingLocations: true, queryTimeStamp: timestamp }, () => searchLocations(input, countries, timestamp, (results, returnedTimestamp) => {
        if (this.state.queryTimeStamp > returnedTimestamp) return
        this.setState({ areaResults: results, hideResults: false, queryingLocations: false }, () => {
          this.initKeyboardListener()
          this.showResultsTimer()
        })
      }))
    }
    
  }

  handleAddress (result) {
    listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)

    const {
      target, onAutocompleteTrigger, gMaps, map
    } = this.props

    this.getPlace(result.place_id, (place) => {
      addressFromPlace(place, gMaps, map, (address) => {
        onAutocompleteTrigger(target, address)
      })
    })

    this.setState({ hideResults: true, listenerSet: false })
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
      t, hasErrors, theme, scope, target
    } = this.props
    const {
      addressResults,
      areaResults,
      input,
      highlightIndex,
      highlightSection,
      hideResults,
      queryingLocations,
      queryingGoogle,
      errorKey,
      hasGoogleErrors,
      noResults
    } = this.state
    const hasAddressResults = addressResults.length > 0
    const showArea = !scope.require_full_address
    const hasAreaResults = !scope.require_full_address && areaResults.length > 0
    const hasResults = hasAddressResults || hasAreaResults
    const numResults = hasAddressResults && hasAreaResults ? 4 : 6
    const highlightStyle = {
      borderBottom: `5px solid ${theme.colors.primary}`
    }
    const areaResultCards = hasAreaResults
      ? areaResults
        .slice(0, numResults)
        .map((result, i) => {
          const isHighlighted = highlightIndex === i && highlightSection === 'area'

          return (
            <div
              className={`flex-100 layout-row layout-align-center-center pointy ${styles.autocomplete_card}`}
              style={isHighlighted ? highlightStyle : {}}
              onClick={() => this.handleArea(result)}
              key={uuidv4()}
            >
              <p className="flex">{result.description}</p>
            </div>
          )
        })
      : [
        <div
          className={`flex-100 layout-row layout-align-center-center pointy ${styles.autocomplete_card}`}
          key={uuidv4()}
        >
          <p className="flex">{t('common:noAreaResults')}</p>
        </div>
      ]
    const addressResultCards = hasAddressResults
      ? addressResults
        .filter(result => !areaResults.some(element => element.description === result.description))
        .slice(0, numResults)
        .map((result, i) => {
          const isHighlighted = highlightIndex === i && highlightSection === 'address'

          return (
            <div
              className={`flex-100 layout-row layout-align-center-center
          ${styles.autocomplete_card} pointy ccb_result`}
              style={isHighlighted ? highlightStyle : {}}
              onClick={() => this.handleAddress(result)}
              key={uuidv4()}
            >
              <p className="flex">{result.description}</p>
            </div>)
        })
      : [
        <div
          className={`flex-100 layout-row layout-align-center-center pointy ${styles.autocomplete_card}`}
          key={uuidv4()}
        >
          <p className="flex">{t('common:noResults')}</p>
        </div>
      ]

    return (
      <div
        className={`auto_origin ccb_carriage flex-100 layout-row layout-wrap layout-align-center-center ${styles.autocomplete_container}`}
      >
        <div
          className={`flex-none ccb_backdrop ${!hideResults && hasResults ? styles.exit_click : styles.hidden}`}
          onClick={() => {
            this.setState({ hideResults: true, listenerSet: false })
            listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)
          }}
        />
        <div
          className={`flex-100 layout-row input_box_full ${styles.autocomplete_input}`}
          onClick={() => this.shouldExpandResults()}
        >
          <input
            type="text"
            name={`${target}-fullAddress`}
            tabIndex={this.props.tabIndex}
            value={input}
            onChange={this.shouldTriggerInputChange}
            onBlur={this.shouldTriggerInputChange}
            data-hj-whitelist
            autoComplete="new-password"
          />

        </div>
        <div className={`
          flex-100 layout-row layout-wrap results
          ${!hideResults ? styles.show_results : styles.hide_results}
        `}
        >
          <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.autocomplete_inner}`}>
            { showArea ? (
              <div className={`
              flex-100 layout-row layout-wrap layout-align-start-start area
              ${styles.results_section} ${!hasAreaResults && !queryingLocations ? styles.hide_results : ''}
            `}
              >
                <div className={`flex-100 layout-row layout-align-start-center ${styles.results_section_header}`}>
                  <p className="flex-none">{t('common:areaPostalCodes')}</p>
                </div>
                {queryingLocations ? <LoadingSpinner size="small" /> : areaResultCards}
              </div>
            ) : '' }
            <div className={`flex-100 layout-row layout-wrap layout-align-start-start address
                ${styles.results_section} ${!hasAddressResults && !noResults ? styles.hide_results : ''}`}
            >
              <div className={`flex-100 layout-row layout-align-start-center ${styles.results_section_header}`}>
                <p className="flex-none">
                  {' '}
                  {t('common:addresses')}
                </p>
              </div>
              {queryingGoogle ? <LoadingSpinner size="small" /> : addressResultCards}
            </div>

          </div>
        </div>
        {/* <span className={hasErrors || hasGoogleErrors ? styles.errors : styles.no_errors} style={{ color: 'white' }}>
          {hasErrors ? t('errors:noRoutes') : ''}
          {hasGoogleErrors ? t(errorKey) : ''}
        </span> */}
      </div>
    )
  }
}

function mapDispatchToProps (dispatch) {
  return {
    errorDispatch: bindActionCreators(errorActions, dispatch)
  }
}

export default withNamespaces(['common', 'errors'])(
  connect(null, mapDispatchToProps)(Autocomplete)
)
