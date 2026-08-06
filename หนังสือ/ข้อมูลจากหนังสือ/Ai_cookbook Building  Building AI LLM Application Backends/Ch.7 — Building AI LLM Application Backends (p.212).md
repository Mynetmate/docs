# 7 Building AI LLM Application Backends

  

In the early days of the web, or even just a few years ago, we had one monolithic application for our web services. We would use HTML/CSS/JavaScript for the part that the user sees, and we would add some logic and code to handle the business logic and the connector between what the user sees and the logic. Fast forward to today, where most web applications have now separated the application into two main components: the frontend and the backend. The reasons for this separation can be broadly categorized as so:

  

- Specialization: Developers can focus on user experience (frontend) or business logic and data (backend)

  

- Scalability: When making updates, only part of the code base needs to be updated, thus making it less likely to break and be more scalable

  

- Security: Most of the sensitive data lives in the backend, where it can be protected

  

One of the best analogies I have come across regarding frontends and backends is that of restaurants. The frontend is similar to the dining area and what the customer sees and interacts with, whereas the backend is like the kitchen, where much of the work happens out of sight of the customer: the customer’s meal is cooked and delivered to the dining area before it reaches them. Each of these areas requires different skillsets and technologies, but they work together to deliver the finished product (I don’t know about you, but now I am kind of hungry).

  

_Building AI LLM Application Backends_

  

184

  

In the previous chapter, we learned about a simple way to create a frontend with Streamlit. However, much of the business logic still lives in the same Streamlit app we created. What if we want to start using databases to persist our data? What about scaling our application into smaller parts? We saw how we can just make API calls to OpenAI, but how about recreating a service just like that for our own services?

  

In this chapter, we will start to learn how to create a basic API server – that is, a web backend – to service our application. We will build a FastAPI application that uses OpenAI’s GPT models to answer network questions intelligently.

  

In this chapter, we will cover the following recipes:

  

- Simple network AI APIs

  

- Adding device context

  

- Adding database storage

  

- Simple web interface

  

- Docker deployment

  

Different from previous chapters, where the recipes were somewhat independent from each other, in this chapter, we will gradually build out our application with each successive recipe.

  

## **Technical requirements**

  

Before we get started, remember to create a new folder for this chapter and a Python virtual environment to house the code. Since this chapter gradually builds up the application, we do not need to create subfolders for each recipe.

  

We will need to install the following new Python packages, as well as exporting our OpenAI API key:

  

```

$ pip install fastapi uvicorn openai sqlalchemy python-multipart openai

$ export OPENAI_API_KEY="your-openai-api-key"

```

  

## **7.1 Simple network AI APIs**

  

Let’s create a basic FastAPI application that uses OpenAI’s GPT model to answer network questions. We have completed similar tasks while following other recipes in this book, but in this recipe, we will do it in the context of FastAPI to learn the basics of the FastAPI framework.

  

_Chapter 7_

  

185

  

### **Getting ready**

  

No new software is needed for this recipe. Please make sure you’ve installed the packages specified in the _Technical requirements_ section.

  

### **How to do it…**

  

1. Create the following Python file, `main_v1.py` :

  

```

from fastapi import FastAPI

from pydantic import BaseModel

import openai

import os

app = FastAPI(title="Network AI")

client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

classQuestionRequest(BaseModel):

    question: str

@app.post("/ask")

defask_question(request: QuestionRequest):

ifnot client.api_key:

return {

"answer": "Please set your OPENAI_API_KEY environment

                      variable"

        }

try:

        response = client.chat.completions.create(

            model="gpt-3.5-turbo",

            messages=[

                {

"role": "system",

"content": "You are a network engineer assistant

                               Give concise, practical answers about

                               network troubleshooting,

                               configuration, and performance

                               issues."         },

                {

"role": "user",

"content": request.question

                }

            ],

            max_tokens=150

        )

return {"answer": response.choices[0].message.content}

except Exception as e:


return {"answer": f"AI service unavailable: {str(e)}"}

if __name__ == "__main__":

import uvicorn

    uvicorn.run(app, port=8000)

```

  

2. We can run the server as follows:

  

```

$ python main_v1.py

```

  

