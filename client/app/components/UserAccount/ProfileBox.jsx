import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './UserAccount.scss'

const ProfileBox = ({
  user, style, t, hide
}) => !hide && (
  <div
    className={`flex-100 layout-row layout-align-start-start
    layout-wrap section_padding relative ${styles.content_details}`}
  >
    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:fullName')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none">
          {`${user.first_name} ${user.last_name}`}
        </p>
      </div>
    </div>
    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:email')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none">
          {user.email}
        </p>
      </div>
    </div>
    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:phone')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none">
          {user.phone}
        </p>
      </div>
    </div>
    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:company')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none">
          {user.company_name}
        </p>
      </div>
    </div>
    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:vatNo')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none">
          {user.vat_number || '-'}
        </p>
      </div>
    </div>
    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:companyNumber')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none">
          {user.company_number || '-'}
        </p>
      </div>
    </div>
    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:currency')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none">
          {user.currency || '-'}
        </p>
      </div>
    </div>
  </div>
)

ProfileBox.defaultProps = {
  style: {}
}

export default withNamespaces(['user', 'common'])(ProfileBox)
