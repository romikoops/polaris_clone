import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminNavItem} from './AdminNavItem';
export class AdminNav extends Component {
    constructor(props) {
        super(props);
        this.state = {
            links: [
                {
                    icon: 'fa-tachometer',
                    text: 'Dashboard',
                    url: '/admin/dashboard'
                },
                {
                    icon: 'fa-building-o',
                    text: 'Hubs',
                    url: '/admin/hubs'
                },
                {
                    icon: 'fa-calculator',
                    text: 'Service Charges',
                    url: '/admin/service_charges'
                },
                {
                    icon: 'fa-area-chart',
                    text: 'Pricing',
                    url: '/admin/pricing'
                },
                {
                    icon: 'fa-list',
                    text: 'Schedules',
                    url: '/admin/schedules'
                },
                {
                    icon: 'fa-truck',
                    text: 'Trucking',
                    url: '/admin/trucking'
                }
            ]
        };
    }
    render() {
        const {theme, navLink} = this.props;
        const {links} = this.state;
        const linkItems = links.map((li) =>
            <AdminNavItem url={li.url} text={li.text} iconClass={li.icon} theme={theme} navFn={navLink}/>
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
