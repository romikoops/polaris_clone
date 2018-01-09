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
import defs from '../../styles/default_classes.scss';
const containerDescriptions = CONTAINER_DESCRIPTIONS;
export class HSCodeRow extends Component {
    constructor(props) {
        super(props);
        this.state = {
            hsCodes: {}
        };
        this.setHsCode = this.setHsCode.bind(this);
    }
    setHsCode(id, codes) {
        let exCodes;
        if (this.state.hsCodes[id]) {
            exCodes = [...this.state.hsCodes[id], ...codes];
        } else {
            exCodes = codes;
        }
        this.setState({
            hsCodes: {
                ...this.state.hsCodes,
                [id]: exCodes
            }
        });
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

    render() {
        const { containers, cargoItems, hsCodes, theme } = this.props;
        // const { hsCodes } = this.state;
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

        if (containers) {
            containers.forEach((cont, i) => {
                if (i !== 0) {
                    const tmpCont = (
                        <div className={`flex-100 layout-row layout-wrap ${styles.container_row}`}>
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
                            <div className="flex-100 layout-row layout-align-start-center">
                                <NamedAsync
                                    classes="flex-50"
                                    multi
                                    name={cont.id}
                                    value={hsCodes[cont.id] ? hsCodes[cont.id] : ''}
                                    autoload={false}
                                    loadOptions={getOptions}
                                    onChange={this.props.setCode}
                                />
                                 <div className="flex-50 layout-row layout-wrap">
                                    {hsCodes[cont.id] ? hsCodes[cont.id].map((hs) => {return <HSCell code={hs} cargoId={cont.id} />;}) : ''}
                                </div>
                            </div>
                        </div>
                    );
                    containersAdded.push(tmpCont);
                }
            });
        }
        if (cargoItems) {
            cargoItems.forEach((cont, i) => {
                console.log(hsCodes[cont.id]);
                const tmpCont = (
                    <div key={i} className={`flex-100 layout-row layout-wrap ${styles.container_row}`}>
                        <div className="flex-10 layout-row layout-align-center-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Unit</p>
                            <p className="flex-100">{i}</p>
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
                        <div className="flex-20 layout-row layout-align-center-center layout-wrap">
                            <p className={`flex-100 ${styles.cell_header}`}>Dangerous Goods:{' '}</p>
                            <p className="flex-100">{cont.dangerousGoods ? 'Yes' : 'No'}</p>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <NamedAsync
                                classes="flex-50"
                                multi
                                name={cont.id}
                                value={hsCodes[cont.id] ? hsCodes[cont.id] : ''}
                                autoload={false}
                                loadOptions={getOptions}
                                onChange={this.props.setCode}
                            />
                            <div className="flex-50 layout-row layout-wrap">
                                {hsCodes[cont.id] ? hsCodes[cont.id].map((hs) => {return <HSCell code={hs} cargoId={cont.id} />;}) : ''}
                            </div>
                        </div>
                    </div>
                );
                cargoItemsAdded.push(tmpCont);
            });
        }

        return (
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
                <div className={`layout-row flex-none ${defs.content_width} layout-wrap layout-align-start-center`} >
                    <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                        <div className="layout-row flex-100 layout-wrap">
                            <h4 className="flex-none clip" style={textStyle}> HS Codes</h4>
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
