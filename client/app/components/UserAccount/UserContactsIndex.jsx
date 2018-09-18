import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import SideOptionsBox from '../Admin/SideOptions/SideOptionsBox'
import styles from '../Admin/Admin.scss'
import ContactsIndex from '../Contacts/ContactsIndex';

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
      numPages,
      t
    } = this.props

    const newButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="New Contact"
          active
          handleNext={toggleNewContact}
          iconClass="fa-plus"
        />
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-space-between-start extra_padding_left">
        <div className="flex-80 flex-sm-95 flex-xs-95 layout-row layout-align-start-start">
          <div className="layout-row layout-wrap flex-100">
            <ContactsIndex
              theme={theme}
              hideFilters
              clients={contacts}
              handleClick={viewContact}
              seeAll={false}
              placeholder="Search Contacts"
            />
            {/* <div className="flex-95 layout-row layout-align-center-center margin_bottom">
              <div
                className={`
              flex-15 layout-row layout-align-center-center pointy
              ${styles.navigation_button} ${this.state.page === 1 ? styles.disabled : ''}
            `}
                onClick={this.state.page > 1 ? this.prevPage : null}
              >
        
                <i className="fa fa-chevron-left" />
                <p>&nbsp;&nbsp;&nbsp;&nbsp;{t('common:basicBack')}</p>
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
                <p>{t('common:next')}&nbsp;&nbsp;&nbsp;&nbsp;</p>
                <i className="fa fa-chevron-right" />
              </div>
            </div> */}
          </div>
          {newContactBox}
        </div>
        <div className="layout-column flex-20 hide-xs hide-sm layout-align-end-end relative" >
          <div className={`layout-column  hide-xs layout-align-end-end ${styles.side_box_style}`}>
            <SideOptionsBox
              header="Data Manager"
              content={
                <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                  <div
                    className={`${
                      styles.action_section
                    } flex-100 layout-row layout-align-center-center layout-wrap`}
                  >
                    {newButton}
                  </div>
                </div>
              }
            />
          </div>
        </div>
      </div>
    )
  }
}

UserContactsIndex.propTypes = {
  theme: PropTypes.theme,
  numPages: PropTypes.number,
  t: PropTypes.func.isRequired,
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

export default translate('common')(UserContactsIndex)
