let url;
if (process.env.NODE_ENV === 'production') {
    url = 'https://api.itsmycargo.com';
} else {
    // url = 'http://localhost:3000';
    url = 'https://api.itsmycargo.com';
}
export const BASE_URL = url;
