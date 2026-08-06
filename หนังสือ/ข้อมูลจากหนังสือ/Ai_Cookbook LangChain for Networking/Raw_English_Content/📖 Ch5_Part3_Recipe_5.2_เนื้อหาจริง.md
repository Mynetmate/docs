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

