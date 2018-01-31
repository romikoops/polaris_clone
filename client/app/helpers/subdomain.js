export const getSubdomain = () => {
    const host = window.location.host;
    if (host.indexOf('.') < 0) {
        return 'greencarrier';
        // return 'isa';
        // return 'demo';
    }
    if (host.split('.')[0] === 'www' || host.split('.')[0] === 'react' || host.includes('localhost')) {
        return 'greencarrier';
        // return 'isa';
<<<<<<< HEAD
=======
        // return 'demo';
>>>>>>> 361d5d3c8e7483be045653d2654533b87c06637d
    }
    return host.split('.')[0];
};
