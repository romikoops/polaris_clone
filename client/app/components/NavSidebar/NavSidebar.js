import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './NavSidebar.scss';
// import Style from 'style-it';
import {AdminNavItem} from '../../components/Admin/AdminNavItem';
import { v4 } from 'node-uuid';
export class NavSidebar extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const {
            navLinkInfo,
            // activeLink,
            toggleActiveClass,
            theme,
            // navHeadlineInfo
        } = this.props;

        const navLinks = navLinkInfo.map(op => {
            return (
                <AdminNavItem key={v4()} url={op.url} target={op.target} text={op.text} iconClass={op.icon} theme={theme} navFn={toggleActiveClass}/>
            );
        });
        const navStyle = {height: `${navLinks.length * 55}px`};
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-start-center" style={navStyle}>
                {navLinks}
            </div>
        );
    }
}

NavSidebar.propTypes = {
    theme: PropTypes.object,
    navLinkInfo: PropTypes.array
};
