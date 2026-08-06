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

5.2 Creating a network configuration analyzer
In this recipe, we want to create a network configuration and analyze the network configuration
data to uncover potential issues using LangChain.
Getting ready
Please make sure the previous recipe has been completed.
How to do it…
1. We prepared three configurations in the mock_data folder: router_config, switch_config,
and problem_config.
2. We created the following script to loop through the configuration for analysis:
from langchain_community.llms import Ollama
def load_config(filename):
"""Load a mock configuration file"""
with open(f"mock_data/{filename}", 'r') as f:
return f.read()
def analyze_config(config_text, config_name):
"""Analyze network config using Docker Ollama"""
llm = Ollama(
model="llama2:7b-chat",
base_url="http://localhost:11434"
)
prompt = f"""
Analyze this network configuration:
{config_text}
Please tell me:
3. What type of device is this (router/switch/firewall)?
4. What is its main function?
5. Any obvious issues or concerns?
Chapter 5 131
Keep your response clear and practical for a network engineer.
"""
return llm.invoke(prompt)
def main():
"""Analyze all mock configurations"""
configs = [
"router_config.txt",
"switch_config.txt",
"problem_config.txt"
]
print("AI Analysis of Mock Network Configurations")
print("=" * 50)
for config_file in configs:
print(f"\n Analyzing {config_file}")
print("-" * 30)
config_text = load_config(config_file)
analysis = analyze_config(config_text, config_file)
print(analysis)
# Save results
output_file = f"outputs/{config_file.replace(
'.txt', '_analysis.txt'
)}"
with open(output_file, 'w') as f:
f.write(f"Analysis of {config_file}\n")
f.write("=" * 30 + "\n")
f.write(analysis)
print(f"💾 Saved analysis to {output_file}")
if __name__ == "__main__":
main()

3. After execution, the results are saved in the outputs folder. Here is a sample of issues
identified for the router_config.txt file:
4. Obvious issues or concerns:
a. Missing a default gateway: The `no shutdown` statement in the
`interface GigabitEthernet0/1` configuration implies that there is
no default gateway configured for the LAN network. This could cause
connectivity issues for devices on the LAN network when they try to
access the WAN network or other networks beyond the router. It's
recommended to add a default gateway to ensure proper routing and
connectivity.
b. Incomplete OSPF configuration: The `network 192.168.1.0 0.0.0.255
area 0` statement only defines a single network range, which may not
be sufficient for a larger network. A complete OSPF configuration
should include multiple networks, areas, and routers to ensure
proper routing and scalability.
c. Inconsistent IP addressing: The `ip address` statements have
different IP addresses (203.0.113.1 vs 192.168.1.1) for the WAN and
LAN interfaces, respectively. It's best practice to use consistent
IP addressing across all interfaces to avoid any potential issues
with IP address overlap or conflicts.
5. There are several issues being identified by the analysis:
6. There are a few obvious issues or concerns with this
configuration:
* The use of "cisco123" as the `enable` password is quite
weak and could be easily guessed by an attacker. It's important to
use strong, unique passwords for all device management interfaces to
prevent unauthorized access.
* The `access-list` configuration permits all incoming
traffic on any port, which may not be desirable in a production
network. It would be more secure to restrict incoming traffic to
only trusted sources and ports.
* The lack of encryption or authentication mechanisms for
the Telnet connection is also a concern. It's important to protect
remote access connections with features like SSL/TLS encryption or
mutual authentication to prevent eavesdropping and man-in-the-middle
attacks.
Chapter 5 133
How it works…
In the script, we use the following lines to specify the model and URL for the LLM:
llm = Ollama(
model="llama2:7b-chat",
base_url="http://localhost:11434"
)
We use the following lines to specify the prompt; {config_text} is where we substitute the
content of the config file:
prompt = f"""
Analyze this network configuration:
{config_text}
Please tell me:
1. What type of device is this (router/switch/firewall)?
2. What is its main function?
3. Any obvious issues or concerns?
Keep your response clear and practical for a network engineer.
"""
In the function, we can invoke the LLM with the prompt:
return llm.invoke(prompt)
The main function loops through the data files and calls the analyze_config() function for each
of the config files.
There’s more…
For a more personalized experience, do the following:
• Use your own configuration files instead of mock data
• Test with different questions in the prompt
• Test with different vendor syntax, such as Juniper and Nokia

