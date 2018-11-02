import React from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import SideOptionsBox from '../Admin/SideOptions/SideOptionsBox'
import styles from '../Admin/Admin.scss'
import ContactsIndex from '../Contacts/ContactsIndex'

function UserContactsIndex ({
  theme,
  toggleNewContact,
  newContactBox,
  t
}) {
  const newButton = (
    <div className="flex-none layout-row">
      <RoundButton
        theme={theme}
        size="small"
        text={t('common:newContact')}
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
            placeholder={t('account:searchContacts')}
          />
        </div>
        {newContactBox}
      </div>
      <div className="layout-column flex-20 hide-xs hide-sm layout-align-end-end relative" >
        <div className={`layout-column  width_100 hide-xs layout-align-end-end ${styles.side_box_style}`}>
          <SideOptionsBox
            header={t('account:dataManager')}
            content={
              <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className={`${styles.action_section} flex-100 layout-row layout-align-center-center layout-wrap`}>
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

UserContactsIndex.propTypes = {
  theme: PropTypes.theme,
  toggleNewContact: PropTypes.func,
  newContactBox: PropTypes.objectOf(PropTypes.any),
  t: PropTypes.func.isRequired
}

UserContactsIndex.defaultProps = {
  theme: null,
  toggleNewContact: null,
  newContactBox: {}
}

export default withNamespaces(['common', 'account'])(UserContactsIndex)
