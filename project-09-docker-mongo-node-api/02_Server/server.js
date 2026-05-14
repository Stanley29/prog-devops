const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();
app.use(cors());

mongoose
  .connect("mongodb://admin:admin@geography-db:27017/geographydb?authSource=admin")
  .then(() => console.log("Connected to Mongodb"))
  .catch((err) => console.error("MongoDB connection error:", err));

const questionSchema = new mongoose.Schema({
  id: Number,
  question: String,
  answers: [String],
  answer: Number
});

const Question = mongoose.model("Question", questionSchema);

app.get("/questions", async (req, res) => {
  const questions = await Question.find({});
  res.json(questions);
});

app.listen(4000, () => {
  console.log("API listening on port 4000");
});
