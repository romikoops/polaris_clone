import React from 'react'
import { v4 } from 'uuid'
import styles from '../AdminShipments.scss'
import adminStyles from '../Admin.scss'
import PropTypes from '../../../prop-types'
import AlternativeGreyBox from '../../GreyBox/AlternativeGreyBox'

export default function ContactDetailsRow ({
  contacts,
  style
}) {
  const nArray = []
  let shipperContact = ''
  let consigneeContact = ''
  if (contacts) {
    contacts.forEach((n) => {
      if (n.type === 'notifyee') {
        nArray.push(<div className={`${styles.contact_box} ${styles.notifyee_box} flex-100 layout-wrap layout-column`}>
          <div className="layout-column flex">
            <div className={`${styles.info_row} flex-100 layout-row`}>
              <i className={`${adminStyles.icon} fa fa-user flex-none`} style={style} />
              <h4>{n.contact.first_name} {n.contact.last_name}</h4>
            </div>
            <div className={`${styles.info_row} flex-100 layout-row`}>
              <i className={`${adminStyles.icon} fa fa-building flex-none`} style={style} />
              <p>{n.contact.company_name}</p>
            </div>
          </div>
        </div>)
        if (nArray.length % 2 === 1) {
          nArray.push(<div key={v4()} className="flex-45 layout-row" />)
        }
      }
      if (n.type === 'shipper') {
        shipperContact = (
          <div className={`${styles.contact_box} flex-100 layout-wrap layout-column`}>
            <div className="layout-column layout-sm-row flex-sm-100">
              <div className="layout-sm-column flex-sm-30">
                <div className={`${styles.info_row} flex-100 layout-row`}>
                  <i className={`${adminStyles.icon} fa fa-user flex-none`} style={style} />
                  <h4>{n.contact.first_name} {n.contact.last_name}</h4>
                </div>
                <div className={`${styles.info_row} ${styles.padding_bottom_contact} flex-100 layout-row`}>
                  <i className={`${adminStyles.icon} fa fa-building flex-none`} style={style} />
                  <p>{n.contact.company_name}</p>
                </div>
              </div>
              <div className="layout-sm-column flex-sm-40">
                <div className={`${styles.info_row} flex-100 layout-row`}>
                  <i className={`${adminStyles.icon} fa fa-envelope flex-none`} style={style} />
                  <p>{n.contact.email}</p>
                </div>
                <div className={`${styles.info_row} flex-100 layout-row`}>
                  <i className={`${adminStyles.icon} fa fa-phone flex-none`} style={style} />
                  <p>{n.contact.phone}</p>
                </div>
              </div>
              <div className={`${styles.info_row} ${styles.last_margin} flex-100 layout-row layout-align-sm-center-center flex-sm-30`}>
                <i className={`${adminStyles.icon} fa fa-map flex-none`} style={style} />
                <p>{n.location ? `${n.location.street} ${n.location.street_number}` : ''} <br />
                  <strong>{n.location ? `${n.location.zip_code} ${n.location.city}` : ''}</strong> <br />
                  {/* {n.location ? `${n.location.country}` : ''} */}
                </p>
              </div>
            </div>
          </div>
        )
      }
      if (n.type === 'consignee') {
        consigneeContact = (
          <div className={`${styles.contact_box} flex-100 layout-wrap layout-column`}>
            <div className="layout-column layout-sm-row flex-sm-100">
              <div className="layout-sm-column flex-sm-30">
                <div className={`${styles.info_row} flex-100 layout-row`}>
                  <i className={`${adminStyles.icon} fa fa-user flex-none layout-align-center-center`} style={style} />
                  <h4>{n.contact.first_name} {n.contact.last_name}</h4>
                </div>
                <div className={`${styles.info_row} ${styles.padding_bottom_contact} flex-100 layout-row`}>
                  <i className={`${adminStyles.icon} fa fa-building flex-none`} style={style} />
                  <p>{n.contact.company_name}</p>
                </div>
              </div>
              <div className="layout-sm-column flex-sm-40">
                <div className={`${styles.info_row} flex-100 layout-row`}>
                  <i className={`${adminStyles.icon} fa fa-envelope flex-none`} style={style} />
                  <p>{n.contact.email}</p>
                </div>
                <div className={`${styles.info_row} flex-100 layout-row`}>
                  <i className={`${adminStyles.icon} fa fa-phone flex-none`} style={style} />
                  <p>{n.contact.phone}</p>
                </div>
              </div>
              <div className={`${styles.info_row} ${styles.last_margin} flex-100 layout-row layout-align-sm-center-center flex-sm-30`}>
                <i className={`${adminStyles.icon} fa fa-map flex-none`} style={style} />
                <p>{n.location ? `${n.location.street} ${n.location.street_number}` : ''} <br />
                  <strong>{n.location ? `${n.location.zip_code} ${n.location.city}` : ''}</strong> <br />
                  {/* {n.location ? `${n.location.country}` : ''} */}
                </p>
              </div>
            </div>
          </div>
        )
      }
    })
  }

  return (
    <div className={`layout-row flex-100 layout-wrap ${adminStyles.margin_bottom} ${adminStyles.margin_box_right}`}>
      <div className="flex-100 flex-gt-sm-40 layout-row layout-align-center-center card_padding_right">
        <AlternativeGreyBox
          title="Shipper"
          wrapperClassName="layout-row flex-100"
          contentClassName="layout-row layout-wrap flex-100"
          content={shipperContact}
          showTitle
        />
      </div>
      <div className="flex-100 flex-gt-sm-40 layout-row layout-align-center-center card_padding_right">
        <AlternativeGreyBox
          title="Consignee"
          wrapperClassName="layout-row flex-100"
          contentClassName="layout-row layout-wrap flex-100"
          content={consigneeContact}
          showTitle
        />
      </div>
      <div className="flex-100 flex-gt-sm-20 layout-row layout-align-center-center ">
        <AlternativeGreyBox
          title="Notifyees"
          wrapperClassName="layout-row flex-100 height_100"
          contentClassName="layout-row layout-wrap flex-100"
          content={nArray}
          showTitle
        />
      </div>
    </div>
  )
}

ContactDetailsRow.propTypes = {
  contacts: PropTypes.arrayOf(PropTypes.contact).isRequired,
  style: PropTypes.objectOf(PropTypes.string)
}

ContactDetailsRow.defaultProps = {
  style: {}
}
