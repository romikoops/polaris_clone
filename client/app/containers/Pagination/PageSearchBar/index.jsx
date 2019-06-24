import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './PageSearchBar.scss'

function PageSearchBar ({
  handleSearch, t
}) {
  return (
    <div className={`layout-row layout-align-end-center ${styles.page_navigation}`}>
      <div className="input_box_full flex-100 flex-gt-sm-40 layout-row layout-align-end-center">
        <input
          type="text"
          name="search"
          placeholder={t('account:searchContacts')}
          onChange={handleSearch}
        />
      </div>
    </div>
  )
}

export default withNamespaces('common')(PageSearchBar)