5.3 Using prompt templates for reusability
In the previous recipe, we used a raw string to create quick one-off questions. A key concept when
it comes to evolving our AI usage from basic to more sophisticated usage is reusability. LangChain
provides the PromptTemplate object to provide a consistent structure and a reusable prompt.
PromptTemplate provides the following advantages:
• It is reusable; we can write once and use it everywhere instead of needing to write prompts
every time
• It is more scalable as consistency is key when working in teams
• It provides a professional, consistent structure for the prompt
• It provides validation and prevents errors
Let’s look at a prompt template example in this recipe.
Getting ready
Please make sure that you have completed the first recipe in this chapter.
How to do it…
1. We created mock data under the mock_data folder with security_issue.txt.
2. We created the following script for testing the data with multiple templates:
from langchain.prompts import PromptTemplate
from langchain_community.llms import Ollama
def create_security_template():
"""Template for security analysis"""
template = """
You are a network security expert analyzing a configuration.
CONFIGURATION:
{config}
SECURITY ANALYSIS:
Please identify:
3. High-risk security issues
Chapter 5 135
4. Medium-risk concerns
5. Best practice recommendations
Rate each issue as HIGH, MEDIUM, or LOW risk.
Be specific about what needs to be fixed.
ANALYSIS:
"""
return PromptTemplate(
template=template,
input_variables=["config"]
)
def create_basic_overview_template():
"""Template for basic config overview"""
template = """
You are a senior network engineer reviewing this configuration.
DEVICE CONFIG:
{config}
OVERVIEW REQUEST:
Provide a brief overview including:
6. Device type and purpose
7. Key configuration highlights
8. One potential improvement
Keep it concise and practical.
OVERVIEW:
"""
return PromptTemplate(
template=template,
input_variables=["config"]
)
def test_templates():
"""Test the templates"""
# Connect to Docker Ollama
llm = Ollama(
model="llama2:7b-chat",
base_url="http://localhost:11434"
)
# Load a test config
with open("mock_data/security_issue.txt", 'r') as f:
config = f.read()
# Test security template
print("Testing Security Template")
print("=" * 40)
security_template = create_security_template()
security_prompt = security_template.format(config=config)
security_result = llm.invoke(security_prompt)
print(security_result)
print("\n" + "=" * 40)
# Test overview template
print("Testing Overview Template")
print("=" * 40)
overview_template = create_basic_overview_template()
overview_prompt = overview_template.format(config=config)
overview_result = llm.invoke(overview_prompt)
print(overview_result)
if __name__ == "__main__":
test_templates()
Chapter 5 137
3. After running the script, we should see the results of the analysis:
$ python Recipe_5_3_Prompt_Template.py
Testing Security Template
========================================
As a network security expert, I have analyzed the configuration
provided and identified potential security issues. Here are my
findings:
4. High-risk security issues:
a. Enable password 'cisco' is a known vulnerability (CVE-2018-19645)
that can be easily guessed or brute-forced. Recommend changing the
password to a more complex and unique one. Risk level: HIGH
b. The 'telnet' password for login is a well-known default password.
Change it to a stronger password to prevent unauthorized access.
Risk level: HIGH
<output skipped>
To address these issues, I recommend the following actions:
5. Change the 'cisco' password to a unique and complex password.
6. Update the login password to a stronger one.
7. Implement MFA for all login credentials.
8. Regularly review and update the access list to ensure that only
authorized IP addresses have access to the network.
9. Change the SNMP community string to a more secure one.
By addressing these security issues, you can significantly reduce
the risk of unauthorized access or exploitation of your network
infrastructure.
========================================
Testing Overview Template
========================================
Overview of UnsafeSwitch Configuration:
Device Type and Purpose: The UnsafeSwitch is a Cisco router used for
managing network traffic and providing secure access to the network.

