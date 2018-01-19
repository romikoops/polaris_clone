import React, { Component } from 'react';

export class ShipmentSummaryBox extends Component {
    constructor(props) {
        super(props);
        this.state = {
            working: true
        };
        this.onChangeFunc = this.onChangeFunc.bind(this);
    }
    onChangeFunc(optionsSelected) {
        const nameKey = this.props.name;
        this.props.onChange(nameKey, optionsSelected);
    }

    render() {
        const { theme, shipment } = this.props;
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

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className="flex-100 layout-row layout-wrap">
                    <div
                        className={`flex-100 layout-row layout-align-start-center ${
                            styles.top_row
                        }`}
                    >
                        <div
                            className={`flex-80 layout-row layout-align-start-center ${
                                styles.hubs_row
                            }`}
                        >
                            <div className={`${styles.header_hub}`}>
                                <i
                                    className={`fa fa-map-marker ${
                                        styles.map_marker
                                    }`}
                                />
                                <div className="flex-100 layout-row">
                                    <h4 className="flex-100"> {originHub.name} </h4>
                                </div>
                                {originHub.hub_code ?
                                    <div className="flex-100">
                                        <p className="flex-100">
                                            {' '}
                                             {originHub.hub_code}
                                        </p>
                                    </div> :
                                    '' }
                            </div>
                            <div className={`${styles.connection_graphics}`}>
                                <div className="flex-none layout-row layout-align-center-center">
                                    {this.switchIcon(schedule)}
                                </div>
                                <div style={dashedLineStyles} />
                            </div>
                            <div className={`${styles.header_hub}`}>
                                <i className={`fa fa-flag-o ${styles.flag}`} />
                                <div className="flex-100 layout-row">
                                    <h4 className="flex-100"> {destHub.name} </h4>
                                </div>
                                <div className="flex-100">
                                    <p className="flex-100">
                                        {' '}
                                        {destHub.hub_code
                                            ? destHub.hub_code
                                            : ''}{' '}
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div
                            className={`flex-20 layout-row layout-align-start-center ${
                                styles.load_type
                            }`}
                        >
                            {/* <p className="flex-none no_m">{loadType}</p>*/}
                            <p className="flex-none no_m">{schedule.id}</p>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center">
                        <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                            <div className="flex-100 layout-row">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    Pickup Date
                                </h4>
                            </div>
                            <div className="flex-100 layout-row">
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(this.props.pickupDate).format(
                                        'YYYY-MM-DD'
                                    )}{' '}
                                </p>
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(this.props.pickupDate).format(
                                        'HH:mm'
                                    )}{' '}
                                </p>
                            </div>
                        </div>
                        <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                            <div className="flex-100 layout-row">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    {' '}
                                    Date of Departure
                                </h4>
                            </div>
                            <div className="flex-100 layout-row">
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(schedule.etd).format(
                                        'YYYY-MM-DD'
                                    )}{' '}
                                </p>
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(schedule.etd).format('HH:mm')}{' '}
                                </p>
                            </div>
                        </div>
                        <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                            <div className="flex-100 layout-row">
                                <h4
                                    className={styles.date_title}
                                    style={gradientFontStyle}
                                >
                                    {' '}
                                    ETA terminal
                                </h4>
                            </div>
                            <div className="flex-100 layout-row">
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(schedule.eta).format(
                                        'YYYY-MM-DD'
                                    )}{' '}
                                </p>
                                <p className={`flex-none ${styles.sched_elem}`}>
                                    {' '}
                                    {moment(schedule.eta).format('HH:mm')}{' '}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}
