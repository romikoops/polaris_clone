import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { AdminSearchableClients } from './AdminSearchables'
import styles from './Admin.scss'
import FileUploader from '../../components/FileUploader/FileUploader'
import { adminClientsTooltips as clientTip } from '../../constants'
import DocumentsDownloader from '../../components/Documents/Downloader'
import { RoundButton } from '../RoundButton/RoundButton'
import { filters, capitalize } from '../../helpers'
import { Checkbox } from '../Checkbox/Checkbox'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'

class AdminClientsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {},
      searchFilters: {},
      searchResults: []
    }
  }
  componentWillMount () {
    if (this.props.clients && !this.state.searchResults.length) {
      this.prepFilters()
    }
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }

  prepFilters () {
    const { clients } = this.props
    const tmpFilters = {
      companies: {}
    }
    clients.forEach((user) => {
      tmpFilters.companies[user.company_name] = true
    })
    this.setState({
      searchFilters: tmpFilters,
      searchResults: clients
    })
  }
  toggleFilterValue (target, key) {
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        [target]: {
          ...this.state.searchFilters[target],
          [key]: !this.state.searchFilters[target][key]
        }
      }
    })
  }
  handleSearchQuery (e) {
    const { value } = e.target
    this.setState({
      searchFilters: {
        ...this.state.searchFilters,
        query: value
      }
    })
  }
  applyFilters (array) {
    const { searchFilters } = this.state
    const motKeys = Object.keys(searchFilters.companies).filter(key => searchFilters.companies[key])
    const filter1 = array.filter(a => motKeys.includes(a.company_name))
    let filter2
    if (searchFilters.query && searchFilters.query !== '') {
      filter2 = filters.handleSearchChange(
        searchFilters.query,
        ['first_name', 'last_name', 'company_name', 'phone', 'email'],
        filter1
      )
    } else {
      filter2 = filter1
    }

    return filter2
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  render () {
    const { theme, adminDispatch } = this.props
    const { expander, searchFilters, searchResults } = this.state
    const hubUrl = '/admin/clients/process_csv'
    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="New"
          active
          handleNext={this.props.toggleNewClient}
          iconClass="fa-plus"
        />
      </div>
    )
    const results = this.applyFilters(searchResults)
    const typeFilters = Object.keys(searchFilters.companies).map(htk => (
      <div
        className={`${
          styles.action_section
        } flex-100 layout-row layout-align-center-center layout-wrap`}
      >
        <p className="flex-70">{capitalize(htk)}</p>
        <Checkbox
          onChange={() => this.toggleFilterValue('companies', htk)}
          checked={searchFilters.companies[htk]}
          theme={theme}
        />
      </div>
    ))

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-around-start">
        {/* {uploadStatus} */}
        <div className={`${styles.component_view} flex-80 layout-row layout-align-start-start`}>
          <AdminSearchableClients
            theme={theme}
            clients={results}
            adminDispatch={adminDispatch}
            tooltip={clientTip.manage}
            showTooltip
            hideFilters
          />
        </div>
        <div className="layout-column flex-20 flex-md-30 hide-sm hide-xs layout-align-end-end">
          <SideOptionsBox
            header="Filters"
            flexOptions="layout-column flex-20 flex-md-30"
            content={
              <div>

                <div
                  className="flex-100 layout-row layout-wrap layout-align-center-start input_box_full"
                >
                  <input
                    type="text"
                    className="flex-100"
                    value={searchFilters.query}
                    placeholder="Search..."
                    onChange={e => this.handleSearchQuery(e)}
                  />
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    collapsed={!expander.companies}
                    theme={theme}
                    handleCollapser={() => this.toggleExpander('companies')}
                    headingText="Company"
                    faClass="fa fa-building"
                    content={typeFilters}
                  />
                </div>
              </div>
            }
          />
          <SideOptionsBox
            header="Data manager"
            flexOptions="layout-column flex-20 flex-md-30"
            content={
              <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <CollapsingBar
                  collapsed={!expander.upload}
                  theme={theme}
                  handleCollapser={() => this.toggleExpander('upload')}
                  headingText="Upload Data"
                  faClass="fa fa-cloud-upload"
                  content={(
                    <div
                      className={`${
                        styles.action_section
                      } flex-100 layout-row layout-align-center-center layout-wrap`}
                    >
                      <p className="flex-none">Upload Clients Sheet</p>
                      <FileUploader
                        theme={theme}
                        url={hubUrl}
                        type="xlsx"
                        text="Client .xlsx"
                        tooltip={clientTip.upload}
                      />
                    </div>
                  )}
                />
                <CollapsingBar
                  collapsed={!expander.download}
                  theme={theme}
                  handleCollapser={() => this.toggleExpander('download')}
                  headingText="Download Data"
                  faClass="fa fa-cloud-download"
                  content={(
                    <div
                      className={`${
                        styles.action_section
                      } flex-100 layout-row layout-wrap layout-align-center-center`}
                    >
                      <p className="flex-100 center">Download Clients Sheet</p>
                      <DocumentsDownloader theme={theme} target="clients" />
                    </div>
                  )}
                />
                <CollapsingBar
                  collapsed={!expander.new}
                  theme={theme}
                  handleCollapser={() => this.toggleExpander('new')}
                  headingText="Create New Client"
                  faClass="fa fa-plus-circle"
                  content={(
                    <div
                      className={`${
                        styles.action_section
                      } flex-100 layout-row layout-wrap layout-align-center-center`}
                    >
                      {newButton}
                    </div>
                  )}
                />
              </div>
            }
          />
        </div>
      </div>
    )
  }
}

AdminClientsIndex.propTypes = {
  theme: PropTypes.theme,
  clients: PropTypes.arrayOf(PropTypes.clients),
  adminDispatch: PropTypes.shape({
    getClient: PropTypes.func
  }).isRequired,
  toggleNewClient: PropTypes.func.isRequired
}

AdminClientsIndex.defaultProps = {
  theme: null,
  clients: []
}

export default AdminClientsIndex