Key Configuration Highlights:
Hostname and Password: The hostname is set to "UnsafeSwitch," and
the password is set to "cisco." This ensures that only authorized
personnel can access the device.
<output skipped>
How it works…
The template configuration might appear similar on the surface, but the structure provided is
the key difference:
return PromptTemplate(
template=template,
input_variables=["config"]
)
…
security_template = create_security_template()
security_prompt = security_template.format(config=config)
security_result = llm.invoke(security_prompt)
…
overview_template = create_basic_overview_template()
overview_prompt = overview_template.format(config=config)
overview_result = llm.invoke(overview_prompt)
The structure’s consistency is why prompt templates are recommended after experimenting
with one-off prompts.
This is also the first time we are manually “chaining” multiple steps together.
There’s more…
Here are some template best practices:
• Be specific: For example, check for weak passwords
• Set the context: For example, security expert, senior engineer
• Define the output: For example, keep it concise and practical
Chapter 5 139
See also
Please compare the structure with Recipe 5.2 to see the differences. Prompt templates provide a
consistent structure and reusability for our workflow.
5.4 Combining models with simple chains
As we mentioned earlier in the chapter, LangChain was one of the first open source projects with
the aim of combining multiple AI operations together to create a workflow. This is similar to real-
world troubleshooting; many times, we require a team of specialists to collaborate on a problem.
We will now see how we can use LangChain’s SequentialChain object to combine multiple AI
models, such as combining local Ollama and OpenAI models for analysis.
Getting ready
Please make sure that the steps given in the first recipe of this chapter were followed. We will need
to install an additional package, langchain-openai, as well as exporting our OPENAI_API_KEY
to the environment:
$ pip install langchain-openai
$ export OPENAI_API_KEY="your-openai-api-key"
How to do it…
1. In this recipe, we will embed the test data directly within the script:
from langchain_core.prompts import PromptTemplate
from langchain_core.
runnables import RunnablePassthrough, RunnableLambda
from langchain_ollama import OllamaLLM
from langchain_openai import ChatOpenAI
import os
def create_mixed_analysis_chain():
"""Chain using both local Ollama and OpenAI models with
modern LCEL patterns"""
# Local model for basic analysis (private, fast, free)
local_llm = OllamaLLM(
model="llama2:7b-chat",
base_url="http://localhost:11434"

)
# OpenAI model for complex reasoning (powerful, costs money)
openai_llm = ChatOpenAI(
model="gpt-3.5-turbo",
temperature=0.1,
api_key=os.getenv("OPENAI_API_KEY")
)
# Step 1: Basic analysis with local model
basic_analysis_template = PromptTemplate(
input_variables=["config"],
template="""
Analyze this network configuration and extract key facts:
{config}
Provide:
1. Device type and hostname
<skip>
BASIC ANALYSIS:
"""
)
# Step 2: Advanced reasoning with OpenAI
advanced_analysis_template = PromptTemplate(
input_variables=["config", "basic_analysis"],
template="""
You are a senior network architect. Based on this basic analysis
and configuration, provide strategic recommendations:
BASIC ANALYSIS:
{basic_analysis}
ORIGINAL CONFIG:
{config}
Chapter 5 141
Provide advanced analysis:
1. Architecture assessment and design patterns
<skip>
ADVANCED ANALYSIS:
"""
)
# Step 3: Combined synthesis with OpenAI
synthesis_template = PromptTemplate(
input_variables=[
"config",
"basic_analysis",
"advanced_analysis"
],
template="""
You are a Chief <skip>:
TECHNICAL FINDINGS:
{basic_analysis}
STRATEGIC RECOMMENDATIONS:
{advanced_analysis}
ORIGINAL CONFIGURATION:
{config}
Create a COMBINED EXECUTIVE SUMMARY that includes:
1. **Current State Assessment**: Merge technical facts with
strategic context
<skip>
"""
)
# Create the basic analysis chain using LCEL

basic_chain = basic_analysis_template | local_llm
# Function to prepare input for advanced analysis
def prepare_advanced_input(input_dict):
"""Prepare input for the advanced analysis chain"""
return {
"config": input_dict["config"],
"basic_analysis": input_dict["basic_analysis"]
}
# Function to prepare input for synthesis
def prepare_synthesis_input(input_dict):
"""Prepare input for the synthesis chain"""
advanced_content = input_dict["advanced_analysis"]
if hasattr(advanced_content, 'content'):
advanced_text = advanced_content.content
else:
advanced_text = str(advanced_content)
return {
"config": input_dict["config"],
"basic_analysis": input_dict["basic_analysis"],
"advanced_analysis": advanced_text
}
# Create the advanced analysis chain using LCEL
advanced_chain = advanced_analysis_template | openai_llm
# Create the synthesis chain using LCEL
synthesis_chain = synthesis_template | openai_llm
# Create the complete mixed chain using LCEL
mixed_chain = (
RunnablePassthrough.assign(
basic_analysis=basic_chain
)
| RunnablePassthrough.assign(
Chapter 5 143
advanced_analysis=RunnableLambda(prepare_advanced_
input) | advanced_chain
)
| RunnablePassthrough.assign(
combined_analysis=RunnableLambda(
prepare_synthesis_input) | synthesis_chain
)
)
return mixed_chain
# Test the mixed chain
def test_mixed_models():
"""Test chain with both local and OpenAI models"""
if not os.getenv("OPENAI_API_KEY"):
print(
"OpenAI API key not found. Set OPENAI_API_KEY
environment variable."
)
return
# Load test config
test_config = """
hostname CoreRouter-HQ
<skip>
access-list 100 permit tcp 10.0.1.0 0.0.0.255 any eq 443
access-list 100 deny ip any any log
"""
print(" Testing Mixed Model Chain (Local + OpenAI + Synthesis)")
print("=" * 70)
try:
chain = create_mixed_analysis_chain()
results = chain.invoke({"config": test_config})

