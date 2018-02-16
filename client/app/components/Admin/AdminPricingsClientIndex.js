import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { Redirect } from 'react-router';
import { history } from '../../helpers';
import { AdminSearchableClients } from './AdminSearchables';
import { RoundButton } from '../RoundButton/RoundButton';
import {gradientTextGenerator} from '../../helpers';
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

        const textStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>pricings</p>
                    {backButton}
                </div>
                <AdminSearchableClients theme={theme} clients={clients} handleClick={this.viewClient} seeAll={() => adminTools.goTo('/admin/pricings/clients')}/>

            </div>
        );
    }
}
AdminPricingsClientIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    pricings: PropTypes.array
};
