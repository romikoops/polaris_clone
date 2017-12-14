import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './RouteOption.scss';
import { moment } from '../../constants';

export class RouteOption extends Component {
    constructor(props) {
        super(props);
        this.choose = this.choose.bind(this);
    }
    choose() {
        this.props.selectOption(this.props.route);
    }
    faIcon(modeOfTransport) {
        const faKeywords = {
            ocean: 'ship',
            air: 'plane',
            train: 'train'
        };
        const faClass = `fa fa-${faKeywords[modeOfTransport]}`;
        return <i className={faClass} />;
    }
    dashedGradient(color1, color2) {
        return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`;
    }
    render() {
        const { theme, route } = this.props;
        const originNexus       = route.name.split(' - ')[0];
        const destinationNexus  = route.name.split(' - ')[1];
        const modesOfTransport  = Object.keys(route.modes_of_transport).filter(mot => route.modes_of_transport[mot]);
        const nextDeparture     = route.next_departure;
        // const modesOfTransport  = ['ocean', 'air', 'train'];
        // route.dedicated = Math.random() < 0.3;
        const gradientFontStyle = {
            background:
                theme && theme.colors
                    ? `-webkit-linear-gradient(left, ${
                        theme.colors.brightPrimary
                    }, ${theme.colors.brightSecondary})`
                    : 'black'
        };
        const dashedLineStyles = {
            marginTop: '6px',
            height: '2px',
            width: '100%',
            background:
                theme && theme.colors
                    ? this.dashedGradient(
                        theme.colors.primary,
                        theme.colors.secondary
                    )
                    : 'black',
            backgroundSize: '16px 2px, 100% 2px'
        };
        const icons = modesOfTransport.map(mot => this.faIcon(mot));
        const dedicatedDecoratorStyles = {
            borderTop: route.dedicated ? `28px solid ${theme.colors.primary}66` : '',
            borderLeft: '55px solid transparent'
        };
        const dedicatedDecoratorIconStyles = {
            WebkitTextFillColor: 'transparent',
            WebkitTextStroke: '2px white',
        };
        return (
            <div className={styles.route_option} onClick={this.choose} >
                <div
                    className={`flex-100 layout-row layout-align-space-between ${
                        styles.top_row
                    }`}
                >
                    <div className={styles.dedicated_decorator} style={dedicatedDecoratorStyles}>
                        <i className="fa fa-star" style={dedicatedDecoratorIconStyles}></i>
                    </div>
                    <div className={`${styles.header_hub}`}>
                        <i className={`fa fa-map-marker ${styles.map_marker}`} />
                        <div className="flex-100 layout-row">
                            <h4 className="flex-100"> {originNexus} </h4>
                        </div>
                    </div>
                    <div className={`${styles.connection_graphics}`}>
                        <div className="flex-none layout-row layout-align-center-center">
                            {icons}
                        </div>
                        <div style={dashedLineStyles} />
                    </div>
                    <div className={`${styles.header_hub}`}>
                        <i className={`fa fa-flag-o ${styles.flag}`} />
                        <div className="flex-100 layout-row">
                            <h4 className="flex-100"> {destinationNexus} </h4>
                        </div>
                    </div>
                </div>
                <div className="flex-100 layout-row layout-align-start-center">
                    <div className="flex-100 layout-wrap layout-row layout-align-space-between">
                        <div>
                            <h4
                                className={styles.date_title}
                                style={gradientFontStyle}
                            >
                                Next Departure
                            </h4>
                        </div>
                        <div className="layout-row">
                            <p className={styles.sched_elem}>
                                {' '}
                                {moment(nextDeparture).format(
                                    'YYYY-MM-DD'
                                )}{' '}
                            </p>
                            <p className={styles.sched_elem}>
                                {' '}
                                {moment(nextDeparture).format(
                                    'HH:mm'
                                )}{' '}
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
RouteOption.propTypes = {
    theme: PropTypes.object,
    route: PropTypes.object,
    selectOption: PropTypes.func,
    isPrivate: PropTypes.bool
};