print("\n LOCAL MODEL ANALYSIS:")
print("-" * 30)
print(results["basic_analysis"])
print("\n OPENAI ADVANCED ANALYSIS:")
print("-" * 30)
# Extract content from ChatOpenAI response object
advanced_content = results["advanced_analysis"]
if hasattr(advanced_content, 'content'):
print(advanced_content.content)
else:
print(advanced_content)
print("\n COMBINED EXECUTIVE SUMMARY:")
print("-" * 30)
# Extract content from synthesis response
combined_content = results["combined_analysis"]
if hasattr(combined_content, 'content'):
print(combined_content.content)
else:
print(combined_content)
except Exception as e:
print(f" Mixed chain failed: {e}")
import traceback
traceback.print_exc()
if __name__ == "__main__":
test_mixed_models()
2. The results show a combination of local and remote LLMs:
$ python Recipe_5_4_chaining_models.py
Testing Mixed Model Chain (Local + OpenAI + Synthesis)
===================================================================
===
LOCAL MODEL ANALYSIS:
Chapter 5 145
------------------------------
1. Device type and hostname: The device is a CoreRouter-HQ, which
suggests it is a network router or core switch.
<output skipped>
OPENAI ADVANCED ANALYSIS:
------------------------------
1. Architecture assessment and design patterns:
- The current configuration follows a basic router design
pattern with two interfaces for internet and LAN connections. To
enhance the architecture, consider implementing redundancy with
a secondary router for failover, implementing VLANs for better
network segmentation, and implementing Quality of Service (QoS) for
prioritizing traffic.
<output skipped>
COMBINED EXECUTIVE SUMMARY:
------------------------------
**Current State Assessment:**
<skiped>
How it works…
Here is how the script works:
• The basic_analysis_template template is a prompt template that runs through local
LLM analysis
• The advanced_analysis_template template is a prompt template that runs through
OpenAI for higher-level recommendations
• The synthesis_template template is a combination of both
In the script, the advanced template receives both the original config and the basic analysis from
the local LLM:
def prepare_advanced_input(input_dict):
return {
"config": input_dict["config"],
"basic_analysis": input_dict["basic_analysis"]
}

