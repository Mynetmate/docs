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
