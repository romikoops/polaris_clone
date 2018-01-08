import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { Redirect } from 'react-router';
// import { AdminClientTile } from './';
import { history } from '../../helpers';
// import { pricingNames } from '../../constants/admin.constants';
import { AdminSearchableClients } from './AdminSearchables';
// import {v4} from 'node-uuid';
import { RoundButton } from '../RoundButton/RoundButton';

export class AdminPricingsClientIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedPricing: null,
            currentView: 'open',
            redirect: false
        };
        this.backToIndex = this.backToIndex.bind(this);
        this.viewClient = this.viewClient.bind(this);
    }

    backToIndex() {
       history.goBack();
    }

    viewClient(client) {
        const {adminTools} = this.props;
        adminTools.getClientPricings(client.id, true);
    }

    render() {
        const {theme, clients, adminTools } = this.props;
        // const { selectedPricing } = this.state;
        if (!clients) {
            return '';
        }
        if (this.state.redirect) {
            return <Redirect push to="/admin/pricings" />;
        }
        const backButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    text="Back"
                    handleNext={this.backToIndex}
                    iconClass="fa-chevron-left"
                />
            </div>
        );
        // let clientsArr;
        // if (clients) {
        //     clientsArr = clients.map((c) => <AdminClientTile key={v4()} client={c} theme={theme} handleClick={() => this.viewClient(c)}/>);
        // }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>pricings</p>
                    {backButton}
                </div>
                <AdminSearchableClients theme={theme} clients={clients} handleClick={this.viewClient} seeAll={() => adminTools.goTo('/admin/pricings/clients')}/>
               {/* <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className="layout-row flex-100 layout-align-start-center">
                        {clientsArr}
                    </div>
                </div>*/}
            </div>
        );
    }
}
AdminPricingsClientIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricings: PropTypes.array
};
