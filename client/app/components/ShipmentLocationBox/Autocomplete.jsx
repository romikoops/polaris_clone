import React, { PureComponent } from 'react'
import PropTypes from '../../prop-types'
import styles from './ShipmentLocationBox.scss'

class Autocomplete extends PureComponent {
  constructor(props) {
    super(props)
    this.state = { 
      input: props.input,
      results: [],
      highlightIndex: 0
     }
     this.handleInputChange = this.handleInputChange.bind(this)
     this.handleSelect = this.handleSelect.bind(this)
     this.deltaHighlightIndex = this.deltaHighlightIndex.bind(this)
     this.handleKeyEvent = this.handleKeyEvent.bind(this)
  }

  componentDidMount () {
    this.intializeAutocomplete()
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.input !== this.state.input) {
      debugger
      this.setState({input: nextProps.input})
    }
  }

  componentWillUnmount () {
    document.removeEventListener('keydown', this.handleKeyEvent)
  }

  intializeAutocomplete () {
    const { options } = this.props
    const service = new this.props.gMaps.places.AutocompleteService(options)
    this.setState({service})
  }

  initKeyboardListener () {
    document.addEventListener('keydown', this.handleKeyEvent)
  }

  getPlace (placeId, callback) {
    const service = new this.props.gMaps.places.PlacesService(this.props.map)
    service.getDetails({ placeId }, place => callback(place))
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
      case 'Enter':
        this.handleSelectFromIndex()
        break
    }
  }

  handleSelectFromIndex() {
    const { results, highlightIndex } = this.state
    this.handleSelect(results[highlightIndex])
  }

  deltaHighlightIndex (delta) {
    const { results, highlightIndex } = this.state
    let newIndex = highlightIndex + delta
    if (newIndex > results.length - 1) {
      newIndex = 0
    } else if (newIndex < 0) {
      newIndex = results.length -1
    }
    this.setState({ highlightIndex: newIndex })
  }

  handleInputChange (event) {
    const {service} = this.state
    const input = event.target.value
    if (!input || input === '') return this.setState({input: ''})
    service.getPlacePredictions({ input }, (results) => {
      if (results && results.length > 0) {
        this.setState({ results, input, hideResults: false }, () => this.initKeyboardListener())
      }
    })
  }
  handleSelect (result) {
    const { handlePlaceSelect } = this.props
    this.getPlace(result.place_id, place => handlePlaceSelect(place))
    this.setState({ hideResults: true })
  }



  render() {
    const { results, input, highlightIndex, hideResults } = this.state
    const hasResults = results.length > 0
    const resultCards = hasResults ? results.map((result, i) => {
      return (
      <div
        className={`flex-100 layout-row layout-align-center-center
          ${styles.autocomplete_card} ${highlightIndex === i ? styles.highlighted : ''}
        `}
        onClick={() => this.handleSelect(result)}
      >
        <p className="flex">{result.description}</p>
      </div>)
    }) : []

    return ( 
      <div className={`flex-100 layout-row layout-align-center-center ${styles.autocomplete_container}`}>
        <div className={`flex-100 layout-row input_box_full ${styles.autocomplete_input}`}>
          <input
            type="text"
            value={input}
            onChange={this.handleInputChange}
          />
        </div>
        <div className={`flex-100 layout-row layout-wrap input_box_full
          ${hasResults && !hideResults ? styles.show_results : styles.hide_results}`}>
          {resultCards}
        </div>
      </div>
     );
  }
}

Autocomplete.propTypes = {
  gMaps: PropTypes.objectOf(PropTypes.func).isRequired,
  options: PropTypes.objectOf(PropTypes.string),
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  map: PropTypes.func.isRequired,
  input: PropTypes.string,
  handlePlaceSelect: PropTypes.func.isRequired
}
Autocomplete.defaultProps = {
  theme: {},
  input: '',
  options: {}
}
 
export default Autocomplete;