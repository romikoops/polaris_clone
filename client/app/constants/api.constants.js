let url;
if (process.env.NODE_ENV === 'production') {
  url = 'https://imc-api.herokuapp.com';
} else {
  url = 'http://localhost:3000';
}
export const BASE_URL = url;
