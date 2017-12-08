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
        const { theme, isPrivate, route } = this.props;
        console.log(isPrivate);
        const originNexus      = route.route.name.split(' - ')[0];
        const destinationNexus = route.route.name.split(' - ')[1];
        const modeOfTransport  = route.next.mode_of_transport;
        // console.log(route);
        // console.log(originNexus);
        // console.log(destinationNexus);

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


        return (
            <div className={styles.route_option} onClick={this.choose} >
                <div
                    className={`flex-100 layout-row layout-align-space-between ${
                        styles.top_row
                    }`}
                >
                    <div className={`${styles.header_hub}`}>
                        <i className={`fa fa-map-marker ${styles.map_marker}`} />
                        <div className="flex-100 layout-row">
                            <h4 className="flex-100"> {originNexus} </h4>
                        </div>
                        <div className="flex-100">
                            <p className="flex-100">
                                CODE
                            </p>
                        </div>
                    </div>
                    <div className={`${styles.connection_graphics}`}>
                        <div className="flex-none layout-row layout-align-center-center">
                            {this.faIcon(modeOfTransport)}
                        </div>
                        <div style={dashedLineStyles} />
                    </div>
                    <div className={`${styles.header_hub}`}>
                        <i className={`fa fa-flag-o ${styles.flag}`} />
                        <div className="flex-100 layout-row">
                            <h4 className="flex-100"> {destinationNexus} </h4>
                        </div>
                        <div className="flex-100">
                            <p className="flex-100">
                                CODE
                            </p>
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
                                {moment(this.props.pickupDate).format(
                                    'YYYY-MM-DD'
                                )}{' '}
                            </p>
                            <p className={styles.sched_elem}>
                                {' '}
                                {moment(this.props.pickupDate).format(
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
