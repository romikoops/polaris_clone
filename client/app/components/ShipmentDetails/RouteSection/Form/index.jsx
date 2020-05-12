import React, { Component } from 'react'
import Fuse from 'fuse.js'
import { debounce, filter, flatten, flow, has, uniqBy } from 'lodash'
import { withNamespaces } from 'react-i18next'

import AddressFields from './AddressFields/fields'
import Autocomplete from './Autocomplete/autocomplete'
import styles from './index.scss'
import LoadingBackfill from '../../../LoadingBackfill/LoadingBackfill'

class Form extends Component {
  static normalizeHubResults (results) {
    const normalizedResults = (results || []).map((result) => ({
      value: result.nexusId,
      label: result.country ? `${result.nexusName}, ${result.country}` : result.nexusName,
      rawResult: {
        country: result.country,
        id: result.nexusId,
        latitude: result.latitude,
        longitude: result.longitude,
        mots: result.mots,
        name: result.nexusName,
        locode: result.locode
      },
      type: 'hub'
    }))

    return uniqBy(normalizedResults, 'label')
  }

  static normalizeAddressResults (results) {
    const normalizedResults = results || []

    return normalizedResults.filter((item) => item).map((result) => ({
      value: result.id,
      label: result.description,
      rawResult: result,
      type: 'address'
    }))
  }

  static defaultProps = {
    addressFetch: (item) => Promise.resolve(item),
    addressSearch: () => Promise.resolve([]),
    hasHubs: false,
    hasTrucking: false,
    loading: false,
    onBlur: () => {},
    onChange: () => {},
    onFocus: () => {},
    requiresFullAddress: false,
    showAddress: false,
    foundTrucking: false
  }

  constructor (props) {
    super(props)

    this.fuseHubService = new Fuse(this.normalizedHubs, Form.fuseOptions)
    this.fuseAddressService = new Fuse([], Form.fuseAddressOptions)
    this.setAddress = debounce(this.setAddress, 500)
    this.onChildBlur = debounce(this.onChildBlur, 200)
    this.onChildFocus = debounce(this.onChildFocus, 200)

    const isHub = () => has(props, 'value.nexusId')
    this.state = {
      disabledAddress: isHub(),
      results: []
    }
  }

  getEmptyValue = () => ({
    street: '',
    number: '',
    zipCode: '',
    city: '',
    country: '',
    fullAddress: '',
    latitude: null,
    longitude: null
  })

  get placeholder () {
    const { hasHubs, hasTrucking, t } = this.props

    if (hasHubs && hasTrucking) {
      return t('shipment:portOrAddress')
    }

    if (hasHubs) {
      return t('shipment:port')
    }

    return t('shipment:address')
  }

  get normalizedHubs () {
    const { hubs } = this.props

    return Form.normalizeHubResults(hubs)
  }

  setHubItem = (autocompleteItem) => {
    const { onChange } = this.props

    this.setState({ disabledAddress: true })

    onChange(autocompleteItem)
  }

  setAddress = (autocompleteItem) => {
    const { addressFetch, onChange } = this.props

    addressFetch(autocompleteItem).then((address) => {
      this.setState({ disabledAddress: false })

      onChange({ ...autocompleteItem, address })
    })
  }

  setResults = (results) => {
    this.setState({ results })
  }

  onAutocompleteChanged = (item) => {
    if (item.type === 'hub') {
      this.setHubItem(item)

      return
    }

    this.setAddress(item)
  }

  onAutocompleteSearch = (query) => this.search(query)

  onAutocompleteCleared = () => {
    const { onChange } = this.props

    this.setResults([])
    onChange(null)
  }

  onAddressFieldsChanged = (fieldName, fieldValue) => {
    const { onChange, value: propsValue } = this.props

    const value = { ...propsValue, [fieldName]: fieldValue }
    const autocompleteItem = {
      type: 'addressFields',
      rawResult: value
    }

    this.onChildBlur()
    onChange(autocompleteItem, { [fieldName]: fieldValue })
  }

  onAddressFieldsCleared = () => {
    const { onChange } = this.props

    onChange(null)
  }

  onChildBlur = () => {
    const { onBlur } = this.props
    onBlur()
  }

  onChildFocus = () => {
    const { onFocus } = this.props
    onFocus()
  }

  search = (query) => {
    const hubsResults = this.searchHub(query)
    const addressResults = this.searchAddress(query)

    return Promise.all([hubsResults, addressResults]).then((results) => {
      const cleanResults = flow([flatten, filter])(results)

      this.setResults(cleanResults)
    })
  }

  searchAddress = (query) => {
    const { hasTrucking, addressSearch } = this.props

    if (!hasTrucking) {
      return Promise.resolve([])
    }

    return addressSearch(query).then((results) => {
      const normalizedResults = Form.normalizeAddressResults(results)
      this.fuseAddressService.setCollection(normalizedResults)

      return this.fuseAddressService.search(query, { limit: 5 })
    })
  }

  searchHub = (query) => {
    const { hasHubs } = this.props

    if (!hasHubs) {
      return Promise.resolve([])
    }

    this.fuseHubService.setCollection(this.normalizedHubs)
    const results = this.fuseHubService.search(query, { limit: 5 })

    return Promise.resolve(results)
  }

  autocompleteItemTemplate = (item) => {
    if (item.type === 'address') {
      return item.label
    }

    const mots = item.rawResult.mots || []
    const motIconMap = {
      ocean: 'fa fa-ship',
      truck: 'fa fa-truck',
      air: 'fa fa-plane',
      rail: 'fa fa-train'
    }

    const icons = mots.sort().map((mot) => <i className={motIconMap[mot]} />)

    return (
      <div className={styles.autocompleteItem}>
        <strong>
          { icons }
        </strong>
        <span>{item.label}</span>
      </div>
    )
  }

  static fuseOptions = {
    shouldSort: true,
    threshold: 0.1,
    location: 0,
    distance: 100,
    maxPatternLength: 32,
    minMatchCharLength: 1,
    keys: ['label', 'rawResult.locode']
  };

  static fuseAddressOptions = {
    shouldSort: true,
    threshold: 0.6,
    location: 0,
    distance: 100,
    maxPatternLength: 32,
    minMatchCharLength: 1,
    keys: ['label']
  }

  render () {
    const { disabledAddress, results } = this.state
    const { showAddress, loading, requiresFullAddress, value: propsValue, foundTrucking } = this.props

    const value = propsValue || this.getEmptyValue()

    return (
      <div className={styles.routeSelectionForm}>
        <Autocomplete
          itemTemplate={this.autocompleteItemTemplate}
          onBlur={this.onChildBlur}
          onChange={this.onAutocompleteChanged}
          onClear={this.onAutocompleteCleared}
          onFocus={this.onChildFocus}
          placeholder={this.placeholder}
          results={results}
          search={this.onAutocompleteSearch}
          value={value.fullAddress}
        />

        <LoadingBackfill className={styles.loadingWrapper} show={loading} />

        <AddressFields
          disabled={disabledAddress}
          hide={!showAddress || loading}
          onBlur={this.onChildBlur}
          onChange={this.onAddressFieldsChanged}
          onClear={this.onAddressFieldsCleared}
          onFocus={this.onChildFocus}
          requiresFullAddress={requiresFullAddress}
          foundTrucking={foundTrucking}
          value={value}
        />
      </div>
    )
  }
}

export default withNamespaces(['shipment'])(Form)
