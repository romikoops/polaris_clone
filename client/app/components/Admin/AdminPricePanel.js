import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { v4 } from 'node-uuid';
import { pricingNames } from '../../constants/admin.constants';
const pricingNamesHash = pricingNames;
export class AdminPricePanel extends Component {
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
        const { theme, pricing} = this.props;
        if (!pricing) {
            return '';
        }
        const priceTiles = [];
        const sections = {};
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        Object.keys(pricing).forEach(key => {
            if (key !== 'created_at' && key !== 'updated_at' && key !== 'tenant_id' && key !== 'customer_id' && key !== 'route_id' && key !== 'dedicated') {
                if (!sections[key]) {
                    sections[key] = [];
                }
                Object.keys(pricing[key]).forEach(ky2 => {
                    if (ky2 !== 'currency') {
                        sections[key].push(
                            <div key={v4()} className="flex-100 layout-row">
                                <div className="flex-50 layout-align-start-center layout-row">
                                    <p className="flex-none">{pricingNamesHash[ky2]}</p>
                                </div>
                                <div className="flex-50 layout-align-start-center layout-row">
                                    <p className="flex-none">{pricing[key].currency} {pricing[key][ky2]}</p>
                                </div>
                            </div>
                        );
                    }
                });
            }
        });

        const PriceSection = ({pkey}) => {
            return (<div key={v4()} className={`flex-none layout-row layout-wrap ${styles.price_card}`}>
                <div className="flex-100 layout-row layout-align-start-center">
                    <p className={`flex-none ${styles.title}`} style={textStyle}> {pricingNamesHash[pkey]}</p>
                </div>
                <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                    {sections[pkey]}
                </div>
            </div>);
        };
        Object.keys(pricing).forEach(key => {
            priceTiles.push(<PriceSection  pkey={key} />);
        });
        return (
            <div key={v4()} className={`flex-100 layout-row layout-wrap ${styles.price_panel}`}>
                <div className="flex-100 layout-row layout-align-start-center">
                    <p className="flex-none">{pricing.customer_id ? 'Dedicated Pricing' : 'Open Pricing'}</p>
                </div>
                <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                    {priceTiles}
                </div>
            </div>
        );
    }
}
AdminPricePanel.propTypes = {
    theme: PropTypes.object,
    hub: PropTypes.object,
    pricing: PropTypes.object,
    navFn: PropTypes.func
};
