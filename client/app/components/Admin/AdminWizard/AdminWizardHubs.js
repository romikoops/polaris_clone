import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin.scss';
import { AdminHubTile } from '../';
import { history } from '../../../helpers';
import { RoundButton } from '../../RoundButton/RoundButton';
import {v4} from 'node-uuid';
import FileUploader from '../../../components/FileUploader/FileUploader';
export class AdminWizardHubs extends Component {
    constructor(props) {
        super(props);
        this.state = {
            stage: 1
        };
        this.nextStep = this.nextStep.bind(this);
        this.back = this.back.bind(this);
    }
    nextStep() {
        this.props.adminTools.goTo('/admin/wizard/service_charges');
    }
    back() {
        history.goBack();
    }
    render() {
        const {theme, newHubs, adminTools} = this.props;
        let hubList;
        if (newHubs && newHubs.length > 0) {
            hubList = newHubs.map((hub) =>
                <AdminHubTile key={v4()} hub={hub} theme={theme} handleClick={() => adminTools.getHub(hub.id, true)}/>
            );
        } else {
            hubList = [];
        }
        const hubUrl = '/admin/hubs/process_csv';
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const backButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    text="Back"
                    handleNext={this.back}
                    iconClass="fa-chevron-left"
                />
            </div>);
        const nextButton = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    size="small"
                    active
                    text="Next"
                    handleNext={this.nextStep}
                    iconClass="fa-chevron-right"
                />
            </div>);

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                    <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                        <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>hubs</p>
                    </div>
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                        <p className="flex-none">Upload Hubs Sheet</p>
                        <FileUploader theme={theme} url={hubUrl} dispatchFn={adminTools.wizardHubs} type="xlsx" text="Hub .xlsx"/>
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        {hubList}
                    </div>
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    {backButton}
                    {nextButton}
                    </div>
                </div>
            </div>
        );
    }
}
AdminWizardHubs.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};
