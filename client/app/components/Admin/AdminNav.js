import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminNavItem} from './AdminNavItem';
import { v4 } from 'node-uuid';
export class AdminNav extends Component {
    constructor(props) {
        super(props);
        this.state = {
            links: [
                {
                    icon: 'fa-tachometer',
                    text: 'Dashboard',
                    url: '/admin/dashboard',
                    target: 'dashboard'
                },
                {
                    icon: 'fa-ship',
                    text: 'Shipments',
                    url: '/admin/shipments',
                    target: 'shipments'
                },
                {
                    icon: 'fa-building-o',
                    text: 'Hubs',
                    url: '/admin/hubs',
                    target: 'hubs'
                },
                {
                    icon: 'fa-calculator',
                    text: 'Service Charges',
                    url: '/admin/service_charges',
                    target: 'serviceCharges'
                },
                {
                    icon: 'fa-area-chart',
                    text: 'Pricing',
                    url: '/admin/pricing',
                    target: 'pricing'
                },
                {
                    icon: 'fa-list',
                    text: 'Schedules',
                    url: '/admin/schedules',
                    target: 'schedules'
                },
                {
                    icon: 'fa-truck',
                    text: 'Trucking',
                    url: '/admin/trucking',
                    target: 'trucking'
                },
                {
                    icon: 'fa-users',
                    text: 'Client',
                    url: '/admin/clients',
                    target: 'clients'
                }
            ]
        };
    }
    render() {
        const {theme, navLink} = this.props;
        const {links} = this.state;
        const linkItems = links.map((li) =>
            <AdminNavItem key={v4()} url={li.url} target={li.target} text={li.text} iconClass={li.icon} theme={theme} navFn={navLink}/>
        );
        console.log(linkItems);
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                {linkItems}
            </div>
        );
    }
}
AdminNav.propTypes = {
    theme: PropTypes.object,
    navLink: PropTypes.func
};
