import React from 'react'
import PropTypes from '../../prop-types'
import { AdminSearchableClients } from '../Admin/AdminSearchables'
import { RoundButton } from '../RoundButton/RoundButton'
import SideOptionsBox from '../Admin/SideOptions/SideOptionsBox'
// import styles from './UserAccount.scss';
// import FileUploader from '../FileUploader/FileUploader';
export function UserContactsIndex ({
  theme, contacts, viewContact, toggleNewContact, newContactBox
}) {
  const sideBoxStyle = {
    position: 'fixed',
    top: '160px',
    right: '0px',
    backgroundColor: 'white'
  }

  return (
    <div className="flex-100 layout-row layout-wrap layout-align-space-between-start extra_padding_left">
      <div className="flex-75 flex-sm-95 flex-xs-95 layout-row layout-align-start-start">
        <AdminSearchableClients
          theme={theme}
          hideFilters
          clients={contacts}
          handleClick={viewContact}
          seeAll={false}
          placeholder="Search Contacts"
        />
        {newContactBox}
      </div>
      <div className="layout-column flex-20 flex-md-15 flex-sm-10 show-gt-xs hide-xs layout-align-end-end" style={sideBoxStyle}>
        <SideOptionsBox
          header="Data Manager"
          flexOptions="layout-column flex-20 flex-md-15 flex-sm-10"
          content={
            <div className="layout-row flex layout-align-center-center">
              <div className="flex-70 layout-row layout-align-start-center">
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

UserContactsIndex.propTypes = {
  theme: PropTypes.theme,
  contacts: PropTypes.arrayOf(PropTypes.object),
  viewContact: PropTypes.func.isRequired,
  toggleNewContact: PropTypes.func,
  newContactBox: PropTypes.objectOf(PropTypes.any)
}

UserContactsIndex.defaultProps = {
  theme: null,
  contacts: [],
  toggleNewContact: null,
  newContactBox: {}
}

export default UserContactsIndex