```

INFO:     Started server process [142204]

INFO:     Waiting for application startup.

INFO:     Application startup complete.

INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to

quit)

INFO:     127.0.0.1:44394 - "POST /ask HTTP/1.1" 200 OK

```

  

3. We can use `curl` and the `/ask` endpoint to try out the function:

  

```

$ curl -X POST "http://localhost:8000/ask"   -H "Content-Type:

application/json"   -d '{"question": "Why is my BGP session down?"}'

{"answer":"Your BGP session could be down due to various reasons

such as improper configuration, peer misconfiguration, network

connectivity issues, MTU mismatches, routing problems, or BGP

neighbor password mismatch. Check the configuration, network

reachability, and logs for errors to identify the exact cause of the

BGP session being down."}

```

  

_Chapter 7_

  

187

  

4. One of the biggest differences between a backend and a frontend is that the backend mainly focuses on serving content, _not_ the user interface. If we navigate to `127.0.0.1:8000` , we will see a not-so-pretty page:

  
  
  

_Figure 7.1: Default FastAPI page_

  

5. However, documentation is always a first-class citizen with FastAPI. We can see the automatically generated documentation at the `/docs` endpoint:

  
  
  

_Figure 7.2: FastAPI documentation_

  

### **How it works…**

  

FastAPI wraps our application in a function that automatically handles HTTP requests, JSON serialization, and API documentation generation. The `title` parameter sets the name whenever the title is shown, such as on the documentation page:

  

```

app = FastAPI(title="Network AI")

```

  

_Building AI LLM Application Backends_

  

188

  

One of FastAPI’s best features is its integration with Pydantic. In the following code, if someone sends invalid data for a question, such as a wrong type or a missing value, Pydantic automatically validates the incoming JSON request, and FastAPI will generate an error message:

  

```

classQuestionRequest(BaseModel):

    question: str

```

  

The following section is the AI magic where we craft the prompt, specify the model, and parse out the response:

  

```

        response = client.chat.completions.create(

            model="gpt-3.5-turbo",

            messages=[

                {

"role": "system",

"content": "You are a network engineer assistant.

                               Give concise, practical answers about

                               network troubleshooting, configuration, and

                               performance issues."

                },

                {"role": "user", "content": request.question}

            ],

            max_tokens=150

        )

return {"answer": response.choices[0].message.content}

```

  

The import at the end might look weird, but it is FastAPI’s best practice. This only imports `uvicorn` when needed (when running the file directly):

  

```

if __name__ == "__main__":

import uvicorn

    uvicorn.run(app, port=8000)

```

  

_Chapter 7_

  

189

  

### **There’s more…**

  

For more verbose logging, we can use the following pattern to document more information:

  

```

import logging

logging.basicConfig(level=logging.INFO)

@app.post("/ask")

defask_question(request: QuestionRequest):

    logging.info(f"Question received: {request.question}")

```

  

### **See also**

  

You can learn more about FastAPI at `https://fastapi.tiangolo.com/` .

  

## **7.2 Adding device context**

  

Let’s enhance our AI application so that it includes a feature to give device-specific advice. This will give us more detailed answers as the additional vendor information will provide more specific commands and solutions.

  

This recipe is meant to demonstrate how we can refactor our code to add more features to our application.

  

### **Getting ready**

  

Please ensure that you’ve completed the _Simple network AI APIs_ recipe.

  

### **How to do it…**

  

1. To enhance the script we made in the _Simple network AI APIs_ recipe, copy the same script and name it `main_v2.py` .

  

2. Next, add an additional parameter called `device_type` to our `QuestionRequest` class:

  

```

classQuestionRequest(BaseModel):

    question: str

    device_type: str = "generic"

```

  

3. We can add an `if-else` loop to modify our prompt accordingly:

  

```

if request.device_type.lower() == "cisco":

        system_msg += (

"Focus on Cisco IOS/IOS-XE commands and syntax. "

```

  

_Building AI LLM Application Backends_

  

190

  

