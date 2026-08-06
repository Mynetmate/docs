5.1 Installing and setting up LangChain
In this recipe, we will install and set up LangChain to work with the local Ollama instance.
Getting ready
Please make sure the steps in the Technical requirements section of this chapter have been completed
and the containers are running in the background. Let’s go ahead and download the llama2:7bchat
AI model. We’ll use the Ollama web UI to do this. If you’d prefer to use the CLI, feel free to
skip this step. Launch the web interface on http ://localhost:8080 or on the host’s public IP
on port 3002, and use the setup icon next to the model selection:
Figure 5.1: Ollama web UI settings
Choose Models in the left panel and type llama2:7b-chat in the window, then click on the green
download button:
Chapter 5 127
Figure 5.2: Downloading the model
We can also use the docker command to execute Ollama commands to pull down the model:
$ docker exec ch05_ollama_1 ollama pull llama2:7b-chat
pulling manifest
<output skipped>
verifying sha256 digest
writing manifest
success
We should be able to use curl to see the newly downloaded model:
$ curl http://localhost:11434/api/tags
{"models":[{"name":"llama2:7b-chat","model":"llama2:7bchat","
modified_at":"2025-07-27T22:48:08.83573767Z","si
ze":3826793677,"digest":"78e26419b4469263f75331927a00a0
284ef6544c1975b826b15abdaef17bb962","details":{"parent_
model":"","format":"gguf","family":"llama","families":["llama"],"parameter_
size":"7B","quantization_level":"Q4_0"}}]}
We are ready to proceed to the next step.
How to do it…
1. We will use the following Python script to test both the container and the model:
from langchain_community.llms import Ollama
import requests
def test_docker_connection():
"""Test if Docker Ollama is accessible"""
print("Testing Docker Ollama connection...")
try:
# Test direct API connection
response = requests.get("http://localhost:11434/api/tags")
if response.status_code == 200:
print("Docker Ollama API is accessible")
else:
print("Docker Ollama API not responding")
return False
# Test LangChain connection
llm = Ollama(
model="llama2:7b-chat",
base_url="http://localhost:11434"
)
ai_response = llm.invoke("What is OSPF in networking?")
print("LangChain successfully connected to Docker Ollama")
print(f"AI Response: {ai_response[:100]}...")
return True
except Exception as e:
print(f"Connection failed: {e}")
return False
if __name__ == "__main__":
if test_docker_connection():
print("\n Ready for networking AI!")
Chapter 5 129
else:
print("\n Check your Docker setup and try again.")
2. The result should look similar to the following output:
$ python Recipe_5_1_Test_Setup.py
Testing Docker Ollama connection...
Docker Ollama API is accessible
LangChain successfully connected to Docker Ollama
AI Response: OSPF (Open Shortest Path First) is a popular interior
gateway protocol (IGP) used in computer networ...
Ready for networking AI!
How it works…
There are two main parts to the script. The first uses the requests package to test the connectivity
to the container API:
response = requests.get("http://localhost:11434/api/tags")
The second tests the specific model by invoking a question:
llm = Ollama(
model="llama2:7b-chat",
base_url="http://localhost:11434"
)
ai_response = llm.invoke("What is OSPF in networking?")
From here on, we can proceed with more advanced functions.
There’s more…
• LangChain provides excellent documentation for tutorials at https://python.langchain.
com/docs/tutorials/. They also have a conceptual guide, https://python.langchain.
com/docs/concepts/chat_models/, for working with different models.

