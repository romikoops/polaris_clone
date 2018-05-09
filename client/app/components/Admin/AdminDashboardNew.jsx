import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { TabBox as TBox } from '../TabBox/TabBox'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import { AdminShipmentStatus as AShipStat } from './AdminShipmentStatus'
import { AdminRequestedShipments as AReqShip } from './AdminRequestedShipments'
import { AdminCustomers as ACust } from './AdminCustomers'
import { AdminAffluency as AAffl } from './AdminAffluency'
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

const tabs = [fcl, lcl]

export class AdminDashboardNew extends Component {
  constructor (props) {
    super(props)
    this.state = {}
  }

  render () {
    const {
      theme,
      shipments
    } = this.props

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

    return (
      <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${astyles.container}`}>
        <TextHeading theme={theme} size={1} text="Dashboard" />
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
        <section className={`layout-row flex-100 layout-wrap layout-align-start-start ${astyles.section}`}>
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
  theme: PropTypes.node,
  shipments: PropTypes.node
}

AdminDashboardNew.defaultProps = {
  theme: null,
  shipments: ['']
}

export default AdminDashboardNew
