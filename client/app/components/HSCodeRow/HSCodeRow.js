import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { NamedAsync } from '../NamedSelect/NamedAsync';
import { authHeader } from '../../helpers';
import styles from './HSCodeRow.scss';
import {
    CONTAINER_DESCRIPTIONS,
    // CONTAINER_TARE_WEIGHTS,
    BASE_URL
} from '../../constants';
import { Tooltip } from '../Tooltip/Tooltip';
import { BookingTextHeading } from '../TextHeadings/BookingTextHeading';
// import defs from '../../styles/default_classes.scss';
const containerDescriptions = CONTAINER_DESCRIPTIONS;
export class HSCodeRow extends Component {
    constructor(props) {
        super(props);
        this.state = {
            hsCodes: {},
            clipboard: {}
        };
        this.copyCodes = this.copyCodes.bind(this);
        this.pasteCodes = this.pasteCodes.bind(this);
        this.deleteCode = this.deleteCode.bind(this);
        this.reduceCargos = this.reduceCargos.bind(this);
    }

    copyCodes(cgId) {
        this.setState({clipboard: this.props.hsCodes[cgId], showPaste: true});
        console.log(this.state.hsCodes[cgId]);
    }
    pasteCodes(cgId) {
        this.props.setCode(cgId, this.state.clipboard);
    }
    deleteCode(cargoId, code) {
        const codes = this.state.hsCodes[cargoId];
        const newCodes = codes.filter((x) => {x !== code;});
        this.setState({
            hsCodes: {
                ...this.state.hsCodes,
                [cargoId]: newCodes
            }
        });
    }
    reduceCargos(arr) {
        const results = [];
        const uuids = {};
        arr.forEach((c) => {
            if (!uuids[c.cargo_group_id]) {
                uuids[c.cargo_group_id] = true;
                results.push(c);
            }
        });
        return results;
    }

