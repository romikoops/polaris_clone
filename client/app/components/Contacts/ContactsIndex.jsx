import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../prop-types'
import styles from '../Admin/Admin.scss'
import { AdminClientTile } from '../Admin'
import { userActions, appActions } from '../../actions'

function determinePerPage () {
  // 960px refers to the gt-sm AngularJS Material breakpoint

  return window.innerWidth >= 960 ? 6 : 4
}

class ContactsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {}
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.seeAll = this.seeAll.bind(this)
    this.nextPage = this.nextPage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handlePage = this.handlePage.bind(this)

    this.perPage = determinePerPage()
    props.userDispatch.getContacts({ page: 1, per_page: this.perPage })
  }

  handleClick (client) {
    const { handleClick, userDispatch } = this.props
    if (handleClick) {
      handleClick(client)
    } else {
      userDispatch.getContact(client.id, true)
    }
  }

  seeAll () {
    const { seeAll, userDispatch } = this.props
    if (seeAll) {
      seeAll()
    } else {
      userDispatch.goTo('/admin/contacts')
    }
  }

  nextPage () {
    this.handlePage(1)
  }

  prevPage () {
    this.handlePage(-1)
  }

  handlePage (delta) {
    const { userDispatch, contactsData } = this.props
    const { searchText } = this.state

    const page = contactsData.page + (1 * delta)
    if (searchText) {
      this.searchContactsFromPage(searchText, page)
    } else {
      userDispatch.getContacts({ page, per_page: this.perPage })
    }
  }

  searchContactsFromPage (text, page) {
    const { userDispatch, contactsData } = this.props
    userDispatch.searchContacts(text, page || contactsData.page, this.perPage)
  }

  handleSearchChange (event) {
    const { searchTimeout } = this.state
    const { userDispatch } = this.props
    if (event.target.value === '') {
      userDispatch.getContacts({ page: 1, per_page: this.perPage })
      this.setState({ searchText: null })

      return
    }
    if (searchTimeout) {
      clearTimeout(searchTimeout)
    }
    const newSearchTimeout = setTimeout(this.searchContactsFromPage(event.target.value), 750)
    this.setState({ searchTimeout: newSearchTimeout, searchText: event.target.value })
  }

  render () {
    const {
      theme,
      placeholder,
      tooltip,
      showTooltip,
      contactsData,
      t
    } = this.props
    const { contacts, numContactPages, page } = contactsData

    const contactsArr = contacts && contacts
      .sort((a, b) => b.primary - a.primary)
      .map(client => (
        <AdminClientTile
          key={v4()}
          client={client}
          theme={theme}
          flexClasses="flex-45 flex-gt-sm-33"
          handleClick={this.handleClick}
          tooltip={tooltip}
          showTooltip={showTooltip}
        />
      ))

    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start-start ${styles.searchable}`}>
        <div className={`searchables flex-100 layout-row layout-align-end-center ${styles.searchable_header}`}>
          <div className="input_box_full flex-40 layout-row layout-align-end-center">
            <input
              type="text"
              name="search"
              placeholder={placeholder || t('account:searchContacts')}
              onChange={this.handleSearchChange}
            />
          </div>
        </div>
        <div className={`flex-100 layout-wrap layout-row layout-align-start-start ${styles.searchable_section}`}>
          {contactsArr}
        </div>
        <div className={`flex-95 layout-row layout-align-center-center ${styles.pagination_buttons}`}>
          <div
            className={`
              flex-15 layout-row layout-align-center-center pointy
              ${styles.navigation_button} ${parseInt(page, 10) === 1 ? styles.disabled : ''}
            `}
            onClick={parseInt(page, 10) > 1 ? this.prevPage : null}
          >
            <i className="fa fa-chevron-left" />
            <p className={`${styles.back}`}>
              {t('common:basicBack')}
            </p>
          </div>
          <p>
            {page}
            {' '}
/
            {' '}
            {numContactPages}
            {' '}
          </p>
          <div
            className={`
              flex-15 layout-row layout-align-center-center pointy
              ${styles.navigation_button} ${parseInt(page, 10) < numContactPages ? '' : styles.disabled}
            `}
            onClick={parseInt(page, 10) < numContactPages ? this.nextPage : null}
          >
            <p className={`${styles.forward}`}>
              {t('common:next')}
            </p>
            <i className="fa fa-chevron-right" />
          </div>
        </div>
      </div>
    )
  }
}
ContactsIndex.propTypes = {
  contactsData: PropTypes.objectOf(PropTypes.object),
  handleClick: PropTypes.func,
  userDispatch: PropTypes.shape({
    getContact: PropTypes.func,
    getContacts: PropTypes.func,
    goTo: PropTypes.func
  }),
  seeAll: PropTypes.func,
  placeholder: PropTypes.string,
  theme: PropTypes.theme,
  showTooltip: PropTypes.bool,
  tooltip: PropTypes.string,
  t: PropTypes.func.isRequired
}

ContactsIndex.defaultProps = {
  handleClick: null,
  contactsData: { contacts: [], numContactPages: 1 },
  seeAll: null,
  theme: null,
  showTooltip: false,
  tooltip: '',
  placeholder: '',
  userDispatch: null
}
function mapStateToProps (state) {
  const {
    authentication, app, users
  } = state
  const { tenant } = app
  const { theme } = tenant
  const { user, loggedIn } = authentication
  const { contactsData } = users

  return {
    user,
    tenant,
    loggedIn,
    theme,
    contactsData
  }
}
function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces(['common', 'account'])(connect(mapStateToProps, mapDispatchToProps)(ContactsIndex))
