import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { serviceChargeNames } from '../../constants/admin.constants';
export class AdminChargePanel extends Component {
    constructor(props) {
        super(props);
        this.handleLink = this.handleLink.bind(this);
        this.state = {
            expanded: false
        };
        this.toggleExpand = this.toggleExpand.bind(this);
    }
    handleLink() {
        const {target, navFn} = this.props;
        console.log('NAV ' + target);
        navFn(target);
    }
    toggleExpand() {
        this.setState({expanded: !this.state.expanded});
    }
    render() {
        const { expanded } = this.state;
        const { theme, hub, charge} = this.props;
        if (!hub || !charge) {
            return '';
        }
        const bg1 = { backgroundImage: 'url(' + hub.location.photo + ')' };
        const gradientStyle = {
            background:
                theme && theme.colors
                    ? `-webkit-linear-gradient(left, ${theme.colors.primary}, ${
                        theme.colors.secondary
                    })`
                    : 'black'
        };
        const panelStyle = expanded ? {height: '150px'} : {height: '0px'};
        const exportArr = [];
        const importArr = [];
        const ChargeSection = ({key, value, currency}) => {
            <div className="flex-33 layout-row layout-align-space-between-center">
                <p className="flex-none"> {serviceChargeNames[key]}</p>
                <p className="flex-none"> {value} {currency}</p>
            </div>;
        };
        Object.keys(charge).forEach(key => {
            if (charge[key].trade_direction === 'import') {
                importArr.push(<ChargeSection key={key} value={charge[key].value} currency={charge[key].currency}/>);
            } else if (charge[key].trade_direction === 'export') {
                exportArr.push(<ChargeSection key={key} value={charge[key].value} currency={charge[key].currency}/>);
            }
        });
        const expandIcon = expanded ? <i className="flex-none fa fa-chevron-up" style={gradientStyle}/> : <i className="flex-none fa fa-chevron-down" style={gradientStyle}/>;
        return(
            <div className={`flex-none ${styles.charge_card} layout-row`} style={bg1}>

                <div className={`${styles.charge_header} layout-row`}>
                    <div className={styles.fade}></div>
                    <div className="flex-10 layout-column layout-align-start-center">
                        <i className="flex-none fa fa-map-marker" style={gradientStyle}/>
                    </div>
                    <div className="flex-80 layout-row layout-wrap layout-align-start-start">
                        <h6 className="flex-100"> {hub.data.name} </h6>
                    </div>
                    <div className="flex-10 layout-column layout-align-start-center" onClick={this.toggleExpand}>
                        {expandIcon}
                    </div>
                </div>
                <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.charge_panel}`} style={panelStyle}>
                    <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.charge_panel_xxport}`}>
                        <div className="flex-100 layout-row layout-align-start-start">
                            <p className="flex-none">Import</p>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                            {importArr}
                        </div>
                    </div>
                    <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.charge_panel_xxport}`}>
                        <div className="flex-100 layout-row layout-align-start-start">
                            <p className="flex-none">Export</p>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
                            {exportArr}
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
AdminChargePanel.propTypes = {
    theme: PropTypes.object,
    hub: PropTypes.object,
    charge: PropTypes.object,
    navFn: PropTypes.func
};
