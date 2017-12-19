import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin.scss';
// import { AdminHubTile } from '../';
import { RoundButton } from '../../RoundButton/RoundButton';
// import {v4} from 'node-uuid';
import Select from 'react-select';
import '../../../styles/select-css-custom.css';
import styled from 'styled-components';
import FileUploader from '../../../components/FileUploader/FileUploader';
export class AdminWizardTrucking extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selType: {label: 'Sweden', value: 'zipcode'}
        };
        this.nextStep = this.nextStep.bind(this);
        this.back = this.back.bind(this);
        this.setTruckingType = this.setTruckingType.bind(this);
        this.uploadTrucking = this.uploadTrucking.bind(this);
    }
    nextStep() {
        this.props.adminTools.goTo('/admin/wizard/finished');
    }
    back() {
        history.goBack();
    }
    setTruckingType(type) {
      this.setState({selType: type});
    }
    uploadTrucking(file) {
      this.props.adminTools.wizardTrucking(this.state.selType.value, file);
    }

    render() {
        const {theme, newScs} = this.props;
        const cities = [
          {label: 'Sweden', value: 'zipcode'},
          {label: 'China', value: 'city'}
        ];
        const StyledSelect = styled(Select)`
            .Select-control {
                background-color: #F9F9F9;
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2 !important;
            }
            .Select-menu-outer {
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2;
            }
            .Select-value {
                background-color: #F9F9F9;
                border: 1px solid #F2F2F2;
            }
            .Select-option {
                background-color: #F9F9F9;
            }
        `;
        console.log(newScs);
        const scUrl = '/admin/hubs/process_csv';
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
                        <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>Trucking</p>
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center">
                        <StyledSelect
                            name="sort-filter"
                            className={`${styles.select}`}
                            value={this.state.selType}
                            options={cities}
                            onChange={this.setTruckingType}
                        />
                    </div>
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                        <p className="flex-none">Upload Trucking Sheet</p>
                        <FileUploader theme={theme} url={scUrl} dispatchFn={this.uploadTrucking} type="xlsx" />
                    </div>
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        {/* {hubList}*/}
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
AdminWizardTrucking.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};
