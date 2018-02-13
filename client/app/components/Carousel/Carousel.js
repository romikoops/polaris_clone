import React, {Component} from 'react';
import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import styles from '../ActiveRoutes/ActiveRoutes.scss';
import {v4} from 'node-uuid';
import styled from 'styled-components';

export class Carousel extends Component {
    render() {
        if (!this.props.slides) {
            return '';
        }
        const slideNumber = this.props.noSlides ? this.props.noSlides : 4;
        const settings = {
            dots: true,
            autoplay: true,
            infinite: true,
            slidesToShow: slideNumber,
            speed: 2000,
            arrows: true
        };
        const slideCountStyle = this.props.noSlides === 1 ? styles.one_slide : '';
        const StyledSlider = styled.div`
            .slick_slide {
                width: 1200px !important;
            }
        `;
        const slides = this.props.slides.map((route) => {
            const divStyle = {
                backgroundImage: 'url(' + route.image + ')'
            };
            const slickSlide = (navigator.userAgent.indexOf('MSIE') !== -1 ) || (!!document.documentMode === true )
                ? styles.slick_slide_ie11
                : styles.slick_slide
            ;
            return (
                <div key={v4()} className={`${slickSlide} flex-none layout-row layout-align-center-center`} style={divStyle}>
                    {this.props.fade ? <div className={`flex-none ${styles.fade}`}></div> : ''}
                    <div className={`flex-none layout-column layout-align-center-center ${styles.slick_content}`}>
                        <h2 className={styles.slick_city + ' flex-none'}> {route.header} </h2>
                        <h5 className={styles.slick_country + ' flex-none'}> {route.subheader} </h5>
                    </div>
                </div>
            );
        });
        return (
            <StyledSlider className={`flex-100 layout-row ${styles.slider_container} ${slideCountStyle}`}>
                <Slider {...settings}>
                    {slides}
                </Slider>
            </StyledSlider>
        );
    }
}
