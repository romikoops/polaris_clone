import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './NavSidebar.scss';
import Style from 'style-it';
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

        return (
            <div>
                <Style>
                    {`
                        .active::before {
                            position: absolute;
                            top: 0;
                            bottom: 0;
                            left: 0;
                            width: 2px;
                            content: '';
                            background-color: ${theme.colors.primary};
                        }
                    `}
                </Style>

{/*                <nav className={styles.menu}>
                    <h3 className={styles['menu-heading']}>
                        {navHeadlineInfo}
                    </h3>*/}
                    {navLinks}
                {/* </nav> */}
            </div>
        );
    }
}

NavSidebar.propTypes = {
    theme: PropTypes.object,
    navLinkInfo: PropTypes.array
};
