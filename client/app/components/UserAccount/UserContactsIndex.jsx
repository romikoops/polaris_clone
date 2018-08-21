import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { AdminSearchableClients } from '../Admin/AdminSearchables'
import { RoundButton } from '../RoundButton/RoundButton'
import SideOptionsBox from '../Admin/SideOptions/SideOptionsBox'
import styles from '../Admin/Admin.scss'

export class UserContactsIndex extends Component {
  constructor (props) {
    super(props)

    this.state = {
      page: 1
    }
    this.handlePage = this.handlePage.bind(this)
    this.nextPage = this.nextPage.bind(this)
    this.prevPage = this.prevPage.bind(this)
    this.getContactsFromPage = this.getContactsFromPage.bind(this)
  }
  getContactsFromPage (page) {
    const { userDispatch } = this.props
    userDispatch.getContacts(true, page)
  }

  handlePage (direction) {
    this.setState((prevState) => {
      const nextPage = prevState.page + (1 * direction)
      this.getContactsFromPage(nextPage > 0 ? nextPage : 1)

      return { page: prevState.page + (1 * direction) }
    })
  }

  nextPage () {
    this.handlePage(1)
  }
  prevPage () {
    this.handlePage(-1)
  }

  render () {
    const {
      theme,
      contacts,
      viewContact,
      toggleNewContact,
      newContactBox,
      numPages
    } = this.props

    const sideBoxStyle = {
      position: 'fixed',
      top: '160px',
      right: '0px',
      backgroundColor: 'white'
    }

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-between-start extra_padding_left">
        <div className="flex-75 flex-sm-95 flex-xs-95 layout-row layout-align-start-start">
          <div className="layout-column">
            <AdminSearchableClients
              theme={theme}
              hideFilters
              clients={contacts}
              handleClick={viewContact}
              seeAll={false}
              placeholder="Search Contacts"
            />
            <div className="flex-95 layout-row layout-align-center-center margin_bottom">
              <div
                className={`
              flex-15 layout-row layout-align-center-center pointy
              ${styles.navigation_button} ${this.state.page === 1 ? styles.disabled : ''}
            `}
                onClick={this.state.page > 1 ? this.prevPage : null}
              >
                {/* style={this.state.page === 1 ? { display: 'none' } : {}} */}
                <i className="fa fa-chevron-left" />
                <p>&nbsp;&nbsp;&nbsp;&nbsp;Back</p>
              </div>
              {}
              <p>{this.state.page}</p>
              <div
                className={`
              flex-15 layout-row layout-align-center-center pointy
              ${styles.navigation_button} ${this.state.page < numPages ? '' : styles.disabled}
            `}
                onClick={this.state.page < numPages ? this.nextPage : null}
              >
                <p>Next&nbsp;&nbsp;&nbsp;&nbsp;</p>
                <i className="fa fa-chevron-right" />
              </div>
            </div>
          </div>
          {newContactBox}
        </div>
        <div className="layout-column flex-20 hide-xs layout-align-end-end" style={sideBoxStyle}>
          <SideOptionsBox
            header="Data Manager"
            flexOptions="layout-column flex-20 flex-md-15 flex-sm-10"
            content={
              <div className="layout-row flex layout-align-center-center">
                <div className="flex-none layout-row layout-align-center-center">
                  <RoundButton
                    theme={theme}
                    size="small"
                    text="New Contact"
                    active
                    handleNext={toggleNewContact}
                    iconClass="fa-plus"
                  />
                </div>
              </div>
            }
          />
        </div>
      </div>
    )
  }
}

UserContactsIndex.propTypes = {
  theme: PropTypes.theme,
  numPages: PropTypes.number,
  contacts: PropTypes.arrayOf(PropTypes.object),
  userDispatch: PropTypes.func.isRequired,
  viewContact: PropTypes.func.isRequired,
  toggleNewContact: PropTypes.func,
  newContactBox: PropTypes.objectOf(PropTypes.any)
}

UserContactsIndex.defaultProps = {
  theme: null,
  contacts: [],
  numPages: 1,
  toggleNewContact: null,
  newContactBox: {}
}

export default UserContactsIndex