The prepare_synthesis_input() function extracts text from the OpenAI response and provides
config, basic, and advanced analysis to the synthesis template:
def prepare_synthesis_input(input_dict):
# Handle OpenAI response object format
advanced_content = input_dict["advanced_analysis"]
if hasattr(advanced_content, 'content'):
advanced_text = advanced_content.content
else:
advanced_text = str(advanced_content)
return {
"config": input_dict["config"],
"basic_analysis": input_dict["basic_analysis"],
"advanced_analysis": advanced_text
}
Note that in the script, we are using the new LangChain Expression Language (LCEL). In the
old sequential syntax, we would define separate chains, then use SequentialChain to combine
the two:
# Sequential, verbose, harder to modify
chain1 = LLMChain(llm=local_llm, prompt=template1, output_key="step1")
chain2 = LLMChain(llm=openai_llm, prompt=template2, output_key="step2")
sequential_chain = SequentialChain(chains=[chain1, chain2], ...)
In the new LCEL syntax (https://python.langchain.com/docs/concepts/lcel/), we use the |
operator to specify the template, fill it with inputs, then pass it to the LLM:
basic_chain = basic_analysis_template | local_llm
advanced_chain = advanced_analysis_template | openai_llm
Mixing models can be a great way to save on costs by running a basic analysis with a local model
while using a higher-cost remote LLM for advanced analysis.
There’s more…
Mixing models can be a powerful chaining technique to leverage multiple models. The latest
development in this area is the Model Context Protocol (MCP) announced by Anthropic in November
2024. It is a new way for AI models to smartly route between different AI models. The
MCP approach is new but is gaining a lot of traction in the community.
Chapter 5 147
See also
Please reference the third recipe of this chapter, Using prompt templates for reusability, for prompt
template usage.
5.5 Using agents with LangChain
In this recipe, we will build a simple AI agent that can choose between tools and make a smart
decision on which one to use.
Getting ready
Please make sure the steps given in the first recipe are followed.
How to do it…
2025. We have the following router_config.txt file in the mock_data folder:
hostname TestRouter
interface eth0
ip address 192.168.1.1 255.255.255.0
no shutdown
interface eth1
ip address 10.0.1.1 255.255.255.0
switchport mode access
router ospf 1
network 192.168.1.0 0.0.0.255 area 0
2026. In the following script, simple_tools.py, we create two tools, find_ip_address() and
identify_device(). Then, we use langchain.tools.Tool to create simple tools to determine
which function to call based on the description:
from langchain.tools import Tool
import re
def find_ip_addresses(config_text):
"""Find IP addresses in config"""
ips = re.findall(
r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b',
config_text
)

return f"Found IP addresses: {', '.join(set(ips))}" if ips else
"No IPs found"
def identify_device(config_text):
"""Identify device type"""
if "switchport" in config_text.lower():
return "Device type: Switch"
elif "router" in config_text.lower():
return "Device type: Router"
else:
return "Device type: Unknown network device"
def create_tools():
"""Create simple tools for the agent"""
return [
Tool(
name="IP_Finder",
description="Find IP addresses in config",
func=find_ip_addresses
),
Tool(
name="Device_ID",
description="Identify device type",
func=identify_device
)
]
if __name__ == "__main__":
# Test tools directly
with open("mock_data/router_config.txt", 'r') as f:
config = f.read()
tools = create_tools()
for tool in tools:
print(f"{tool.name}: {tool.func(config)}")
Chapter 5 149
3. We will create the following agent file, basic_agent.py:
from langchain.agents import initialize_agent, AgentType
from langchain_community.llms import Ollama
from simple_tools import create_tools
class SimpleAgent:
"""Simple interactive network agent"""
def __init__(self):
self.llm = Ollama(
model="llama2:7b-chat",
base_url=http://localhost:11434
)
self.tools = create_tools()
self.agent = initialize_agent(
tools=self.tools,
llm=self.llm,
agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION,
verbose=True,
max_iterations=2
)
def analyze(self, config, question):
"""Analyze config with agent"""
prompt = f"Config: {config}\nQuestion: {question}\nUse
available tools to help answer."
return self.agent.invoke(prompt)
if __name__ == "__main__":
# Load config
with open("mock_data/router_config.txt", 'r') as f:
config = f.read()
agent = SimpleAgent()
print("Interactive Network Agent")
print("Available tools: IP_Finder, Device_ID")

print("Type 'quit' to exit\n")
while True:
question = input("Ask about the config: ").strip()
if question.lower() == 'quit':
break
try:
result = agent.analyze(config, question)
print(f"Agent: {result}\n")
except Exception as e:
print(f"Error: {e}\n")
4. Here is an example of the interactive output:
$ python basic_agent.py
Interactive Network Agent
Available tools: IP_Finder, Device_ID
Type 'quit' to exit
Ask about the config: What type of device is this?
> Entering new AgentExecutor chain...
Action: IP_Finder
Action Input: Config text
After analyzing the config text, I can identify that the device is
a Cisco router. The `hostname` field indicates that this is a Cisco
device, and the `ip address` fields show that it is assigned an IP
address in the 192.168.1.0/24 subnet. Additionally, the `switchport
mode access` and `router ospf 1` directives suggest that this is a
routed network with OSPF enabled.
Chapter 5 151
How it works…
The magic happened in the basic_agent.py file with the LangChain agent framework, where
the agent picked the right tool for the job:
# In basic_agent.py
self.agent = initialize_agent(
tools=self.tools,
llm=self.llm,
agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, # ← This is key!
verbose=True,
max_iterations=2
)
In the simple_tools.py file, we use a description to identify the tools. The description is the
critical part that helps the agent know what it does:
# In simple_tools.py
Tool(name="IP_Finder", description="Find IP addresses in config",
func=find_ip_addresses),
Tool(name="Device_ID", description="Identify device type", func=identify_
device)
The intelligence is the LLM reasoning with keyword matching.
There’s more…
• LangChain agents: https://python.langchain.com/docs/how_to/#agents
• LLM-powered autonomous agents: https://lilianweng.github.io/posts/2023-06-
23-agent/

Summary
In this chapter, we went from being a What is LangChain? noob to building simple AI-powered
network tools with LangChain. We learned how to set up LangChain with local LLM containers,
learned how to use prompt templates, and then combined them to chain multiple models into
an operation. We also learned about building simple AI agents to automatically pick the right
tool from the questions we asked.
In the next chapter, we will start learning about a quick frontend tool we can use to prototype
our applications: Streamlit.