import React from 'react'
import PropTypes from '../../prop-types'
import { AdminSearchableClients } from '../Admin/AdminSearchables'
// import styles from './UserAccount.scss';
// import FileUploader from '../FileUploader/FileUploader';
export function UserContactsIndex ({ theme, contacts, viewContact }) {
  return (
    <div className="flex-100 layout-row layout-wrap layout-align-start-start">
      <AdminSearchableClients
        theme={theme}
        clients={contacts}
        title="All Contacts"
        handleClick={viewContact}
        seeAll={false}
        placeholder="Search Contacts"
      />
    </div>
  )
}

UserContactsIndex.propTypes = {
  theme: PropTypes.theme,
  contacts: PropTypes.arrayOf(PropTypes.object),
  viewContact: PropTypes.func.isRequired
}

UserContactsIndex.defaultProps = {
  theme: null,
  contacts: []
}

export default UserContactsIndex
