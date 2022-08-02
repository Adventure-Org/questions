import http from 'k6/http';

export let options = {
  insecureSkipTLSVerify: true,
  noConnectionReuse: false,
  vus: 60,
  duration: '30s',
};

const url = 'http://localhost:3000';

export default () => {
  // http.get('http://localhost:3000/qa/questions?product_id=1');
  http.batch([
    ['GET', `${url}/qa/questions?product_id=3000000`],
    ['GET', `${url}/qa/questions/2000000/answers`],
  ]);
};
