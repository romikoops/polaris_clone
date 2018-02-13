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
                // {
                //     icon: 'fa-calculator',
                //     text: 'Service Charges',
                //     url: '/admin/service_charges',
                //     target: 'serviceCharges'
                // },
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
                },
                {
                    icon: 'fa-map-signs',
                    text: 'Routes',
                    url: '/admin/routes',
                    target: 'routes'
                },
                {
                    icon: 'fa-magic',
                    text: 'Set Up',
                    url: '/admin/wizard',
                    target: 'wizard'
                }
            ]
        };
    }
    render() {
        const {theme, navLink, user} = this.props;
        const {links} = this.state;
        const linkItems = links.map((li) =>
            <AdminNavItem key={v4()} url={li.url} target={li.target} text={li.text} iconClass={li.icon} theme={theme} navFn={navLink}/>
        );
        if (user.role_id === 3) {
            linkItems.push(<AdminNavItem key={v4()} url={'/super_admin/upload'} target={'super_admin'} text={'Super Admin'} iconClass={'fa-star'} theme={theme} navFn={navLink}/>);
        }
        const navStyle = {height: `${linkItems.length * 55}px`};

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center" style={navStyle}>
                {linkItems}
            </div>
        );
    }
}
AdminNav.propTypes = {
    theme: PropTypes.object,
    navLink: PropTypes.func
};
