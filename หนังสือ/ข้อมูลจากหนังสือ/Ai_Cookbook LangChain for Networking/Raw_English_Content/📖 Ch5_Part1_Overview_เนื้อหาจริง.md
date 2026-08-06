5
LangChain for Networking
Tasks
In previous chapters, we saw how we can use an AI Large Language Model (LLM) as a newly hired
network engineer colleague. They are capable of helping us out with various network engineering
tasks if we give them enough directions via prompts. This chapter is all about the open source
tool LangChain, and how it can be used to help us with our daily network engineering work.
We can think of LangChain as LEGO blocks for AI that we can use to snap other AI tools together
to solve problems. It simplifies the process of connecting LLMs with external data sources, APIs,
and user interfaces. The name LangChain comes from the modularity it promotes to break down
complex tasks into “chains” of smaller steps. Instead of one giant AI LLM trying to solve all problems,
LangChain connects smaller AI “specialists” together.
LangChain can be used to pull up-to-date knowledge from our own data to augment the result.
It can also be used as an agent and a tool to combine the tools we have built, as well as build
pipelines of different models. All of these features will come in handy when it comes to helping
us solve network engineering problems.
In this chapter, we will cover the following recipes:
• Installing and setting up LangChain
• Creating a network configuration analyzer
• Using prompt templates for reusability
• Combining models with simple chains
• Using agents with LangChain

It is worth knowing the origin of LangChain before we start using the tool to put this new approach
into perspective.
What is LangChain all about?
LangChain was created by Harrison Chase in 2022. While working as a Machine Learning (ML)
engineer, he saw how powerful LLMs such as GPT-3 can be, but also that they have their limitations
in that they cannot access up-to-date or proprietary data, interact with external tools, or define
pipelines of workflows. Chase developed LangChain as an open source framework that would
combine LLMs with other components easily and reliably. He called it LangChain by combining
the words “language” and “chains” to illustrate the tool’s objective of combining steps.
LangChain is both an open source project and a business. The business model is similar to Red
Hat and Elastic; the library is free to use, and the company supports development with enterprise
support. This is great for us developers since it is free to learn and experiment with an active
community of support. Once we are ready to put it into production, we can choose to purchase
enterprise support if needed.
Today, LangChain is a core part of the AI developer ecosystem with a vibrant community, third-party
integrations, and funding to accelerate its development.
Technical requirements
Please refer to Chapter 1 and Chapter 4 for setting up Docker containers for our AI models. My
recommendation is to create a dedicated folder, for example, ch05:
$ mkdir ch05 && cd ch05
Use the following Docker Compose file to launch the Docker containers:
networks:
ollama:
services:
ollama:
image: ollama/ollama
networks:
- ollama
volumes:
- ./data/ollama:/root/.ollama
Chapter 5 125
ports:
- 11434:11434
restart: unless-stopped
# Linux-specific resource limits
deploy:
resources:
limits:
memory: 14G
reservations:
memory: 8G
ollama-webui:
image: ghcr.io/ollama-webui/ollama-webui:main
volumes:
- ./data/ollama-webui:/app/backend/data
depends_on:
- ollama
ports:
- 3002:8080
environment:
- 'OLLAMA_API_BASE_URL=http://ollama:11434/api'
extra_hosts:
- host.docker.internal:host-gateway
networks:
- ollama
restart: unless-stopped
We can launch the containers via docker-compose up -d, where the Docker Compose file resides,
and verify the containers are running with docker ps:
$ sudo docker-compose up -d
$ docker ps
CONTAINER ID IMAGE COMMAND
CREATED STATUS PORTS
NAMES
6fbd6fba65a0 ghcr.io/ollama-webui/ollama-webui:main "bash start.sh"
4 hours ago Up 4 hours 0.0.0.0:3002->8080/tcp, [::]:3002->8080/tcp
ch05_ollama-webui_1
f9e54b792eb4 ollama/ollama "/bin/ollama


serve" 4 hours ago Up 4 hours 0.0.0.0:11434->11434/tcp, [::]:11434-
>11434/tcp ch05_ollama_1
We should also create a Python virtual environment and install the following packages:
$ pip install langchain==0.1.0 langchain-community requests
The recipes in this chapter tend to be more involved with mock data, outputs, and the scripts
themselves. Therefore, I would recommend making subfolders for each of the recipes, but this
is optional.
