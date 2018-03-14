import React, { Component } from 'react'
import PropTypes from 'prop-types'
// import styles from '../../Admin.scss'
// import {
//   AdminSearchableShipments,
//   AdminSearchableRoutes,
//   AdminSearchableClients
// } from '../../AdminSearchables'
// import { adminDashboard as adminTip } from '../../../../constants'
import { history } from '../../../../helpers'
// import { RoundButton } from '../../../RoundButton/RoundButton'

export class AdminUploadsSuccess extends Component {
  static goBack () {
    history.goBack()
  }
  static prepShipment (baseShipment, clients, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].first_name} ${clients[shipment.user_id].last_name}`
      : ''
    shipment.companyName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].company_name}`
      : ''
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : ''
    shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : ''
    return shipment
  }
  constructor (props) {
    super(props)
    this.viewShipment = this.viewShipment.bind(this)
  }
  viewShipment (shipment) {
    this.props.viewShipment(shipment)
  }

  render () {
    console.log(this.props)
    // const {selectedShipment} = this.state;
    const { theme, data } = this.props
    const { stats, results } = data
    // ;

    // const clientHash = {}
    // clients.forEach((cl) => {
    //   clientHash[cl.id] = cl
    // })

    // const mergedShipments = results.shipments
    //   ? results.shipments.map(sh => AdminUploadsSuccess.prepShipment(sh, clientHash, hubHash))
    //   : []

    // const shipmentView = (
    //   <div className="flex-100 layout-row layout-wrap layout-align-start-start">
    //     <AdminSearchableShipments
    //       handleClick={this.viewShipment}
    //       hubs={hubHash}
    //       adminDispatch={adminDispatch}
    //       shipments={mergedShipments}
    //       title={`${title} Shipments`}
    //       theme={theme}
    //       // handleShipmentAction={handleShipmentAction}
    //       tooltip={adminTip.requested}
    //       seeAll={false}
    //     />

    //     {mergedShipments.length === 0 ? (
    //       <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
    //         <div className="flex-100 layout-row layout-align-end-center">
    //           <div className="flex-none layout-row">
    //             <RoundButton
    //               theme={theme}
    //               size="small"
    //               text="Back"
    //               handleNext={() => AdminUploadsSuccess.goBack()}
    //               iconClass="fa-chevron-left"
    //             />
    //           </div>
    //         </div>
    //         <div
    //           className={`flex-100 layout-row layout-align-space-between-center ${
    //             styles.sec_subheader
    //           }`}
    //         >
    //           <p className={` ${styles.sec_subheader_text} flex-none`}> No Shipments yet</p>
    //         </div>
    //         <p className="flex-none"> As shipments are requested, they will appear here</p>
    //       </div>
    //     ) : (
    //       ''
    //     )}
    //   </div>
    // )
    const statView = Object.keys(stats).map(k => (
      <div className="flex-100 layout-row layout-align-space-between-center">
        <div className="flex-none layout-row layout-align-start-center">{k}</div>
        <div className="flex-none layout-row layout-align-start-center">{stats[k]}</div>
      </div>
    ))
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <div className="flex-100 layout-row layout-align-start-center">
            <h3 className="flex-none">Upload Successful!</h3>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">{statView}</div>
      </div>
    )
  }
}
AdminUploadsSuccess.propTypes = {
  theme: PropTypes.theme,
  title: PropTypes.string,
  target: PropTypes.string,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  clients: PropTypes.arrayOf(PropTypes.clients),
  handleShipmentAction: PropTypes.func.isRequired,
  viewShipment: PropTypes.func.isRequired,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  adminDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminUploadsSuccess.defaultProps = {
  theme: null,
  hubs: [],
  shipments: [],
  clients: [],
  hubHash: {},
  adminDispatch: {},
  title: '',
  target: ''
}

export default AdminUploadsSuccess