    render() {
        const { containers, cargoItems, hsCodes, theme } = this.props;
        const { showPaste } = this.state;
        const containersAdded = [];
        const cargoItemsAdded = [];
        const getOptions = (input) => {
            console.log(input);
            const formData = new FormData();
            formData.append('query', input);
            const requestOptions = {
                method: 'POST',
                headers: { ...authHeader()},
                body: formData
            };
            return fetch(`${BASE_URL}/search/hscodes`, requestOptions)
                .then((response) => {
                    return response.json();
                }).then((json) => {
                    return { options: json.data };
                });
            // }
            // return [];
        };
        const HSCell = ({code, cargoId}) => {
            return (<div className={`flex-33 layout-row ${styles.hs_cell}`}>
                <p className="flex-none">{code.value}</p>
                <div className="flex-15 layout-row layout-align-center-center">
                    <i className="fa fa-trash" onClick={() => this.props.deleteCode(cargoId, code)}></i>
                </div>
            </div>);
        };
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const reducedContainers = containers ? this.reduceCargos(containers) : [];
        const reducedCargoItems = cargoItems ? this.reduceCargos(cargoItems) : [];
        if (reducedContainers) {
            reducedContainers.forEach((cont, i) => {
                const tmpCont = (
                    <div className={`flex-100 layout-row layout-wrap ${styles.container_row}`} style={{zIndex: `${200 - i}`}}>
                        <div className="flex-15 layout-row layout-align-start-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}> Container Size</p>
                            <p className="flex-100">{containerDescriptions[cont.size_class]}</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-start-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Net Weight</p>
                            <p className="flex-100">{cont.payload_in_kg} kg</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-start-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}> Gross Weight</p>
                            <p className="flex-100">{parseInt(cont.payload_in_kg, 10) + parseInt(cont.tare_weight, 10)}{' '} kg</p>

                        </div>
                        <div className="flex-10 layout-row layout-align-start-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Dangerous Goods:{' '}</p>

                            <p className="flex-100">{cont.dangerousGoods ? 'Yes' : 'No'}</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-start-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Copy/Paste:{' '}</p>

                            <div className="flex-100 layout-row" style={{margin: '1em 0'}}>
                                <div className="flex-50 layout-row layout-align-center-center" onClick={() => this.copyCodes(cont.cargo_group_id)}>
                                    <i className="fa fa-clone clip" style={textStyle}></i>
                                </div>
                                {showPaste ?
                                    <div className="flex-50 layout-row layout-align-center-center" onClick={() => this.pasteCodes(cont.cargo_group_id)}>
                                        <i className="fa fa-clipboard clip" style={textStyle}></i>
                                    </div> :
                                    '' }
                            </div>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <NamedAsync
                                classes="flex-50"
                                multi
                                name={cont.cargo_group_id}
                                value={''}
                                autoload={false}
                                loadOptions={getOptions}
                                onChange={this.props.setCode}
                            />
                            <div className="flex-50 layout-row layout-wrap">
                                {hsCodes[cont.cargo_group_id] ? hsCodes[cont.cargo_group_id].map((hs) => {return <HSCell code={hs} cargoId={cont.cargo_group_id} />;}) : ''}
                            </div>
                        </div>
                    </div>
                );
                containersAdded.push(tmpCont);
            });
        }
        if (reducedCargoItems) {
            reducedCargoItems.forEach((cont, i) => {
                const tmpCont = (
                    <div key={i} className={`flex-100 layout-row layout-wrap ${styles.container_row}`} style={{zIndex: `${200 - i}`}}>
                        <div className="flex-10 layout-row layout-align-center-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Cargo Group</p>
                            <p className="flex-100">{i + 1}</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-center-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Payload</p>
                            <p className="flex-100">{cont.payload_in_kg} kg</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-center-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Depth</p>
                            <p className="flex-100">{cont.dimension_y} cm</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-center-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Width</p>
                            <p className="flex-100">{cont.dimension_x} cm</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-center-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Height</p>
                            <p className="flex-100">{cont.dimension_z} cm</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-center-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Dangerous Goods:{' '}</p>
                            <p className="flex-100">{cont.dangerousGoods ? 'Yes' : 'No'}</p>
                        </div>
                        <div className="flex-15 layout-row layout-align-start-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Copy/Paste:{' '}</p>

                            <div className="flex-100 layout-row" style={{margin: '1em 0'}}>
                                <div className="flex-50 layout-row layout-align-center-center" onClick={() => this.copyCodes(cont.cargo_group_id)}>
                                    <i className="fa fa-clone clip" style={textStyle}></i>
                                </div>

                                <div className="flex-50 layout-row layout-align-center-center" onClick={() => this.pasteCodes(cont.cargo_group_id)}>
                                    <i className="fa fa-clipboard clip" style={textStyle}></i>
                                </div>
                            </div>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <NamedAsync
                                classes="flex-50"
                                multi
                                name={cont.cargo_group_id}
                                value={''}
                                autoload={false}
                                loadOptions={getOptions}
                                onChange={this.props.setCode}
                            />
                            <div className="flex-50 layout-row layout-wrap">
                                {hsCodes[cont.cargo_group_id] ? hsCodes[cont.cargo_group_id].map((hs) => {return <HSCell code={hs} cargoId={cont.cargo_group_id} />;}) : ''}
                            </div>
                        </div>
                    </div>
                );
                cargoItemsAdded.push(tmpCont);
            });
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                <div className={'layout-row flex-90 layout-wrap layout-align-start-center'} >
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className="layout-row flex-100 layout-align-start-center">
                            <p className="flex-none">
                                <BookingTextHeading theme={theme} size={2} text="HS Codes" />
                            </p>
                            <Tooltip theme={theme} icon="fa-info-circle" text="hs_code" />
                        </div>
                        <div className="layout-row flex-100 layout-wrap">
                            {containersAdded}
                            {cargoItemsAdded}
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

HSCodeRow.propTypes = {
    theme: PropTypes.object,
    addContainer: PropTypes.func,
    containers: PropTypes.array,
    cargoItems: PropTypes.array,
    deleteCargo: PropTypes.func
};