```

            "Provide specific 'show' and 'configure' commands. "

        )

elif request.device_type.lower() == "juniper":

        system_msg += (

"Focus on Junos commands and syntax. "

            "Use 'show' and 'set' command formats. "

        )

elif request.device_type.lower() == "arista":

        system_msg += (

"Focus on Arista EOS commands and syntax. "

            "Use EOS-specific features and commands. "

)

elif request.device_type.lower() == "palo alto":

        system_msg += (

"Focus on Palo Alto firewall commands and web "

            "interface guidance. "

        )

else:

        system_msg += "Provide vendor-neutral network guidance. "

    system_msg += (

"Give concise, practical answers with specific commands "

        "when relevant. "

```

  

4. We can also change our model to the `gpt-4.1` model:

  

```

        response = client.chat.completions.create(

            model="gpt-4.1",

            messages=[

                {"role": "system", "content": system_msg},

                {"role": "user", "content": request.question}

            ],

            max_tokens=200

        )

return {

"answer": response.choices[0].message.content,

"device_type": request.device_type

        }

```

  

_Chapter 7_

  

191

  

5. Finally, we can try it out by using `curl` commands. For instance, we can get a list of sup-

  

   - ported vendors, as well as specifying particular vendors, such as Cisco or Juniper:

  

```

$ curl "http://localhost:8000/devices" | jq

…

{

  "supported_devices": [

    "cisco",

    "juniper",

    "arista",

    "palo alto",

    "generic"

  ],

  "usage": "Include device_type in your JSON request for device-

specific help"

}

$ curl -X POST "http://localhost:8000/ask" \

…

{

  "answer": "To check the status of all interfaces:\n\

n```\nshow interfaces status\n```\n\

nOr for a specific interface, such as GigabitEthernet1:\n\

n```\nshow interface GigabitEthernet1\n```\n\

nYou can also get a brief overview of all interfaces with:\n\

n```\nshow ip interface brief\n```\n\

nThis will show interface names, IP addresses, and their status (up/

down).",

  "device_type": "cisco"

}

$ curl -X POST "http://localhost:8000/

ask"   -H "Content-Type: application/

json"   -d '{"question": "How do I check interface status?", "device_

type": "juniper"}' | jq

…

{

  "answer": "To check interface status on a Junos device, use:\n\

n```\nshow interfaces terse\n```\n\

```

  

_Building AI LLM Application Backends_

  

192

  

```

nThis command displays a summary of all interfaces and their status

(up/down). For details about a specific interface (e.g., ge-

0/0/1):\n\n```\nshow interfaces terse ge-0/0/1\n```\

nor for detailed status:\n\n```\nshow interfaces ge-0/0/1\n```\

nThis includes protocol and physical status, errors, and traffic

statistics.",

  "device_type": "juniper"

}

```

  

### **How it works…**

  

This recipe illustrates that sometimes, we do not need to write a lot of code to have a vastly improved answer; sometimes, we can just tweak the existing framework and its parameters. In this case, we already had a request model; we simply needed to add new fields. We already had system messages in place, so all we had to do was dynamically append them with user-provided information.

  

The core of this innovation is the AI LLM prompt, which we built dynamically based on the device type. AI gets smarter when newer models and a more contextual background are used.

  

### **There’s more…**

  

Remember Postman from the _Using Postman with OpenAI testing_ recipe in _Chapter 2_ ? It is a great tool for testing our backend application.

  

### **See also**

  

See the _Using Postman with OpenAI testing_ recipe in _Chapter 2_ .

  

## **7.3 Adding database storage**

  

In most of our applications, we need to store data to persist information. In this recipe, we will add a SQLite database to store our conversations. This will help us track what our users are asking about and provide conversation history.

  

### **Getting ready**

  

Please complete the _Adding device context_ recipe before moving on to this recipe.

  

_Chapter 7_

  

193

  

### **How to do it…**

  

1. As we have done previously, let’s copy `main_v2.py` to a new file named `main_v3.py` .

  

2. Add the following additional imports:

  

```

from sqlalchemy import create_engine, Column, Integer, String,

DateTime

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import sessionmaker

```

  

3. Create the database session:

  

```

# Database setup

engine = create_engine("sqlite:///questions.db")

Base = declarative_base()

Session = sessionmaker(bind=engine)

```

  

4. Specify the database model for questions:

  

```

classQuestion(Base):

    __tablename__ = "questions"

id = Column(Integer, primary_key=True)

    question = Column(String)

    answer = Column(String)

    device_type = Column(String)

    timestamp = Column(DateTime, default=datetime.now)

```

  

