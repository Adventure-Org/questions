SELECT q.*, (SELECT json_agg(a.*), () FROM answers a WHERE a.question_id = q.id) as answers
FROM questions q LIMIT 10;


EXPLAIN SELECT q, (SELECT json_agg(a) FROM answers a WHERE a.question_id = q.id) as answers FROM questions q WHERE q.product_id = 50000 LIMIT 5 OFFSET 0;


EXPLAIN SELECT q.*, (SELECT json_agg(a), (SELECT json_agg(p) ) as photos FROM answers a WHERE a.question_id = q.id) as answers FROM questions q WHERE q.product_id = 50000 LIMIT 5 OFFSET 0;



SELECT q.product_id, q.id, q.body, q.date_written, q.asker_name, q.asker_email, q.helpful,
json_agg(json_build_object("id", a.id, "body", a.body, "date_written", a.date_written, "answerer_email", a.answerer_email, "answerer_name", a.answerer_name, "helpful", a.helpful, "reported", a.reported)) as answers FROM questions q LEFT JOIN answers a ON a.question_id = q.id WHERE q.product_id = 15 GROUP BY q.product_id, q.id, q.body, q.date_written, q.asker_name, q.asker_email, q.helpful;

SELECT q.product_id, q.id, q.body, q.date_written, q.asker_name, q.asker_email, q.helpful


EXPLAIN SELECT q.*, (SELECT json_agg(a.*) FROM answers a WHERE a.question_id = q.id) as answers FROM questions q WHERE q.product_id = $1 LIMIT $2 OFFSET $3


SELECT
   q.product_id, q.body, q.date_written, q.asker_name, q.asker_email, q.helpful,
  json_agg(json_build_object("a.id", a.id, "body", a.body, "date_written", a.date_written, "answerer_email", a.answerer_email, "answerer_name", a.answerer_name, "helpful", a.helpful, "reported", a.reported)) as answer
FROM questions q
INNER JOIN answers a on a.question_id = q.id
WHERE q.product_id = 1;


EXPLAIN SELECT q, json_agg(a) as answer
FROM questions q
LEFT JOIN answers a ON a.question_id = q.id
WHERE q.product_id = 5
GROUP BY q.id;



SELECT q, json_object_agg(a.id, a) as answer
FROM questions q
INNER JOIN answers a ON a.question_id = q.id
WHERE q.product_id = 5
GROUP BY q.id;

-- working
with answer as (
  SELECT
    a.question_id, json_agg(p) as photos
  FROM answers a
  INNER JOIN answer_photos p ON p.answer_id = a.id
  GROUP BY a.id
)
SELECT q.id, json_agg(a) as answers
FROM questions q
INNER JOIN answer a ON q.id = a.question_id
WHERE q.product_id = 3
GROUP BY q.id;


-- SELECT p.id, json_agg(f) as features
-- FROM products p
-- INNER JOIN features f ON p.id = f.product_id
-- WHERE p.id = 5


with answer as (
  SELECT
    a.id as answer_id,
    a.question_id,
    a.date_written as date,
    a.answerer_name,
    a.helpful as helpfulness,
    (SELECT array_agg(p.url) FROM answer_photos p WHERE a.id = p.answer_id) as photos
  FROM
    answers a)
SELECT
  q.id as question_id,
  q.body as question_body,
  q.date_written as question_date,
  q.asker_name,
  q.helpful as question_helpfulness,
  q.reported,
  json_object_agg(a.answer_id , json_build_object('id', a.answer_id, 'date', a.date, 'answerer_name', a.answerer_name, 'helpfulness', a.helpfulness, 'photos', a.photos)) as answers
FROM
  questions q
INNER JOIN answer a ON q.id = a.question_id
WHERE q.product_id = 3 AND a.answer_id IS NOT NULL
GROUP BY q.id;


SELECT
    q.id as question_id,
    q.body as question_body,
    q.date_written as question_date,
    q.asker_name,
    q.helpful as question_helpfulness,
    (
      SELECT
        json_object_agg(a.id, json_build_object(
          'id', a.id,
          'question_id', a.question_id,
          'date', a.date_written,
          'answerer_name', a.answerer_name,
          'photos', (
            SELECT
              array_agg(p.url)
            FROM
              answer_photos p
            WHERE
              a.id = p.answer_id )
          ))
      FROM
        answers a
      WHERE
        a.question_id = q.id
    ) as answers
FROM questions q
WHERE q.product_id = 3
GROUP BY q.id;


with photos as (
  SELECT
    answer_id,
    json_agg(p.url) photos
  FROM answer_photos p
  group by 1
),
answer as (
  SELECT
    question_id,
    json_agg(
        json_build_object(
          "id", a.id,
          "photos", photos
        )
    ) as answer
  FROM answers a
  LEFT JOIN photos p on a.id = p.answer_id
  GROUP BY a.question_id
)
SELECT
  json_agg(a) as results
  FROM questions q
  LEFT JOIN answer a on q.id = a.question_id
WHERE q.product_id = 40347 AND a.question_id IS NOT NULL;


with photos as ( SELECT answer_id, json_agg(p.url) photos FROM answer_photos p group by 1), answer as ( SELECT question_id, json_agg( json_build_object( "id", a.id, "photos", photos )) answer FROM answers a INNER JOIN photos p on a.id = p.answer_id GROUP BY a.question_id ) SELECT json_build_object('results', json_agg(answer)) question FROM questions q INNER JOIN answer a on q.id = a.question_id WHERE q.product_id = '40347';



-- get questions for specific product_id
SELECT
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
GROUP BY q.id LIMIT $2 OFFSET $3;


-- get answers for specific question_id
SELECT
  *
FROM
  answers a
WHERE
  a.question_id = 5;

-- get answers for specific question_id
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
        a.id = p.answer_id ) as photos
FROM
  answers a
WHERE
  a.question_id = 1;


-- add question for specific product_id

INSERT INTO questions (body, asker_name, product_id, asker_email, date_written, reported, helpful)
VALUES ($1, $2, $3, $4, current_timestamp, false, 0);


-- add answer for specific question_id

with new_answer as (
  INSERT INTO answers (body, answerer_name, answerer_email, question_id, date_written, reported, helpful)
  VALUES($1, $2, $3, $4, current_timestamp, false, 0)
  returning id;
)


-- add photos for specific answer_id
INSERT INTO answer_photos (url, answer_id)
VALUES %L