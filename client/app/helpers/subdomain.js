export const getSubdomain = () => {
    const host = window.location.host;
    if (host.indexOf('.') < 0) {
        return 'demo';
        // return 'isa';
        // return 'demo';
    }
    if (host.split('.')[0] === 'www' || host.split('.')[0] === 'react' || host.includes('localhost')) {
        return 'demo';
    }
    return host.split('.')[0];
};
