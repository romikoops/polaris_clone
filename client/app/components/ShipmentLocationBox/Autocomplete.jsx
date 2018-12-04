import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 as uuidv4 } from 'uuid'
import styles from './ShipmentLocationBox.scss'
import listenerTools from '../../helpers/listeners'
import errorStyles from '../../styles/errors.scss'
import getRequests from './getRequests'
import LoadingSpinner from '../LoadingSpinner/LoadingSpinner'
import { moment } from '../../constants'

class Autocomplete extends PureComponent {
  static filterResults (results, options) {
    let filteredResults
    if (options.types) {
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
      const props = nextProps || this.props
      this.addressService = new props.gMaps.places.AutocompleteService({ types: ['address'] })
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
        }, 5000)

        return {
          hideResults: false,
          resultsTimeout: newTimeout
        }
      }

      const newTimeout = setTimeout(() => {
        this.setState({ hideResults: true })
      }, 5000)

      return {
        hideResults,
        resultsTimeout: newTimeout
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

    this.setState((prevState) => {
      const { value } = target
      const { searchTimeout, input } = prevState
      if (value === input) return {}
      const newTimeout = {}
      if (searchTimeout.address) clearTimeout(searchTimeout.address)
      if (searchTimeout.area) clearTimeout(searchTimeout.area)
      if (value) {
        newTimeout.address = setTimeout(() => this.handleInputChange(value), 750)
        newTimeout.area = setTimeout(() => this.handleAreaInputChange(value), 750)
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
    if (countries.length > 0) {
      options.componentRestrictions = { country: countries }
    }
    this.addressService.getPlacePredictions(options, (results) => {
      if (results && results.length > 0) {
        const filteredResults = Autocomplete.filterResults(results, {})
        this.setState({ addressResults: filteredResults, hideResults: false }, () => {
          this.initKeyboardListener()
          this.showResultsTimer()
        })
      }
    })
  }

  handleAreaInputChange (input) {
    const timestamp = moment().format('x')
    this.setState({ queryingLocations: true, queryTimeStamp: timestamp }, () => getRequests.searchLocations(input, this.props.countries, timestamp, (results, returnedTimestamp) => {
      if (this.state.queryTimeStamp > returnedTimestamp) return
      this.setState({ areaResults: results, hideResults: false, queryingLocations: false }, () => {
        this.initKeyboardListener()
        this.showResultsTimer()
      })
    }))
  }

  handleAddress (result) {
    listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)

    const { handlePlaceSelect } = this.props
    this.getPlace(result.place_id, place => handlePlaceSelect(place))

    this.setState({ hideResults: true, listenerSet: false })
  }

  handleArea (result) {
    listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)

    const { handleLocationSelect } = this.props
    handleLocationSelect(result)

    this.setState({ hideResults: true, listenerSet: false })
  }

  shouldExpandResults () {
    listenerTools.addHandler(document, 'keydown', this.handleKeyEvent)
    this.setState({ hideResults: false })
  }

  render () {
    const { t, hasErrors, theme } = this.props
    const {
      addressResults, areaResults, input, highlightIndex, highlightSection, hideResults, queryingLocations
    } = this.state
    const hasAddressResults = addressResults.length > 0
    const hasAreaResults = areaResults.length > 0
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
      : []
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
      : []
    const inputErrorStyle = hasErrors ? styles.with_errors : ''

    return (
      <div className={`auto_origin ccb_carriage flex-100 layout-row layout-align-center-center ${styles.autocomplete_container}`}>
        <div
          className={`flex-none ${!hideResults && hasResults ? styles.exit_click : styles.hidden}`}
          onClick={() => {
            this.setState({ hideResults: true, listenerSet: false })
            listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)
          }}
        />
        <div
          className={`flex-100 layout-row input_box_full ${styles.autocomplete_input} ${inputErrorStyle}`}
          onClick={() => this.shouldExpandResults()}
        >
          <input
            type="text"
            tabIndex={this.props.tabIndex}
            value={input}
            onChange={this.shouldTriggerInputChange}
            onBlur={this.shouldTriggerInputChange}
          />
        </div>
        <div className={`
          flex-100 layout-row layout-wrap results 
          ${hasResults && !hideResults ? styles.show_results : styles.hide_results}
        `}
        >
          <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.autocomplete_inner}`}>
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
            <div className={`flex-100 layout-row layout-wrap layout-align-start-start address
                ${styles.results_section} ${!hasAddressResults ? styles.hide_results : ''}`}
            >
              <div className={`flex-100 layout-row layout-align-start-center ${styles.results_section_header}`}>
                <p className="flex-none">
                  {' '}
                  {t('common:addresses')}
                </p>
              </div>
              {addressResultCards}
            </div>

          </div>
        </div>
        <span className={errorStyles.error_message} style={{ color: 'white' }}>
          {hasErrors ? t('errors:noRoutes') : ''}
        </span>
      </div>
    )
  }
}

export default withNamespaces(['common', 'errors'])(Autocomplete)
