import React, { Component } from 'react'
import { v4 } from 'uuid'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import Fuse from 'fuse.js'
import PropTypes from '../../prop-types'
import styles from '../Admin/Admin.scss'
import { AdminClientTile } from '../Admin'
import { userActions, appActions } from '../../actions'

export class ContactsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      contacts: props.contactsData.contacts,
      page: 1,
      pages: props.contactsData.numContactPages,
      perPage: 6
    }
    this.handleSearchChange = this.handleSearchChange.bind(this)
    this.handleClick = this.handleClick.bind(this)
    this.seeAll = this.seeAll.bind(this)
    this.nextPage = this.nextPage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.handlePage = this.handlePage.bind(this)
    this.getContactsFromPage = this.getContactsFromPage.bind(this)
  }

  componentDidMount () {
    this.determinePerPage()
    // if (this.props.contacts.length < 1) {
    //   this.props.userDispatch.getContacts(false, 1)
    // }
  }

  componentDidUpdate (prevProps) {
    // if (prevProps.contactsData !== this.props.contactsData) {
    //   this.handleSearchChange({ target: { value: '' } })
    // }
  }

  getContactsFromPage (page) {
    const { userDispatch } = this.props
    userDispatch.getContacts(false, page)
  }

  determinePerPage () {
    const width = window.innerWidth
    const newPerPage = width >= 1920 ? 6 : 4
    this.setState({ perPage: newPerPage })
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

  doNothing () {
    console.log(this.state.page)
  }
  
  handlePage (delta) {
    const { contactsData } = this.props
    const { numContactPages } = contactsData
    const { page } = this.state
    const nextPage = +page + (1 * delta)
    let realPage
    if (nextPage > 0 && nextPage <= numContactPages) {
      realPage = nextPage
    } else if (nextPage > 0 && nextPage > numContactPages) {
      realPage = 1
    } else if (nextPage < 0) {
      realPage = numContactPages
    }
    this.setState({ page: realPage }, () => this.getContactsFromPage(realPage))
  }

  handleSearchChange (event) {
    if (event.target.value === '') {
      this.setState({
        contacts: this.props.contactsData.contacts
      })

      return
    }
    const search = (keys) => {
      const options = {
        shouldSort: true,
        tokenize: true,
        threshold: 0.2,
        location: 0,
        distance: 50,
        maxPatternLength: 32,
        minMatchCharLength: 5,
        keys
      }
      const fuse = new Fuse(this.props.contactsData.contacts, options)

      return fuse.search(event.target.value)
    }
    const filteredClients = search(['first_name', 'last_name', 'company_name', 'phone', 'email'])

    this.setState({
      contacts: filteredClients
    })
  }
  render () {
    const {
      theme,
      title,
      placeholder,
      tooltip,
      showTooltip,
      hideFilters,
      contactsData
    } = this.props
    const { contacts, numContactPages } = contactsData
    const {
      page, perPage
    } = this.state
    let contactsArr
    const startIndex = Math.abs(0 + ((page -1) * perPage) -1)
    const endIndex = startIndex + perPage
    if (contacts) {
      contactsArr = contacts
        .sort((a, b) => b.primary - a.primary)
        .slice(startIndex, endIndex)
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
    }
    
    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start-start ${styles.searchable}`}>
        {title ? (
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div
              className="flex-100 layout-align-start-center greyBg"
            >
              <span><b>{title}</b></span>
            </div>
          </div>
        ) : ''}
        <div className={`searchables flex-100 layout-row layout-align-end-center ${styles.searchable_header}`}>
          { !hideFilters
            ? <div className="input_box_full flex-40 layout-row layout-align-end-center">
              <input
                type="text"
                name="search"
                placeholder={placeholder || 'Search contacts'}
                onChange={this.handleSearchChange}
              />
            </div> : '' }
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
            <p>&nbsp;&nbsp;&nbsp;&nbsp;Back</p>
          </div>
          {}
          <p>{page} / {numContactPages} </p>
          <div
            className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${parseInt(page, 10) < numContactPages ? '' : styles.disabled}
                    `}
            onClick={parseInt(page, 10) < numContactPages ? this.nextPage : null}
          >
            <p>Next&nbsp;&nbsp;&nbsp;&nbsp;</p>
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
  hideFilters: PropTypes.bool,
  title: PropTypes.string
}

ContactsIndex.defaultProps = {
  handleClick: null,
  contactsData: {contacts:[], numContactPages: 1},
  seeAll: null,
  theme: null,
  showTooltip: false,
  tooltip: '',
  placeholder: '',
  userDispatch: null,
  hideFilters: false,
  title: ''
}
function mapStateToProps (state) {
  const {
    authentication, tenant, users
  } = state
  const { theme } = tenant.data
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

export default connect(mapStateToProps, mapDispatchToProps)(ContactsIndex)
