import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { adminClientsTooltips as clientTip } from '../../constants'
import { RoundButton } from '../RoundButton/RoundButton'
import { filters, capitalize } from '../../helpers'
import Checkbox from '../Checkbox/Checkbox'
import SideOptionsBox from './SideOptions/SideOptionsBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'
import { AdminClientTile } from './AdminClientTile'

class AdminClientsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {},
      searchFilters: {},
      searchResults: [],
      numPerPage: 9,
      page: 1
    }
  }
  componentWillMount () {
    if (this.props.clients && !this.state.searchResults.length) {
      this.prepFilters()
    }
    this.prepPages()
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  componentWillReceiveProps (nextProps) {
    if (nextProps.clients.length) {
      this.prepFilters(nextProps.clients)
    }
  }
  prepPages () {
    const { clients } = this.props
    const numPages = Math.ceil(clients.length / 12)
    this.setState({ numPages })
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
  deltaPage (val) {
    this.setState((prevState) => {
      const newPageVal = prevState.page + val
      const page = (newPageVal < 1 && newPageVal > prevState.numPages) ? 1 : newPageVal

      return { page }
    })
  }
  render () {
    const { t, theme, adminDispatch, tabReset } = this.props
    const {
      expander, searchFilters, searchResults, page, numPages, numPerPage
    } = this.state
    const sliceStartIndex = (page - 1) * numPerPage
    const sliceEndIndex = (page * numPerPage)
    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text={t('admin:new')}
          active
          handleNext={this.props.toggleNewClient}
          iconClass="fa-plus"
        />
      </div>
    )
    const results = this.applyFilters(searchResults)
    const typeFilters = Object.keys(searchFilters.companies).map(htk => (
      <div className={`${styles.action_section} flex-100 layout-row layout-align-center-center layout-wrap`}>
        <label htmlFor="companies_filter" className="flex-70">
          <p>{capitalize(htk)}</p>
        </label>
        <Checkbox
          id="companies_filter"
          onChange={() => this.toggleFilterValue('companies', htk)}
          checked={searchFilters.companies[htk]}
          theme={theme}
        />
      </div>
    ))
    const dedicatedTiles = results.filter(user => user.has_pricings)
      .slice(sliceStartIndex, sliceEndIndex)
      .map(u => (<AdminClientTile
        key={v4()}
        client={u}
        theme={theme}
        handleClick={() => adminDispatch.getClient(u.id, true)}
        tooltip={clientTip}
        showTooltip
        flexClasses="flex-30 flex-xs-100 flex-sm-50 flex-md-45 flex-gt-lg-15"
      />))
    const openTiles = results
      .slice(sliceStartIndex, sliceEndIndex)
      .map(u => (<AdminClientTile
        key={v4()}
        client={u}
        theme={theme}
        handleClick={() => adminDispatch.getClient(u.id, true)}
        tooltip={clientTip}
        showTooltip
        flexClasses="flex-30 flex-xs-100 flex-sm-50 flex-md-45 flex-gt-lg-15"
      />))
    const paginationRow = (
      <div className="flex-95 layout-row layout-align-center-center margin_bottom">
        <div
          className={`
            flex-15 layout-row layout-align-center-center pointy
            ${styles.navigation_button} ${page === 1 ? styles.disabled : ''}
          `}
          onClick={page > 1 ? () => this.deltaPage(-1) : null}
        >
          <i className="fa fa-chevron-left" />
          <p>&nbsp;&nbsp;&nbsp;&nbsp;{t('common:basicBack')}</p>
        </div>
        {}
        <p>{page}</p>
        <div
          className={`
            flex-15 layout-row layout-align-center-center pointy
            ${styles.navigation_button} ${page < numPages ? '' : styles.disabled}
          `}
          onClick={page < numPages ? () => this.deltaPage(1) : null}
        >
          <p>{t('common:next')}&nbsp;&nbsp;&nbsp;&nbsp;</p>
          <i className="fa fa-chevron-right" />
        </div>
      </div>
    )

    return (
      <div
        className="flex-100 layout-row layout-wrap layout-align-space-between-start
        extra_padding_left"
      >
        <div className={`${styles.component_view} flex-80 layout-row layout-align-start-start`}>
          <Tabs
            wrapperTabs="layout-row flex-25 flex-sm-40 flex-xs-80"
            paddingFixes
            tabReset={tabReset}
          >
            <Tab
              tabTitle={t('common:open')}
              theme={theme}
            >
              <div className="flex-100 layout-row layout-align-start-start layout-wrap header_buffer tab_size" style={{ minHeight: '560px' }}>
                {openTiles}
                {paginationRow}
              </div>
            </Tab>
            <Tab
              tabTitle={t('admin:dedicated')}
              theme={theme}
            >
              <div className="flex-100 layout-row layout-align-start-start layout-wrap header_buffer tab_size">
                {dedicatedTiles}
                {paginationRow}
              </div>
            </Tab>

          </Tabs>
        </div>
        <div className="flex-20 layout-wrap layout-row layout-align-end-end">
          <SideOptionsBox
            header={t('admin:filters')}
            flexOptions="flex-100"
            content={
              <div>

                <div
                  className="flex-100 layout-row layout-wrap layout-align-center-start input_box_full"
                >
                  <input
                    type="text"
                    className="flex-100"
                    value={searchFilters.query}
                    placeholder={t('admin:search')}
                    onChange={e => this.handleSearchQuery(e)}
                  />
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <CollapsingBar
                    showArrow
                    collapsed={!expander.companies}
                    theme={theme}
                    styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                    handleCollapser={() => this.toggleExpander('companies')}
                    text={t('user:company')}
                    faClass="fa fa-building"
                    content={typeFilters}
                  />
                </div>
              </div>
            }
          />
          <SideOptionsBox
            header={t('admin:dataManager')}
            flexOptions="flex-100"
            content={
              <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <CollapsingBar
                  showArrow
                  collapsed={!expander.new}
                  theme={theme}
                  styleHeader={{ background: '#E0E0E0', color: '#4F4F4F' }}
                  handleCollapser={() => this.toggleExpander('new')}
                  text={t('admin:createNewClient')}
                  faClass="fa fa-plus-circle"
                  content={(
                    <div
                      className={`${
                        styles.action_section
                      } flex-100 layout-row layout-align-center-center layout-wrap`}
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
  t: PropTypes.func.isRequired,
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

export default withNamespaces(['admin', 'user', 'common'])(AdminClientsIndex)
