export const gradientGenerator = (colour1, colour2) => {
    if((navigator.userAgent.indexOf('Opera') || navigator.userAgent.indexOf('OPR')) !== -1 ) {
        return {background: '-o-linear-gradient(left, ' + colour1 + ',' + colour2 + ');'};
    } else if(navigator.userAgent.indexOf('Chrome') !== -1 ) {
        return {background: '-webkit-linear-gradient(left, ' + colour1 + ',' + colour2 + ');'};
    } else if(navigator.userAgent.indexOf('Safari') !== -1) {
        return {background: '-webkit-linear-gradient(left, ' + colour1 + ',' + colour2 + ');'};
    } else if(navigator.userAgent.indexOf('Firefox') !== -1 ) {
        return {background: '-moz-linear-gradient(left, ' + colour1 + ',' + colour2 + ');'};
    } else if((navigator.userAgent.indexOf('MSIE') !== -1 ) || (!!document.documentMode === true )) {
        return {filter: 'progid:DXImageTransform.Microsoft.gradient( startColorstr="' + colour1 + '", endColorstr="' + colour2 + '",GradientType=1 );'};
    }

    return {background: '-webkit-linear-gradient(left, ' + colour1 + ',' + colour2 + ');'};
};
