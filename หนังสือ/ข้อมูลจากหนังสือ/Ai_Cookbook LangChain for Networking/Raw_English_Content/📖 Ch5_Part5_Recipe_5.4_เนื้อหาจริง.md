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
