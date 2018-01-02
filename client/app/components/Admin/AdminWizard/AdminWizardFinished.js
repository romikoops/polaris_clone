import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin.scss';
// import { AdminHubTile } from '../';
// import { RoundButton } from '../../RoundButton/RoundButton';
// import {v4} from 'node-uuid';
// import Select from 'react-select';
// import '../../../styles/select-css-custom.css';
// import styled from 'styled-components';
// import FileUploader from '../../../components/FileUploader/FileUploader';
export class AdminWizardFinished extends Component {
    constructor(props) {
        super(props);
        this.nextStep = this.nextStep.bind(this);
        this.back = this.back.bind(this);
    }
    nextStep() {
        this.props.adminTools.goTo('/admin/wizard/finished');
    }
    back() {
        history.goBack();
    }


    render() {
        const {theme, newScs} = this.props;
        console.log(newScs);
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        // const backButton = (
        //     <div className="flex-none layout-row">
        //         <RoundButton
        //             theme={theme}
        //             size="small"
        //             text="Back"
        //             handleNext={this.back}
        //             iconClass="fa-chevron-left"
        //         />
        //     </div>);
        // const nextButton = (
        //     <div className="flex-none layout-row">
        //         <RoundButton
        //             theme={theme}
        //             size="small"
        //             active
        //             text="Next"
        //             handleNext={this.nextStep}
        //             iconClass="fa-chevron-right"
        //         />
        //     </div>);

        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                    <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                        <h1 className={` ${styles.sec_title_text} flex-none`} style={textStyle}>Finished!</h1>
                    </div>

                    <div className={`flex-100 layout-row layout-align-start-center ${styles.sec_title}`}>
                        <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>Browse through the links on the left to see your data!</p>
                    </div>

                    {/* <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                        {backButton}
                        {nextButton}
                    </div> */}
                </div>
            </div>
        );
    }
}
AdminWizardFinished.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array
};
