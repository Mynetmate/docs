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