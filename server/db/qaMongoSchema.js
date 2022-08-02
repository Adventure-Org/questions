const mongoose = require('mongoose');

let repoSchema = mongoose.Schema({
  product_id: {type: Number, unique: true},
  question_id: {type: Number, unique: true},
  question_body: String,
  question_helpfulness: Number,
  reported: Boolean,
  answers: [
    {
      answer_id: {type: Number, unique: true},
      body: String,
      answerer_name: String,
      helpfulness: Number,
      reported: Boolean,
      photos: [
        {
          photo_id: {type: Number, unique: true},
          url: String,
        }
      ]
    }
  ]
});