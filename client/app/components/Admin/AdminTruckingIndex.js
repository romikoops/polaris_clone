import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import {AdminRouteTile} from './';
import styles from './Admin.scss';
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
import { AdminSearchableHubs } from './AdminSearchables';
export class AdminTruckingIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    componentDidMount() {
        const { truckingHubs, loading, adminDispatch } = this.props;
        if (!truckingHubs && !loading) {
            adminDispatch.getTrucking(false);
        }
    }
    render() {
        const {theme, viewTrucking, hubs, truckingHubs, adminDispatch} = this.props;
        if (!truckingHubs) {
            return '';
        }

        // const routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={viewTrucking}/>);
        const cityUrl = '/admin/trucking/trucking_city_pricings';
        const zipUrl = '/admin/trucking/trucking_zip_pricings';
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                  <div className="flex-50 layout-row layout-wrap layout-align-start-start">
                    <p className="flex-90">Upload Trucking City Sheet</p>
                    <FileUploader theme={theme} url={cityUrl} type="xlsx" text="Routes .xlsx"/>
                  </div>
                  <div className="flex-50 layout-row layout-wrap layout-align-start-start">
                    <p className="flex-90">Upload Trucking Zip Code Sheet</p>
                    <FileUploader theme={theme} url={zipUrl} type="xlsx" text="Routes .xlsx"/>
                  </div>
                </div>
                <AdminSearchableHubs theme={theme} hubs={hubs} adminDispatch={adminDispatch} sideScroll={false} handleClick={viewTrucking}/>
            </div>
        );
    }
}
AdminTruckingIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    routes: PropTypes.array,
    viewClient: PropTypes.func
};
