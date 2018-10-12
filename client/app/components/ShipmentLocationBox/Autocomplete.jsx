import React, { PureComponent } from 'react'
import Truncate from 'react-truncate'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './ShipmentLocationBox.scss'
import listenerTools from '../../helpers/listeners'
import errorStyles from '../../styles/errors.scss'

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
      highlightSection: 'area'
    }
    this.handleInputChange = this.handleInputChange.bind(this)
    this.shouldTriggerInputChange = this.shouldTriggerInputChange.bind(this)
    this.handleSelect = this.handleSelect.bind(this)
    this.deltaHighlightIndex = this.deltaHighlightIndex.bind(this)
    this.handleKeyEvent = this.handleKeyEvent.bind(this)
    this.showResultsTimer = this.showResultsTimer.bind(this)
  }

  componentDidMount () {
    this.intializeAutocomplete()
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.input !== this.state.input) {
      this.setState({ input: nextProps.input })
    }
  }

  componentWillUnmount () {
    listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)
  }

  getPlace (placeId, callback) {
    const service = new this.props.gMaps.places.PlacesService(this.props.map)
    service.getDetails({ placeId }, place => callback(place))
  }

  intializeAutocomplete () {
    const areaOptions = { types: ['regions'] }
    const addressOptions = { types: ['address'] }
    const areaService = new this.props.gMaps.places.AutocompleteService(areaOptions)
    const addressService = new this.props.gMaps.places.AutocompleteService(addressOptions)
    this.setState({ areaService, addressService })
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

      return prevState
    })
  }

  handleSelectFromIndex () {
    const { highlightSection, highlightIndex } = this.state
    const results = this.state[`${highlightSection}Results`]
    this.handleSelect(results[highlightIndex])
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
    const { value } = event.target
    const { searchTimeout, input } = this.state
    if (value === input) return null
    if (searchTimeout) {
      clearTimeout(searchTimeout)
    }
    const newTimeout = setTimeout(this.handleInputChange(event.target.value), 750)
    this.setState({
      input: event.target.value,
      searchTimeout: newTimeout
    })
  }

  handleInputChange (input) {
    const { areaService, addressService } = this.state
    if (!input || input === '') return this.setState({ input: '' })
    areaService.getPlacePredictions({ input }, (results) => {
      if (results && results.length > 0) {
        const filteredResults = Autocomplete.filterResults(results, { types: ['postal_code', 'locality'] })
        this.setState({ areaResults: filteredResults, hideResults: false }, () => {
          this.initKeyboardListener()
          this.showResultsTimer()
        })
      }
    })
    addressService.getPlacePredictions({ input }, (results) => {
      if (results && results.length > 0) {
        const filteredResults = Autocomplete.filterResults(results, {})
        this.setState({ addressResults: filteredResults, hideResults: false }, () => {
          this.initKeyboardListener()
          this.showResultsTimer()
        })
      }
    })

    return ''
  }
  handleSelect (result) {
    listenerTools.removeHandler(document, 'keydown', this.handleKeyEvent)

    const { handlePlaceSelect } = this.props
    this.getPlace(result.place_id, place => handlePlaceSelect(place))
    this.setState({ hideResults: true, listenerSet: false })
  }
  shouldExpandResults () {
    listenerTools.addHandler(document, 'keydown', this.handleKeyEvent)
    this.setState({ hideResults: false })
  }
  render () {
    const { t, hasErrors, theme } = this.props
    const {
      addressResults, areaResults, input, highlightIndex, highlightSection, hideResults
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
              className={`flex-100 layout-row layout-align-center-center pointy
                ${styles.autocomplete_card}`}
              style={isHighlighted ? highlightStyle : {}}
              onClick={() => this.handleSelect(result)}
            >
              <p className="flex"><Truncate lines={1} >{result.description}</Truncate></p>
            </div>)
        }) : []
    const addressResultCards = hasAddressResults
      ? addressResults
        .filter(result => !areaResults.some(element => element.description === result.description))
        .slice(0, numResults)
        .map((result, i) => {
          const isHighlighted = highlightIndex === i && highlightSection === 'address'

          return (
            <div
              className={`flex-100 layout-row layout-align-center-center
          ${styles.autocomplete_card} pointy`}
              style={isHighlighted ? highlightStyle : {}}
              onClick={() => this.handleSelect(result)}
            >
              <p className="flex"><Truncate lines={1} >{result.description}</Truncate> </p>
            </div>)
        }) : []
    const inputErrorStyle = hasErrors ? styles.with_errors : ''

    return (
      <div className={`auto_origin flex-100 layout-row layout-align-center-center ${styles.autocomplete_container}`}>
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
            value={input}
            onChange={this.shouldTriggerInputChange}
            onBlur={this.shouldTriggerInputChange}
          />
        </div>
        <div className={`flex-100 layout-row layout-wrap results
            ${hasResults && !hideResults ? styles.show_results : styles.hide_results}`}
        >
          <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.autocomplete_inner}`}>
            <div className={`flex-100 layout-row layout-wrap layout-align-start-start area
                ${styles.results_section} ${!hasAreaResults ? styles.hide_results : ''}`}
            >
              <div className={`flex-100 layout-row layout-align-start-center 
                  ${styles.results_section_header}`}
              >
                <p className="flex-none">{t('common:areaPostalCodes')}</p>
              </div>
              {areaResultCards}
            </div>
            <div className={`flex-100 layout-row layout-wrap layout-align-start-start address
                ${styles.results_section} ${!hasAddressResults ? styles.hide_results : ''}`}
            >
              <div className={`flex-100 layout-row layout-align-start-center 
                  ${styles.results_section_header}`}
              >
                <p className="flex-none"> {t('common:addresses')}</p>
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

Autocomplete.propTypes = {
  gMaps: PropTypes.objectOf(PropTypes.func).isRequired,
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  map: PropTypes.func.isRequired,
  input: PropTypes.string,
  hasErrors: PropTypes.bool,
  handlePlaceSelect: PropTypes.func.isRequired
}
Autocomplete.defaultProps = {
  theme: {},
  input: '',
  hasErrors: false
}

export default translate(['common', 'errors'])(Autocomplete)
