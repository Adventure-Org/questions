const express = require('express');
const db = require('./models/QA_Model');

const router = express.Router();

router.get('/qa/questions', db.getQuestions);

router.get('/qa/questions/:question_id/answers', db.getAnswers);

router.post('/qa/questions', db.addQuestion);

router.post('/qa/questions/:question_id/answers', db.addAnswer);

router.put('/qa/questions/:question_id/helpful', db.markQuestionHelpful);

router.put('/qa/questions/:question_id/report', db.reportQuestion);

router.put('/qa/answers/:answer_id/helpful', db.markAnswerHelpful);

router.put('/qa/answers/:answer_id/report', db.reportAnswer);

module.exports = router;
