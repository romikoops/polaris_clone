import React, { Component } from 'react';
import styles from './ShopStageView.scss';
import PropTypes from 'prop-types';
import defs from '../../styles/default_classes.scss';
import { SHIPMENT_STAGES } from '../../constants';
import { gradientCSSGenerator, gradientTextGenerator } from '../../helpers';
import styled from 'styled-components';
export class ShopStageView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            stages: SHIPMENT_STAGES,
            currentStage: props.currentStage
        };
    }
    componentDidMount() {
        this.stageName(this.props.currentStage);
    }
    stageFunction(stage) {
        const { theme } = this.props;
        const gradientStyle = theme ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : theme.colors.brightPrimary;
        // const borderStyle = {
        //     borderColor: theme ? gradientGenerator(theme.colors.primary, theme.colors.secondary) : theme.colors.brightPrimary
        // };
        const activeBtnStyle = theme && theme.colors ? gradientCSSGenerator(theme.colors.primary, theme.colors.secondary) : theme.colors.primary;
        console.log(activeBtnStyle);
        const StyledCircle = styled.div`
            background: ${activeBtnStyle};
           color: ${theme.colors.primary};
           
        `;
        let stageBox;
        if (stage.step < this.props.currentStage) {
            stageBox = (
                <div
                    className={`${
                        styles.shop_stage_past
                    } flex-none layout-column layout-align-center-center`}
                    onClick={() => this.props.setStage(stage)}
                >
                    <i className="fa fa-check flex-none clip" style={gradientStyle} />
                </div>
            );
        } else if (stage.step === this.props.currentStage) {
            stageBox = (
                <div className={styles.wrapper_shop_stage_current} >
                    <div
                        className={`${
                            styles.shop_stage_current
                        } flex-none layout-column layout-align-center-center`}
                    >
                        <h3 className="flex-none" style={gradientStyle}>
                            {' '}
                            {stage.step}{' '}
                        </h3>
                    </div>
                    <StyledCircle className={styles.shop_stage_current_border} />
                </div>
            );
        } else {
            stageBox = (
                <div
                    className={`${
                        styles.shop_stage_yet
                    } layout-column layout-align-center-center`}
                >
                    <h3 className="flex-none"> {stage.step} </h3>
                </div>
            );
        }
        return stageBox;
    }

    stageName(cStage) {
        SHIPMENT_STAGES.forEach(stage => {
            if (stage.step === cStage) {
                this.setState({ title: stage.header });
            }
        });
    }
    render() {
        const stageBoxes = [];
        SHIPMENT_STAGES.map(stage => {
            stageBoxes.push(
                <div
                    key={stage.step}
                    className={`${
                        styles.stage_box
                    } flex-none layout-column layout-align-start-center`}
                >
                    {this.stageFunction(stage)}
                    <p className={`flex-none ${styles.stage_text}`}>
                        {stage.text}
                    </p>
                </div>
            );
        });
        return (
            <div className={`layout-row flex-100 layout-align-center layout-wrap ${styles.ss_view}`}>
                <div className={`${styles.shop_banner} layout-row flex-100 layout-align-center`}>
                    <div className={styles.fade}></div>
                    <div className={`layout-row ${defs.content_width} layout-wrap layout-align-start-center ${styles.banner_content}`}>
                        <h3 className="flex-none header"> {this.props.shopType } </h3>
                        <i className="fa fa-chevron-right fade"></i>
                        <p className="flex-none fade"> {this.state.title} </p>
                    </div>
                </div>
                <div className={`${styles.stage_row} layout-row flex-100 layout-align-center`}>
                    <div className={`layout-row ${defs.content_width} layout-align-start-center`}>
                        <div className={` ${styles.line_box} layout-row layout-wrap layout-align-center flex-none`}>
                            <div className={` ${styles.line} flex-none`}></div>
                            { stageBoxes }
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

ShopStageView.propTypes = {
    theme: PropTypes.object,
    stages: PropTypes.array,
    setStage: PropTypes.func,
    currentStage: PropTypes.number,
    shopType: PropTypes.string,
    match: PropTypes.object
};

ShopStageView.defaultProps = {
    currentStage: 1
};
