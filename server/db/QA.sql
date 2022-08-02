DROP DATABASE IF EXISTS QASection;
CREATE DATABASE QASection;

\c qasection;

DROP TABLE IF EXISTS questions CASCADE;
CREATE TABLE questions (
  id SERIAL PRIMARY KEY,
  product_id INT NOT NULL,
  body VARCHAR(1000),
  date_written BIGINT NOT NULL,
  asker_name VARCHAR(255) NOT NULL,
  asker_email VARCHAR(255) NOT NULL,
  helpful INT NOT NULL,
  reported BOOLEAN NOT NULL
);

DROP TABLE IF EXISTS answers CASCADE;
CREATE TABLE answers (
  id SERIAL PRIMARY KEY,
  body VARCHAR(1000) NOT NULL,
  date_written BIGINT NOT NULL,
  answerer_name VARCHAR(255) NOT NULL,
  answerer_email VARCHAR(255) NOT NULL,
  helpful INT NOT NULL,
  reported BOOLEAN NOT NULL,
  question_id INT NOT NULL,
  FOREIGN KEY (question_id)
    REFERENCES questions(id)
);

DROP TABLE IF EXISTS answer_photos;
CREATE TABLE answer_photos (
  id SERIAL PRIMARY KEY,
  "url" VARCHAR(1000) NOT NULL,
  answer_id INT NOT NULL,
  FOREIGN KEY (answer_id)
    REFERENCES answers(id)
);

\COPY questions(id , product_id, body, date_written, asker_name, asker_email, reported, helpful) FROM '/Users/roycechun/Desktop/RFP2205/Atelier-Backend/data/questions.csv' CSV HEADER;

\COPY answers(id, question_id, body, date_written, answerer_name, answerer_email, reported, helpful) FROM '/Users/roycechun/Desktop/RFP2205/Atelier-Backend/data/answers.csv' CSV HEADER;

\COPY answer_photos(id, answer_id, url) FROM '/Users/roycechun/Desktop/RFP2205/Atelier-Backend/data/answers_photos.csv' CSV HEADER;

ALTER TABLE questions
ALTER COLUMN date_written TYPE timestamp
USING to_timestamp(date_written / 1000::numeric);

ALTER TABLE answers
ALTER COLUMN date_written TYPE timestamp
USING to_timestamp(date_written / 1000::numeric);


CREATE INDEX idx_questions_productID ON questions(product_id);
CREATE INDEX idx_answers_questionID ON answers(question_id);
CREATE INDEX idx_photos_answerID ON answer_photos(answer_id);


select setval( pg_get_serial_sequence('questions', 'id'),
               (select max(id) from questions)
             );
select setval( pg_get_serial_sequence('answers', 'id'),
               (select max(id) from answers)
             );
select setval( pg_get_serial_sequence('answer_photos', 'id'),
               (select max(id) from answer_photos)
             );