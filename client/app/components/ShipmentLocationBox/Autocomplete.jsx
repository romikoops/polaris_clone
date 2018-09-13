import React, { PureComponent } from 'react'
import PropTypes from '../../prop-types'
class Autocomplete extends PureComponent {
  constructor(props) {
    super(props);
    this.state = { 
      input: props.input,
      results: []
     }
     this.handleInputChange = this.handleInputChange.bind(this)
     this.handleSelect = this.handleSelect.bind(this)
  }
  componentDidMount () {
    this.intializeAutocomplete()
  }

  intializeAutocomplete () {
    const { options } = this.props
    const service = new this.props.gMaps.places.AutocompleteService(options)
    this.setState({service})
  }

  handleInputChange (event) {
    const {service} = this.state
    const input = event.target.value
    service.getPlacePredictions({ input }, (results) => {
      if (results.length > 0) {
        this.setState({ results, input })
      }
    })
  }
  handleSelect (result) {
    const { handlePlaceSelect } = this.props
    getPlace(result.place_id, place => handlePlaceSelect(place))
  }

  getPlace (placeId, callback) {
    const service = new this.props.gMaps.places.PlacesService(this.state.map)
    service.getDetails({ placeId }, place => callback(place))
  }

  render() {
    const { results, input } = this.state
    const hasResults = results.length > 0
    const resultCards = hasResults ? results.map((result) => {
      return (
      <div
        className="flex-100 layout-row layout-align-center-center"
        onClick={() => this.handleSelect(result)}
      >
        <p className="flex">{result.description}</p>
      </div>)
    }) : []

    return ( 
      <div className={`flex-100 layout-row layout-align-center-center ${style.autocomplete_container}`}>
        <div className={`flex-100 layout-row input_box_full ${style.autocomplete_input}`}>
          <input
            type="text"
            value={input}
            onChange={this.handleInputChange}
          />
        </div>
        <div className={`flex-100 layout-row input_box_full
          ${hasResults ? style.show_results : styles.hide_results}`}>
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