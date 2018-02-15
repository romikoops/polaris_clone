import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AdminNavItem.scss';
import { gradientTextGenerator } from '../../helpers';
import ReactTooltip from 'react-tooltip';
export class AdminNavItem extends Component {
    constructor(props) {
        super(props);
        this.handleLink = this.handleLink.bind(this);
    }
    handleLink() {
        const {target, navFn} = this.props;
        navFn(target);
    }
    render() {
        const { iconClass, theme, text, tooltip} = this.props;
        const textStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
        return(
            <div className={`flex-100 layout-row layout-wrap layout-align-start-center pointy ${styles.nav_item}`} onClick={this.handleLink}>
                <div className="flex-15 layout-row layout-align-center-center nav_icon">
                    <i className={`flex-none fa ${iconClass}`} style={textStyle}></i>
                </div>
                <div className="flex layout-row layout-wrap nav_text">
                    <h3 className="flex-none" >
                        <p data-tip={tooltip} >{text}</p>
                    </h3>
                    <ReactTooltip className={`${styles.nav_tooltip} `} />
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
