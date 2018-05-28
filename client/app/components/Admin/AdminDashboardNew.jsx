import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { TabBox as TBox } from '../TabBox/TabBox'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import { AdminShipmentStatus as AShipStat } from './AdminShipmentStatus'
import { AdminRequestedShipments as AReqShip } from './AdminRequestedShipments'
import { AdminCustomers as ACust } from './AdminCustomers'
import { AdminAffluency as AAffl } from './AdminAffluency'
import { AdminFCL as Fcl } from './AdminFCL'
import { AdminShipmentCard as AShipCard } from './AdminShipmentCard'
import { AdminRouteList as ARouteList } from './AdminRouteList'
import { TextHeading } from '../TextHeading/TextHeading'
import astyles from './AdminDashboardNew.scss'
// import { adminDashboard as adminTip, activeRoutesData } from '../../constants'

const fcl = (<span>Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  Integer at est ipsum. Aenean venenatis maximus dapibus. Aliquam faucibus nisi
  id faucibus interdum. Vivamus justo felis, vulputate eget metus ac, congue
  molestie libero. Praesent erat mauris, consequat eu pharetra vitae, suscipit id risus.
  Donec suscipit, mi ac faucibus laoreet, ex enim maximus tellus, eu laoreet risus sem at magna.
  Vestibulum non dictum ligula. Donec ante massa, porttitor quis felis sit amet, pretium
  tincidunt nisl.</span>)

const lcl = (<span>In elementum lorem sed ante venenatis, at sollicitudin velit rhoncus.
  Vivamus tempor nunc eu est iaculis, id tincidunt magna finibus.
  Donec ac ante luctus orci tempor auctor quis non ante. Aenean a diam vel est venenatis
  fringilla eget at mi. Sed rutrum lacus elit, nec auctor eros rutrum gravida. Cras
  tincidunt, sapien vel finibus dignissim, eros nibh suscipit nunc, non fringilla eros
  nisi nec neque. Ut interdum porttitor magna at varius. Donec varius ipsum purus, et
  semper odio malesuada at. Vivamus turpis elit, sollicitudin a aliquet vitae, pharetra
  et justo.</span>)

export class AdminDashboardNew extends Component {
  static prepShipment (baseShipment, clients, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].first_name} ${clients[shipment.user_id].last_name}`
      : ''
    shipment.companyName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].company_name}`
      : ''
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]] : ''
    shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]] : ''
    return shipment
  }

  constructor (props) {
    super(props)
    this.state = {}
  }

  render () {
    const {
      clients,
      theme,
      shipments,
      hubHash
    } = this.props

    const clientHash = {}
    if (clients) {
      clients.forEach((cl) => {
        clientHash[cl.id] = cl
      })
    }

    const preparedRequestedShipments = shipments.requested.map(s => AdminDashboardNew
      .prepShipment(s, clientHash, hubHash))

    const ShipmentStatus = (
      <AShipStat
        shipments={shipments}
      />
    )

    const RequestedShipments = (
      <AReqShip
        requested={['asd', 'foobar', 'something', 'yo', 'yeehaw', 'wat']}
      />
    )

    const Customers = (
      <ACust />
    )

    const Affluency = (
      <AAffl />
    )

    const FclComp = (
      <Fcl />
    )

    const ShipCard = (
      <AShipCard
        shipment={preparedRequestedShipments[0]}
        hubs={hubHash}
      />
    )

    const RouteList = (
      <ARouteList
        shipments={preparedRequestedShipments}
      />
    )

    const tabs = [FclComp, lcl]

    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${astyles.container}`}>
        <TextHeading theme={theme} size={1} text="Dashboard" />
        <section className={`layout-row flex-100 layout-wrap layout-align-space-between-stretch ${astyles.section}`}>
          <GBox
            title=""
            subtitle=""
            flex={50}
            component={ShipCard}
          />
          <GBox
            title=""
            subtitle=""
            flex={40}
            padding
            component={RouteList}
          />
        </section>
        <section className={`layout-row flex-100 layout-wrap layout-align-space-between-stretch ${astyles.section}`}>
          <GBox
            title="Something"
            subtitle="Sub"
            flex={40}
            padding
            component={ShipmentStatus}
          />
          <GBox
            title="Something"
            subtitle="Sub"
            flex={55}
            padding
            component={RequestedShipments}
          />
        </section>
        <section className={`layout-row flex-100 layout-wrap layout-align-space-between-stretch ${astyles.section}`}>
          <GBox
            title="Something"
            subtitle="Sub"
            flex={55}
            padding
            component={fcl}
          />
          <div className={`layout-column flex-40 layout-wrap layout-align-space-between-stretch ${astyles.sectionpart}`}>
            <GBox
              title="Something"
              subtitle="Sub"
              flex={65}
              fullWidth
              padding
              component={Customers}
            />
            <GBox
              title="Something"
              subtitle="Sub"
              flex={30}
              fullWidth
              padding
              component={Affluency}
            />
          </div>
        </section>
        <section className={`layout-row flex-100 layout-wrap layout-align-start-stretch ${astyles.section}`}>
          <TBox
            tabs={['FCL', 'LCL']}
            components={tabs}
          />
        </section>
      </div>
    )
  }
}

AdminDashboardNew.propTypes = {
  clients: PropTypes.arrayOf(PropTypes.client),
  theme: PropTypes.theme,
  shipments: PropTypes.shape({
    open: PropTypes.arrayOf(PropTypes.shipment),
    requested: PropTypes.arrayOf(PropTypes.shipment),
    finished: PropTypes.arrayOf(PropTypes.shipment)
  }),
  hubHash: PropTypes.objectOf(PropTypes.hub)
}

AdminDashboardNew.defaultProps = {
  clients: [],
  theme: null,
  shipments: {},
  hubHash: {}
}

export default AdminDashboardNew