5. Add the following code, which allows for automatic table creation:

  

```

Base.metadata.create_all(engine)

```

  

6. We’ll use the following code in the `ask_question()` function to save the answer to the database:

  

```

# Save to database

    session = Session()

    session.add(

        Question(

            question=request.question,

            answer=answer,

            device_type=request.device_type

        )

```

  

_Building AI LLM Application Backends_

  

194

  

```

    )

    session.commit()

    session.close()

```

  

7. We’ll also create a `/history` endpoint to query the questions:

  

```

@app.get("/history")

defget_history():

    session = Session()

    questions = (

        session.query(Question)

        .order_by(Question.timestamp.desc())

        .limit(10)

        .all()

    session.close()

return [

{

"question": q.question,

            "answer": q.answer,

            "device_type": q.device_type,

            "time": q.timestamp} for q in questions

]

```

  

8. Let’s try it out. We will start by asking a few questions:

  

```

$ curl -X POST "http://localhost:8000/ask" \

  -H "Content-Type: application/json" \

  -d '{"question": "How do I troubleshoot OSPF

neighbor issues?", "device_type": "cisco"}' | jq

$ curl -X POST "http://localhost:8000/ask" \

  -H "Content-Type: application/json" \

  -d '{"question": "How do I configure VLANs?", "device_

type": "juniper"}' | jq

$ curl -X POST "http://localhost:8000/ask" \

  -H "Content-Type: application/json" \

  -d '{"question": "Why is my interface down?", "device_

type": "arista"}' | jq

```

  

_Chapter 7_

  

195

  

9. We can use the new ‘/history’ endpoint to retrieve all the questions and answers.

  

```

$ curl "http://localhost:8000/history"

```

  

```

[{"question":"Why is my interface down?","answer":"To check

why an interface is down on an Arista switch, you can use

the following commands:\n\n1. Verify the administrative

and operational status of the interface:\n```\nshow interfaces

status\n```\n\n2. Check if the interface is configured:\n```\nshow

running-config interface <interface>\n```\n\n3. Verify if there

are any error counters on the interface:\n```\nshow interfaces

<interface> | include errors\n```\n\n4. Check if the interface is

physically connected and the link is up:\n```\nshow interfaces

<interface> | include connected\n```\n\

```

  

```

nUsing these commands will help you diagnose why the interface

is down on your Arista switch.","device_type":"arista","time":"2025-

07-31T00:06:36.104963"},{"question":"How do I configure VLANs?",

"answer":"To configure VLANs on a Juniper device, you can use the

following commands:\n\n1. Enter configuration mode:\n```shell\

nconfigure\n```\n\n2. Create a VLAN and assign a VLAN ID:\

n```shell\nset vlans VLAN_NAME vlan-id VLAN_ID\n```\n\

n3. Assign interfaces to the VLAN:\n```

```

  

```

…

```

  

### **How it works…**

  

Here are the new SQLAlchemy key objects we need to take note of:

  

- `engine` : This connects to a SQLite database file called `questions.db`

  

- `Base` : We declare the `Base` class for database models

  

- `session` : This is a factory for creating database sessions

  

The database model includes the following aspects:

  

- `id` : This is used to auto-increment the primary key; it is an integer

  

- `question` : This is the user’s question; it is a string object

  

- `answer` : This is the AI’s response; it is a string object

  

- `device_type` : This is a string object

  

- `timestamp` : This is a `DateTime` object that we automatically insert using the time at the time of creation

  

_Building AI LLM Application Backends_

  

196

  

As you have seen, the way to save entries to the database is to use a session. We initiate the session, add the necessary information, commit the change, and close the session.

  

### **There’s more…**

  

We can use SQLAlchemy’s built-in functions to provide statistics:

  

```

from sqlalchemy import func

@app.get("/stats")

defget_stats():

    session = Session()

    total = session.query(Question).count()

    by_device = session.query(

        Question.device_type, func.count())

        .group_by(Question.device_type)

        .all()

    session.close()

return {"total_questions": total, "by_device": dict(by_device)}

