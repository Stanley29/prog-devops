db = db.getSiblingDB("geographydb");

db.questions.insertMany([
  { id: 1, question: "What is the capital of France?", answers: ["Paris", "Berlin", "Rome"], answer: 0 },
  { id: 2, question: "What is the capital of Germany?", answers: ["Vienna", "Berlin", "Madrid"], answer: 1 },
  { id: 3, question: "What is the capital of Italy?", answers: ["Rome", "Paris", "Athens"], answer: 0 },
  { id: 4, question: "What is the capital of Spain?", answers: ["Lisbon", "Madrid", "Barcelona"], answer: 1 },
  { id: 5, question: "What is the capital of Ukraine?", answers: ["Kyiv", "Lviv", "Kharkiv"], answer: 0 },
  { id: 6, question: "What is the capital of Poland?", answers: ["Warsaw", "Krakow", "Gdansk"], answer: 0 },
  { id: 7, question: "What is the capital of Austria?", answers: ["Vienna", "Graz", "Linz"], answer: 0 },
  { id: 8, question: "What is the capital of Switzerland?", answers: ["Bern", "Zurich", "Geneva"], answer: 0 },
  { id: 9, question: "What is the capital of Belgium?", answers: ["Brussels", "Antwerp", "Ghent"], answer: 0 },
  { id: 10, question: "What is the capital of Netherlands?", answers: ["Amsterdam", "Rotterdam", "The Hague"], answer: 0 },
  { id: 11, question: "What is the capital of Sweden?", answers: ["Stockholm", "Oslo", "Copenhagen"], answer: 0 },
  { id: 12, question: "What is the capital of Norway?", answers: ["Oslo", "Bergen", "Trondheim"], answer: 0 },
  { id: 13, question: "What is the capital of Finland?", answers: ["Helsinki", "Turku", "Tampere"], answer: 0 },
  { id: 14, question: "What is the capital of Denmark?", answers: ["Copenhagen", "Aarhus", "Odense"], answer: 0 },
  { id: 15, question: "What is the capital of Portugal?", answers: ["Lisbon", "Porto", "Braga"], answer: 0 }
]);
