import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { v4 } from 'node-uuid';
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
        const { theme, hub, pricing} = this.props;
        if (!hub || !pricing) {
            debugger;
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
        const panelStyle = expanded ? {height: '150px', opacity: '1'} : {height: '0px', opacity: '0'};
        // const ChargeSection = ({tag, value, currency}) => {
        //     return (<div className={`flex-30 layout-row layout-align-space-between-center ${styles.charge_opt}`}>
        //                     <p className="flex-none"> {serviceChargeNames[tag]}</p>
        //                     <p className="flex-none"> {value} {currency}</p>
        //                 </div>);
        // };
        const expandIcon = expanded ? <i className="flex-none fa fa-chevron-up" style={gradientStyle}/> : <i className="flex-none fa fa-chevron-down" style={gradientStyle}/>;
        // debugger;
        return(
            <div className={`flex-100 ${styles.charge_card} layout-row layout-wrap`} style={bg1}>

                
            </div>
        );
    }
}
AdminChargePanel.propTypes = {
    theme: PropTypes.object,
    hub: PropTypes.object,
    pricing: PropTypes.object,
    navFn: PropTypes.func
};
