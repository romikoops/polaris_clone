import React, {Component} from 'react';
import styles from './ShopStageView.scss';
import PropTypes from 'prop-types';
// import SignIn from '../SignIn/SignIn';  default ShopStageView;
export class ShopStageView extends Component {
    constructor(props) {
        super(props);
        this.state = {
            stages: props.stages,
            currentStage: props.currentStage
        };
    }
    componentDidMount() {
        this.stageName(this.props.currentStage);
    }
    stageFunction(stage) {
        const colour = this.props.theme ? this.props.theme.colors.primary : 'white';
        const borderColour = this.props.theme ? this.props.theme.colors.primary : 'black';
        const textStyle = { color: colour};
        const borderStyle = { borderColor: borderColour};
        let stageBox;
        if (stage.step < this.props.currentStage) {
            stageBox = (
                <div className={`${styles.shop_stage_past} flex-none layout-column layout-align-center-center`} >
                    <i className="fa fa-check flex-none" style={textStyle}></i>
                </div>
            );
        } else if (stage.step === this.props.currentStage) {
            stageBox = (
                <div className={`${styles.shop_stage_current} flex-none layout-column layout-align-center-center`} style={borderStyle}>
                  <h3 className="flex-none" style={textStyle}> { stage.step } </h3>
                </div>
            );
        } else {
            stageBox = (
                <div className={`${styles.shop_stage_yet} layout-column layout-align-center-center`} >
                  <h3 className="flex-none" > { stage.step } </h3>
                </div>
            );
        }
        return stageBox;
    }

    stageName(cStage) {
        this.props.stages.forEach(stage => {
            if (stage.step === cStage) {
                this.setState({title: stage.header});
            }
        });
    }
    render() {
        const stageBoxes = [];
        this.props.stages.map(stage => {
            stageBoxes.push(
                <div key={stage.step} className={`${styles.stage_box} flex-none layout-column layout-align-start-center`}>
                    { this.stageFunction(stage) }
                    <p className={`flex-none ${styles.stage_text}`}>{stage.text}</p>
                </div>
            );
        });
        return (
            <div className="layout-row flex-100 layout-align-center layout-wrap">
                <div className={`${styles.shop_banner} layout-row flex-100 layout-align-center`}>
                    <div className="layout-row content-width layout-wrap layout-align-start-center">
                        <h3 className="flex-none header"> {this.props.shopType } </h3>
                        <i className="fa fa-chevron-right fade"></i>
                        <p className="flex-none fade"> {this.state.title} </p>
                    </div>
                </div>
                <div className={`${styles.stage_row} layout-row flex-100 layout-align-center`}>
                    <div className="flex-none content-width layout-row layout-align-start-center">
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
