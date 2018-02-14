import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AdminHubTile.scss';
import ReactTooltip from 'react-tooltip';
import { v4 } from 'node-uuid';

export class AdminHubTile extends Component {
    constructor(props) {
        super(props);
        this.state = {
            redirect: false
        };
        this.handleLink = this.handleLink.bind(this);
        this.clickEv = this.clickEv.bind(this);
    }
    handleLink() {
        const {target, navFn} = this.props;
        console.log('NAV ' + target);
        navFn(target);
    }
    clickEv() {
        const { hub, handleClick } = this.props;
        if (handleClick) {
            handleClick(hub.data);
        }
    }
    render() {
        const { theme, hub, tooltip, showTooltip } = this.props;
        debugger;
        if (!hub) {
            return '';
        }
        const bg1 = hub && hub.location && hub.location.photo  ? { backgroundImage: 'url(' + hub.location.photo + ')' } : { backgroundImage: 'url("https://assets.itsmycargo.com/assets/default_images/aerial_port_sm.jpg")'};
        const gradientStyle = {
            background:
                theme && theme.colors
                    ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${
                        theme.colors.secondary
                    })`
                    : 'black'
        };
        const tooltipId = v4();
        return(
            <div className={`something flex-none ${styles.hub_card} layout-row pointy`} style={bg1} onClick={this.clickEv} data-for={tooltipId} data-tip={tooltip}>
                <div className={styles.fade}></div>
                <div className={`${styles.content} layout-row`}>
                    <div className="flex-15 layout-column layout-align-start-center">
                        <i className="flex-none fa fa-map-marker" style={gradientStyle}/>
                    </div>
                    <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                        <h4 className="flex-100"> {hub.data.name} </h4>
                        <p className="flex-100">{ hub.location.geocoded_address }</p>
                    </div>
                </div>
                {showTooltip ? <ReactTooltip className={`${styles.tooltip}`} id={tooltipId}/> : ''}
            </div>
        );
    }
}
AdminHubTile.propTypes = {
    theme: PropTypes.object,
    hub: PropTypes.object,
    navFn: PropTypes.func,
    handleClick: PropTypes.func
};