```

  

### **See also**

  

Please see the _Adding device context_ recipe to learn how to add device context.

  

## **7.4 Simple web interface**

  

The backend’s main function is to provide business logic and handle data. However, just because it does not interact with the end user does not mean we cannot leverage a simple web interface. For example, people might want to use our AI assistant tool without `curl` commands.

  

In this recipe, we will build a simple HTML form to make a simple web interface for our tool.

  

### **Getting ready**

  

Please complete the _Adding database storage_ recipe before moving on to this recipe.

  

### **How to do it…**

  

1. FasAPI provides several libraries to handle web functionalities. In this case, we will import `Form` and `HTMLResponse` :

  

```

from fastapi import FastAPI, Form

from fastapi.responses import HTMLResponse

```

  

_Chapter 7_

  

197

  

2. In this decorator, we’ll use `response_class=HTMLResponse` to indicate that we should return HTML instead of JSON. FastAPI will return HTML content with the `text` / `html` content type:

  

```

# Web interface endpoint

@app.get("/", response_class=HTMLResponse)

defweb_interface():

return"""

    <!DOCTYPE html>

    <html>

    <head>

        <title>Network AI Assistant</title>

        <style>

            body {

                font-family: Arial, sans-serif;

                margin: 40px;

                max-width: 800px;

            }

…

```

  

3. The form contains a few fields for user-entered values. When submitted, you will have the ability to post to the `/web-ask` endpoint:

  

```

        <formmethod="post"action="/web-ask">

            <divclass="form-group">

                <label>Ask your network question:</label>

                <textarea

name="question"

                    rows="3"

                    placeholder=

"e.g., How do I troubleshoot BGP neighbor

                        down?"

                ></textarea>

            </div>

            <divclass="form-group">

                <label>Device Type:</label>

                <selectname="device_type">

                    <optionvalue="generic">Generic</option>

                    <optionvalue="cisco">Cisco</option>

```

  

_Building AI LLM Application Backends_

  

198

  

```

                    <optionvalue="juniper">Juniper</option>

                    <optionvalue="arista">Arista</option>

                    <optionvalue="palo alto">Palo Alto</option>

                </select>

            </div>

            <buttontype="submit">Get AI Answer</button>

        </form>

```

  

4. The function handles the submission and returns an HTML page:

  

_`# Handle web form submission`_ `@app.post("/web-ask", response_class=HTMLResponse) def web_ask_question( question: str = Form(...), device_type: str = Form("generic") ): answer = get_ai_answer(question, device_type)` _`# Save to database`_ `session = Session() session.add( Question( question=question, answer=answer, device_type=device_type ) ) session.commit() session.close() return f""" <!DOCTYPE html> <html> <head> <title>` 🤖 `Network AI Assistant</title> <style> body {{`

  

_Chapter 7_

  

199

  

`font-family: Arial, sans-serif; margin: 40px; max-width: 800px; }} .question {{ background: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; }} .answer {{ background: #f5f5f5; padding: 20px; margin: 10px 0; border-radius: 5px; white-space: pre-wrap; }} .back {{ margin: 20px 0; }} a {{ color: #007cba; text-decoration: none; }} </style> </head> <body> <h1>` 🤖 `Network AI Assistant</h1> <div class="question"> <strong> Your Question ({device_type}): </strong><br> {question} </div> <div class="answer"> <strong>AI Answer:</strong><br> {answer} </div> <div class="back">`

  

_Building AI LLM Application Backends_

  

200

  

<a href="/">← Ask Another Question</a> | `<a href="/history">View History</a> </div> </body> </html> """`

  

5. The header session contains the metadata for the HTML page, as well as the simple style we specified for the page:

  

```

        <style>

body {{

font-family: Arial, sans-serif;

margin: 40px;

max-width: 800px;

            }}

.question {{

background: #e3f2fd;

padding: 15px;

margin: 10px0;

border-radius: 5px;

            }}

.answer {{

background: #f5f5f5;

padding: 20px;

margin: 10px0;

border-radius: 5px;

white-space: pre-wrap;

            }}

.back {{ margin: 20px0; }}

a {{ color: #007cba; text-decoration: none; }}

        </style>

```

  

6. Now, we can try out the web interface.

  

_Chapter 7_

  

201

  
  
  

_Figure 7.3: Network AI Assistant home page_

  

7. Once submitted, we will see the answer that the AI returned.

  
  
  

_Figure 7.4: Network AI Assistant answer_

  

_Building AI LLM Application Backends_

  

202

  

8. This recipe includes HTML code. It is recommended that you copy and paste the script from this book’s GitHub repository to try it out; manually typing in code is not a great way to spend your day. However, we will paste in the entirety of the script for reference here to illustrate the full structure:

  

```

from fastapi import FastAPI, Form

from fastapi.responses import HTMLResponse

from pydantic import BaseModel

import openai

import os

from sqlalchemy import create_engine, Column, Integer, String,

DateTime

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import sessionmaker

from datetime import datetime

# Previous setup code (OpenAI, database, etc.)

client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

engine = create_engine("sqlite:///questions.db")

Base = declarative_base()

Session = sessionmaker(bind=engine)

classQuestion(Base):

    __tablename__ = "questions"

id = Column(Integer, primary_key=True)

    question = Column(String)

    answer = Column(String)

    device_type = Column(String)

    timestamp = Column(DateTime, default=datetime.now)

```

  

```

Base.metadata.create_all(engine)

app = FastAPI(title="Network AI")

classQuestionRequest(BaseModel):

    question: str

    device_type: str = "generic"

defget_ai_answer(question: str, device_type: str = "generic"):

```

  

_Chapter 7_

  

203

  

```

ifnot client.api_key:

return"Please set your OPENAI_API_KEY environment variable"

    system_msg = "You are a network engineer assistant. "

if device_type.lower() == "cisco":

        system_msg += "Focus on Cisco IOS/IOS-XE commands. "

elif device_type.lower() == "juniper":

        system_msg += "Focus on Junos commands. "

elif device_type.lower() == "arista":

        system_msg += "Focus on Arista EOS commands. "

elif device_type.lower() == "palo alto":

        system_msg += "Focus on Palo Alto firewall commands. "

    system_msg += (

"Give concise, practical answers with specific commands."

    )

try:

        response = client.chat.completions.create(

            model="gpt-3.5-turbo",

            messages=[

                {"role": "system", "content": system_msg},

                {"role": "user", "content": question}

            ],

            max_tokens=200

        )

return response.choices[0].message.content

except Exception as e:

returnf"AI service unavailable: {str(e)}"

```

  

```

# Web interface endpoint

@app.get("/", response_class=HTMLResponse)

defweb_interface():

return"""

    <!DOCTYPE html>

    <html>

    <head>

        <title>Network AI Assistant</title>

```

  

_Building AI LLM Application Backends_

  

204

  

`<style> body { font-family: Arial, sans-serif; margin: 40px; max-width: 800px; } .form-group { margin: 20px 0; } input[type="text"], select, textarea { width: 100%; padding: 10px; font-size: 16px; } button { background: #007cba; color: white; padding: 12px 24px; border: none; font-size: 16px; cursor: pointer; } .answer { background: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 5px; } </style> </head> <body> <h1>` 🤖 `Network AI Assistant</h1> <form method="post" action="/web-ask"> <div class="form-group"> <label> Ask your network question: </label>`

  

_Chapter 7_

  

205

  

`<textarea name="question" rows="3" placeholder="e.g., How do I troubleshoot BGP neighbor down?"> </textarea> </div> <div class="form-group"> <label>Device Type:</label> <select name="device_type"> <option value="generic"> Generic </option> <option value="cisco"> Cisco </option> <option value="juniper"> Juniper </option> <option value="arista"> Arista </option> <option value="palo alto"> Palo Alto </option> </select> </div> <button type="submit">Get AI Answer</button> </form> <div> <h3>Recent Questions</h3> <p> <a href="/history">` View all conversation history → `</a> </p> </div> </body>`

  

_Building AI LLM Application Backends_

  

206

  

```

    </html>

    """

# Handle web form submission

@app.post("/web-ask", response_class=HTMLResponse)

defweb_ask_question(question: str = Form(...), device_

type: str = Form("generic")):

    answer = get_ai_answer(question, device_type)

# Save to database

    session = Session()

    session.add(Question(

        question=question, answer=answer, device_type=device_type

    ))

    session.commit()

    session.close()

returnf"""

    <!DOCTYPE html>

    <html>

    <head>

        <title>Network AI Assistant</title>

        <style>

            body {{

                font-family: Arial, sans-serif;

                margin: 40px;

                max-width: 800px;

            }}

            .question {{

                background: #e3f2fd;

                padding: 15px;

                margin: 10px 0;

                border-radius: 5px;

            }}

            .answer {{

                background: #f5f5f5;

                padding: 20px;

```

  

_Chapter 7_

  

207

  

`margin: 10px 0; border-radius: 5px; white-space: pre-wrap; }} .back {{ margin: 20px 0; }} a {{ color: #007cba; text-decoration: none; }} </style> </head> <body> <h1>` 🤖 `Network AI Assistant</h1> <div class="question"> <strong> Your Question ({device_type}): </strong> <br> {question} </div> <div class="answer"> <strong>AI Answer:</strong><br> {answer} </div> <div class="back">` <a href="/">← Ask Another Question</a> | `<a href="/history">View History</a> </div> </body> </html> """`

  

```

# Keep existing API endpoints

@app.post("/ask")

defask_question(request: QuestionRequest):

    answer = get_ai_answer(request.question, request.device_type)

```

  

_Building AI LLM Application Backends_

  

208

  

```

    session = Session()

    session.add(Question(

        question=request.question,

        answer=answer,

        device_type=request.device_type

    ))

    session.commit()

    session.close()

return {"answer": answer, "device_type": request.device_type}

@app.get("/history")

defget_history():

    session = Session()

    questions = session.query(Question).order_by(

        Question.timestamp.desc()).limit(10).all()

    session.close()

return [

        {

"question": q.question,

"answer": q.answer,

"device_type": q.device_type,

"time": q.timestamp

        } for q in questions

    ]

@app.get("/devices")

defsupported_devices():

return {

"supported_devices": [

"cisco", "juniper", "arista", "palo alto", "generic"

        ],

"usage": "Include device_type in your JSON request for

                 device-specific help"

    }

if __name__ == "__main__":

```

  

_Chapter 7_

  

209

  

```

import uvicorn

    uvicorn.run(app, port=8000)

```

  

### **How it works…**

  

We explained the main changes while specifying the relevant code block in the previous section to keep things relevant. Although simple, this recipe packs a lot into a single script, including AI LLM queries, HTML code, API endpoints, and database persistence. That is why this recipe has been placed toward the end of this chapter: we’d already built up other elements besides the HTML interface.

  

### **There’s more…**

  

There was no JavaScript in the script; however, we can add some in the `<script>` block. For example, to make form submission more slick, we can add the following code, which will change the button text to `Thinking...` and disable the submit button while AI is processing the request:

  

```

<script>

```

  

```

document.querySelector('form').onsubmit = function() {

```

  

```

document.querySelector('button').innerHTML = 'Thinking...';

```

  

```

document.querySelector('button').disabled = true;

```

  

```

};

</script>

```

  

### **See also**

  

- _FastAPI Custom Response – HTML, Stream, File, others_ : `https://fastapi.tiangolo.com/ advanced/custom-response/`

  

- _<form>: The Form element_ : `https://developer.mozilla.org/en-US/docs/Web/HTML/ Reference/Elements/form`

  

## **7.5 Docker deployment**

  

In this recipe, we will package our Network AI Assistant app into a Docker container so that it can be run anywhere.

  

_Building AI LLM Application Backends_

  

210

  

### **Getting ready**

  

Please make sure that you’ve completed the _Simple web interface_ recipe and Docker is installed.

  

### **How to do it…**

  

1. Create a Dockerfile named `dockerfile` . Note that we used `main_v4.py` , but you can use an earlier version as well:

  

```

FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY main_v4.py .

EXPOSE8000

CMD ["python", "main_v4.py"]

```

  

2. For the FastAPI file, we only listened to `localhost` in our `uvicorn` configuration. We will need to change that so that we’re listening on all interfaces:

  

```

if __name__ == "__main__":

import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)

```

  

3. Create a `requirements.txt` file:

  

```

fastapi

uvicorn

openai

sqlalchemy

python-multipart

```

  

4. Build the container image by running `docker build -t <name> .` in the terminal:

  

```

$ docker build -t network-ai .

[+] Building 6.2s (7/9)

docker:default

 => => resolve docker.io/library/python:3.11-slim@sha256:0ce77749ac

0.0s

```

  

```

 => => sha256:f3bfd8e9386c2a97d52a0f28a4cc8db81b034 5.37kB / 5.37kB

0.0s

```

  

_Chapter 7_

  

211

  

```

 => => sha256:59e22667830bf04fb35e15ed9c70023e9d1 28.23MB / 28.23MB

0.4s

```

  

- `=> => sha256:abd846fa1cdb2ae1ef7731213cd4f0c40b05f 3.51MB / 3.51MB 0.1s`

  

```

 => => sha256:b7b61708209ad8f9b9a11c61dc9df90f74c 16.21MB / 16.21MB

0.3s

```

  

5. Run containers with OPENAI_API_KEY.

  

   - `$ docker run -p 8000:8000 -e OPENAI_API_KEY="your-openai-api-key" network-ai`

  

```

/app/main_v4.py:14: MovedIn20Warning: The ``declarative_base()``

function is now available as sqlalchemy.orm.declarative_base().

(deprecated since: 2.0) (Background on SQLAlchemy 2.0 at: https://

sqlalche.me/e/b8d9)

```

  

```

  Base = declarative_base()

```

  

```

INFO:     Started server process [1]

INFO:     Waiting for application startup.

INFO:     Application startup complete.

INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to

quit)

```

  

6. We should see the same web interface at port `8000` .

  
  
  

_Figure 7.5: Web interface from the container_

  

_Building AI LLM Application Backends_

  

212

  

7. Test the containerized Network AI Assistant application:

  

```

$ curl -X POST "http://127.0.0.1:8000/ask"   -H "Content-Type:

application/json"   -d '{"question": "How do I configure VLANs on a

Cisco switch?", "device_type": "cisco"}'

{"answer":"To configure VLANs on a Cisco switch, follow these

steps:\n\n1. Enter global configuration mode:\n```\nenable\

nconfigure terminal\n```\n\n2. Create VLANs and assign names to

them:\n```\nvlan <vlan_id>\nname <vlan_name>\n```\n\n3. Assign

interfaces to VLANs:\n```\ninterface <interface_type> <interface_

number>\nswitchport mode access\nswitchport access vlan <vlan_id>\

n```\n\n4. Exit configuration mode and save the configuration:\n```\

nend\nwr\n```\n\n5. Verify the VLAN configuration:\n```\nshow vlan\

nshow interfaces switchport\n```","device_type":"cisco"}

```

  

### **How it works…**

  

The following is a pretty standard workflow for building Docker containers:

  

1. Create a Dockerfile.

  

2. Create a `requirements.txt` file.

  

3. Build and run the container, adding additional environment variables as required.

  

4. Test the containerized application.

  

Once we’ve containerized our application, we can move it to lots of different providers, such as DigitalOcean, AWS, or Azure.

  

### **There’s more…**

  

See the _Technical requirements_ section of _Chapter 4_ to learn how to install Docker.

  

_Chapter 7_

  

213

  

## **Summary**

  

In this chapter, we built a complete AI-powered backend with a simple web interface that our frontend team can use. As any developer will tell you, the work is never done. We are constantly adding more data, business logic, and demand to the application. It also seems like every week, there is a new JavaScript frontend library that is the “hottest new thing” that puts additional requirements on the backend application.

  

Python is known to have a robust ecosystem of backend web frameworks, including Django and FastAPI. As a mature ecosystem, there are constant features to be added, bugs to be fixed, and more ways we can optimize our code. This chapter serves as an introduction to the FastAPI framework, but we should be prepared for a steeper learning curve before we deploy our AI application into production.

  

In the next chapter, we will go back to the core functionalities and build a Network Copilot application.

  
  
  

<!-- Start of picture text -->

Get This Book’s PDF Version and<br>Exclusive Extras<br>Scan the QR code (or go to  packtpub.com/unlock ). Search for this<br>book by name, confirm the edition, and then follow the steps on<br>the page.<br>Note: Keep your invoice handy. Purchases made directly from Packt<br>don’t require an invoice.<br><!-- End of picture text -->