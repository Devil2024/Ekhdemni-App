# Import necessary libraries
import pandas as pd
import nltk
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report
from chatterbot import ChatBot
from chatterbot.trainers import ChatterBotCorpusTrainer

# Load the dataset from the specified path
df = pd.read_csv("car diagnose.csv")

# Preprocess the text
nltk.download('punkt')
nltk.download('stopwords')
stop_words = set(stopwords.words('english'))

def preprocess_text(text):
    words = nltk.word_tokenize(str(text).lower())
    words = [word for word in words if word.isalnum() and word not in stop_words]
    return " ".join(words)

# Concatenate relevant columns to provide more context
df['text'] = df['Issue'] + " " + df['Diagnostic Steps'] + " " + df['Possible Causes']

# Preprocess the concatenated text
df['text'] = df['text'].apply(preprocess_text)

# Vectorize the concatenated text
vectorizer = TfidfVectorizer(max_features=1000)
X = vectorizer.fit_transform(df['text'])
y = df['Recommended Action']

# Split the dataset
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train the model
model = LogisticRegression()
model.fit(X_train, y_train)

# Evaluate the model
predictions = model.predict(X_test)
print(classification_report(y_test, predictions))

# Create a new ChatterBot
car_trouble_bot = ChatBot('CarTroubleBot')

# Train the bot using the English corpus
trainer = ChatterBotCorpusTrainer(car_trouble_bot)
trainer.train("chatterbot.corpus.english")

# Train the bot using the custom dataset
for i in range(len(df)):
    car_trouble_bot.learn(df['text'][i], df['Recommended Action'][i])

# Interact with the chatbot
while True:
    user_input = input("You: ")
    if user_input.lower() == 'quit':
        break
    response = car_trouble_bot.get_response(user_input)
    print("CarTroubleBot: ", response)
