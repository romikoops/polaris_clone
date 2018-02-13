import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { AdminScheduleLine, AdminHubTile } from './';
import styles from './Admin.scss';
import {v4} from 'node-uuid';
import {gradientTextGenerator} from '../../helpers';
export class AdminRouteView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            scheduleLimit: 20
        };
    }
    render() {
        const {theme, itineraryData, hubHash, adminActions} = this.props;
        // ;s
        if (!itineraryData) {
            return '';
        }
        const { itinerary, hubs, schedules} = itineraryData;
        const textStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};

        const hubArr = hubs.map((hubObj) => {
            return (<AdminHubTile key={v4()} hub={hubHash[hubObj.id]} theme={theme} handleClick={() => adminActions.getHub(hubObj.id, true)} />);
        });

        const schedArr = schedules.map((sched, i) => {
            if (i <= this.state.scheduleLimit) {
                return <AdminScheduleLine key={v4()} schedule={sched} hubs={hubHash} theme={theme}/>;
            }
            return '';
        });

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>{itinerary.name}</p>
                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Route Stops</p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                        {hubArr}
                    </div>

                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Schedules </p>
                    </div>
                    {schedArr}
                </div>
            </div>
        );
    }
}
AdminRouteView.propTypes = {
    theme: PropTypes.object,
    hubHash: PropTypes.object,
    hubs: PropTypes.array,
    clientData: PropTypes.array,
    adminActions: PropTypes.object
};
