import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AdminNavItem.scss';
export class AdminNavItem extends Component {
    constructor(props) {
        super(props);
        this.handleLink = this.handleLink.bind(this);
    }
    handleLink() {
        const {target, navFn} = this.props;
        console.log('NAV ' + target);
        navFn(target);
    }
    render() {
        const { iconClass, theme, text} = this.props;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.nav_item}`} onClick={this.handleLink}>
                <div className="flex-15 layout-row layout-align-center-center">
                    <i className={`flex-none fa ${iconClass}`} style={textStyle}></i>
                </div>
                <div className="flex layout-row layout-wrap">
                    <h3 className="flex-none" style={textStyle}>{text}</h3>
                </div>
            </div>
        );
    }
}
AdminNavItem.propTypes = {
    theme: PropTypes.object,
    iconClass: PropTypes.string,
    text: PropTypes.string,
    url: PropTypes.string,
    navFn: PropTypes.func
};
