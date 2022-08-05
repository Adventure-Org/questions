import http from 'k6/http';

export let options = {
  insecureSkipTLSVerify: true,
  noConnectionReuse: false,
  scenarios: {
    constant_request_rate: {
      executor: 'constant-arrival-rate',
      rate: '1500',
      timeUnit: '1s',
      duration: '60s',
      preAllocatedVUs: 4000,
      maxVUs: 4000
    },
  },
};
const url = 'http://localhost:3000';

export default () => {
  // http.get('http://localhost:3000/qa/questions?product_id=1');
  http.batch([
    ['GET', `${url}/qa/questions?product_id=998849`],
    ['GET', `${url}/qa/questions/3514862/answers`],
  ]);

};

