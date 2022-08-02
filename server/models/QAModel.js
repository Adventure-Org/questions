const { Pool } = require('pg');
const format = require('pg-format');
require('dotenv').config();

const pool = new Pool({
  host: process.env.host,
  user: process.env.user,
  database: process.env.database,
  port: process.env.dbport,
});

exports.getQuestions = (req, res) => {
  let { product_id, page, count } = req.query;
  let offset = 0;
  let responseObj = {};

  console.log(' here is questions: ', product_id);
  if (page === undefined) {
    page = 1;
  }

  if (count === undefined) {
    count = 5;
  }

  if (page > 1) {
    offset = page * count;
  }

  const values = [product_id, count, offset];

  pool.query(`SELECT
  q.id as question_id,
  q.body as question_body,
  q.date_written as question_date,
  q.asker_name,
  q.helpful as question_helpfulness,
  q.reported,
  (
    SELECT
      coalesce(json_object_agg(a.id, json_build_object(
        'id', a.id,
        'question_id', a.question_id,
        'date', a.date_written,
        'answerer_name', a.answerer_name,
        'photos', (
          SELECT
            coalesce(array_agg(p.url), ARRAY[]::text[])
          FROM
            answer_photos p
          WHERE
            a.id = p.answer_id )
        )), '{}'::json)
    FROM
      answers a
    WHERE
      a.question_id = q.id
  ) as answers
FROM questions q
WHERE q.product_id = $1
GROUP BY q.id LIMIT $2 OFFSET $3;`, values)
    .then((result) => {
      responseObj.product_id = product_id;
      responseObj.results = result.rows;
      res.status(200).send(responseObj);
    })
    .catch((err) => console.log(err));
};

exports.getAnswers = (req, res) => {
  const { question_id } = req.params;
  let { page, count } = req.query;
  let responseObj = {};
  let offset = 0;

  if (page === undefined) {
    page = 1;
  }

  if (count === undefined) {
    count = 5;
  }

  if (page > 1) {
    offset = page * count;
  }

  const values = [question_id, count, offset];

  pool.query(`
    SELECT
    a.id as answer_id,
    a.body,
    a.date_written as date,
    a.answerer_name,
    a.helpful as helpfulness,
    (
        SELECT
          coalesce(array_agg(p.url), ARRAY[]::text[])
        FROM
          answer_photos p
        WHERE
          a.id = p.answer_id AND a.reported = false) as photos
    FROM
      answers a
    WHERE
      a.question_id = $1 AND q.reported = false LIMIT $2 OFFSET $3;`, values)
    .then((result) => {
      responseObj.question = question_id;
      responseObj.page = page;
      responseObj.count = count;
      responseObj.results = result.rows;
      res.status(200).send(responseObj);
    })
    .catch((err) => console.log(err));
};

exports.addQuestion = (req, res) => {
  const { body, name, email, product_id } = req.body;
  console.log(name);
  const values = [body, name, email, product_id];

  pool.query(`INSERT INTO questions (body, asker_name, asker_email, product_id, date_written, reported, helpful)
  VALUES ($1, $2, $3, $4, current_timestamp, false, 0);`, values)
    .then(() => res.status(201).send('201 CREATED'))
    .catch((err) => console.log(err));
};

exports.addAnswer = (req, res) => {
  const { question_id } = req.params;
  const { body, name, email, photos } = req.body;

  const values = [body, name, email, question_id];

  const photoRows = [];

  pool.query(`
    INSERT INTO answers (body, answerer_name, answerer_email, question_id, date_written, reported, helpful)
    VALUES($1, $2, $3, $4, current_timestamp, false, 0)
    returning id;
    `, values)
    .then((result) => {
      const { id } = result.rows[0];
      for (let i = 0; i < photos.length; i++) {
        photoRows.push([photos[i], id]);
      }
      return pool.query(format(`INSERT INTO answer_photos (url, answer_id)
      VALUES %L`, photoRows), []);
    })
    .then(() => res.status(201).send('201 CREATED'))
    .catch((err) => console.log(err));
};

exports.markQuestionHelpful = (req, res) => {
  const { question_id } = req.params;

  pool.query(`
    UPDATE questions
      SET helpful = helpful + 1
    WHERE id = ${question_id}
  `)
    .then(() => res.status(204).send('204 NO CONTENT'))
    .catch((err) => console.log(err));
};

exports.reportQuestion = (req, res) => {
  const { question_id } = req.params;

  pool.query(`
    UPDATE questions
      SET reported = true
    WHERE id = ${question_id}
  `)
    .then(() => res.status(204).send('204 NO CONTENT'))
    .catch((err) => console.log(err));
};

exports.markAnswerHelpful = (req, res) => {
  const { answer_id } = req.params;

  pool.query(`
    UPDATE answers
      SET helpful = helpful + 1
    WHERE id = ${answer_id}
  `)
    .then(() => res.status(204).send('204 NO CONTENT'))
    .catch((err) => console.log(err));
};

exports.reportAnswer = (req, res) => {
  const { answer_id } = req.params;

  pool.query(`
    UPDATE answers
      SET reported = true
    WHERE id = ${answer_id}
  `)
    .then(() => res.status(204).send('204 NO CONTENT'))
    .catch((err) => console.log(err));
};
