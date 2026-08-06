8 Building a Network Co-Pilot 

When I started in the field as a junior network engineer, I had lots of questions, and I mean _lots of questions_ ! Many of the answers could be found in books and online resources, but it took so long to search through different sources and piece together the answer. Other times, the answer took the form of tribal knowledge, meaning I had to spend hours looking through the current configuration and ask more senior engineers, and then – maybe – get a decent answer. In short, I wish I’d had a network co-pilot who could help me filter out answers, understand the network, answer my questions at all hours, and just be my network best friend. 

Well, this chapter focuses on building such a pal. Think of a network co-pilot as your AI assistant that understands networking with the network data you are willing to supply. Instead of reading through countless documentation and CLI commands, you can have a conversation with your co-pilot: “Help me configure OSPF on this Cisco router,” or “Why does the interface error counter keep on incrementing at midnight, every other Wednesday?” 

A good network co-pilot does not replace a network engineer’s expertise; it amplifies it. It helps us work faster, catches mistakes, and makes suggestions to help us get more done. 

In this chapter, we will build the core components that make a network co-pilot work. We are not building a full production app (because that would take another book to do so!), but we will create the essential pieces that show you how it all fits together. 

Here are the recipes we will cover in this chapter: 

- Model selection and evaluation 

- Building the core AI engine 

- Network knowledge integration 

_Building a Network Co-Pilot_ 

216 

Some of the knowledge might be a review of what was covered in other chapters, and that is OK; we have chosen to emphasize the theme of _network co-pilot_ in this chapter, even if it echoes some of the elements we covered in earlier chapters. 

# **Technical requirements** 

Please create a new virtual environment and folder for this chapter, then install the following packages and export the OpenAI API key: 

```
$ pip install openai requests panda
```

```
$ export OPENAI_API_KEY="your-openai-api-key"
```

# **8.1 Model selection and evaluation** 

As we have seen in the book, choosing the right AI model is similar to picking the right tool for a job. We would not use a hammer to screw a nail, and we would not use a model optimized for image generation for our network engineering tasks. For this recipe, we will use three scripts to evaluate different models: 

- We will use a `1_test_models.py` script to supply a few test questions and run them against various models, in this case, `gpt-3.5-turbo` , `gpt-4o-mini` , and `gpt-4o` . We will save the results to a file named `model_test_results.json` . 

- In the second script, we will read the results and use OpenAI’s GPT-4o model to evaluate the responses. We will save the evaluation to a file named `response_evaluation.json` . 

- In the third script, we will read the evaluation file and average the scores across different answers. We will use the cost of the model to arrive at a final recommendation for which model to use. 

Ready? Let’s see how it all works. 

## **Getting ready** 

Please ensure the instructions in the _Technical requirements_ section have been followed. 

## **How to do it…** 

1. Let’s create a file for testing our models. The file should include questions we will test the model with, then use the same questions for various models: 

```
import openai
import json
```

_Chapter 8_ 

217 

```
import os
import time
# Simple test questions for networking
TEST_QUESTIONS = [
    {
"id": "ospf_config",
"question": "Configure OSPF area 0 on a Cisco router",
"category": "configuration"
    },
    {
"id": "bgp_troubleshoot",
"question": "BGP neighbor stuck in Idle state. What to
                    check?",
"category": "troubleshooting"
    },
    {
"id": "vlan_basic",
"question": "Create VLAN 100 named Sales on a switch",
"category": "configuration"
    }
]
deftest_model(model_name):
"""Test a model with networking questions"""
    client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    results = []
print(f"Testing {model_name}...")
for question in TEST_QUESTIONS:
try:
            response = client.chat.completions.create(
                model=model_name,
                messages=[{
"role": "user",
                    "content": question["question"]
```

_Building a Network Co-Pilot_ 

218 

`}], max_tokens=150, temperature=0.1 ) results.append({ "question_id": question["id"], "question": question["question"], "category": question["category"], "model": model_name, "response": response.choices[0].message.content }) print(f"` ✓ `{question['id']}") time.sleep(1)` _`# Rate limiting`_ `except Exception as e: print(f"` ✗ `{question['id']}: {e}") return results def main():` _`# Test these three models`_ `models = ["gpt-3.5-turbo", "gpt-4o-mini", "gpt-4o"] all_results = [] for model in models: results = test_model(model) all_results.extend(results)` _`# Save results`_ `with open('model_test_results.json', 'w') as f: json.dump(all_results, f, indent=2) print( f"\nDone! Saved {len(all_results)} responses to model_test_results.json"` 

_Chapter 8_ 

219 

```
)
if __name__ == "__main__":
    main()
```

2. When we execute the script, we will run through the questions model by model and save the results into a file: 

`$ python 1_test_models.py Testing gpt-3.5-turbo...` ✓ `ospf_config` ✓ `bgp_troubleshoot` ✓ `vlan_basic Testing gpt-4o-mini...` ✓ `ospf_config` ✓ `bgp_troubleshoot` ✓ `vlan_basic Testing gpt-4o...` ✓ `ospf_config` ✓ `bgp_troubleshoot` ✓ `vlan_basic Done! Saved 9 responses to model_test_results.json` 

3. We will use a second script to score the responses, then save the result: 

```
import json
import openai
import os
defload_results():
"""Load test results from previous script"""
withopen('model_test_results.json', 'r') as f:
return json.load(f)
defevaluate_response(result):
"""Use GPT-4o to score response quality"""
    client = openai.OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
```

_Building a Network Co-Pilot_ 

220 

```
    prompt = f"""Rate this network engineering response 1-10:
Question: {result['question']}
Response: {result['response']}
Score based on accuracy and usefulness.
Format: SCORE: X - brief reason"""
try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[{"role": "user", "content": prompt}],
            max_tokens=100,
            temperature=0.1
        )
        eval_text = response.choices[0].message.content
# Extract score
if"SCORE:"in eval_text:
            score_part =
                eval_text.split("SCORE:")[1].split("-")[0].strip()
            score = float(score_part)
            explanation =
                eval_text.split("-", 1)[1]
                .strip() if"-"in eval_text else""
return score, explanation
return5.0, "Could not parse score"
except Exception as e:
print(f"Error: {e}")
return5.0, "Evaluation failed"
defmain():
    results = load_results()
    evaluations = []
```

_Chapter 8_ 

221 

```
print("Evaluating responses...")
for result in results:
print(
f"Evaluating {result['model']} - {result[
            'question_id']}"
        )
        score, explanation = evaluate_response(result)
        evaluations.append({
"question_id": result["question_id"],
"model": result["model"],
"category": result["category"],
"score": score,
"explanation": explanation
        })
# Save evaluations
withopen('response_evaluations.json', 'w') as f:
        json.dump(evaluations, f, indent=2)
```

```
print(f"Done! Saved evaluations to response_evaluations.json")
```

```
if __name__ == "__main__":
    main()
```

4. The terminal output shows the progress of the evaluation and saving the results: 

```
$ python 2_evaluate_responses.py
Evaluating responses...
Evaluating gpt-3.5-turbo - ospf_config
Evaluating gpt-3.5-turbo - bgp_troubleshoot
Evaluating gpt-3.5-turbo - vlan_basic
Evaluating gpt-4o-mini - ospf_config
Evaluating gpt-4o-mini - bgp_troubleshoot
Evaluating gpt-4o-mini - vlan_basic
Evaluating gpt-4o - ospf_config
Evaluating gpt-4o - bgp_troubleshoot
```

_Building a Network Co-Pilot_ 

222 

```
Evaluating gpt-4o - vlan_basic
Done! Saved evaluations to response_evaluations.json
```

5. Finally, we will use a third script to return a final evaluation, balancing performance with cost: 

```
import json
defload_evaluations():
"""Load evaluation results"""
withopen('response_evaluations.json', 'r') as f:
return json.load(f)
defanalyze_results(evaluations):
"""Analyze model performance"""
print("MODEL PERFORMANCE ANALYSIS")
print("=" * 40)
# Group scores by model
    model_scores = {}
forevalin evaluations:
        model = eval['model']
if model notin model_scores:
            model_scores[model] = []
        model_scores[model].append(eval['score'])
# Calculate averages
print("\nOVERALL SCORES:")
    results = []
for model, scores in model_scores.items():
        avg_score = sum(scores) / len(scores)
        results.append((model, avg_score))
print(f"{model:<15} Average: {avg_score:.1f}/10")
# Sort by performance
    results.sort(key=lambda x: x[1], reverse=True)
# Performance by category
```

_Chapter 8_ 

223 

```
print(f"\nBY CATEGORY:")
    categories = {}
forevalin evaluations:
        cat = eval['category']
        model = eval['model']
if cat notin categories:
            categories[cat] = {}
if model notin categories[cat]:
            categories[cat][model] = []
        categories[cat][model].append(eval['score'])
```

```
for category, models in categories.items():
print(f"\n{category.title()}:")
for model, scores in models.items():
            avg = sum(scores) / len(scores)
print(f"  {model}: {avg:.1f}")
```

```
# Recommendation
    best_model = results[0][0]
    best_score = results[0][1]
```

```
print(f"\nRECOMMENDATION:")
print(f"{best_model} performs best with {best_score:.1f}/10")
```

```
# Cost consideration
    costs = {
'gpt-3.5-turbo': 0.002,
'gpt-4o-mini': 0.015,
'gpt-4o': 0.06
    }
print(f"\nCOST vs PERFORMANCE:")
for model, score in results:
if model in costs:
            cost = costs[model]
            value = score / (cost * 1000)
print(
```

_Building a Network Co-Pilot_ 

224 

```
f"{model}:
                Score {score:.1f} | ${cost:.3f}/1k tokens | Value:
{value:.0f}"
            )
return results[0][0]  # Return best model
defmain():
    evaluations = load_evaluations()
    best_model = analyze_results(evaluations)
# Save simple summary
    summary = {"best_model": best_model}
withopen('model_summary.json', 'w') as f:
        json.dump(summary, f, indent=2)
print(f"\nSummary saved to model_summary.json")
if __name__ == "__main__":
    main()
```

### Here is the final recommendation: 

```
$ python 3_analysis.py
MODEL PERFORMANCE ANALYSIS
========================================
```

```
OVERALL SCORES:
gpt-3.5-turbo   Average: 8.3/10
gpt-4o-mini     Average: 6.3/10
gpt-4o          Average: 7.0/10
BY CATEGORY:
Configuration:
  gpt-3.5-turbo: 8.5
  gpt-4o-mini: 6.0
  gpt-4o: 7.0
```

_Chapter 8_ 

225 

```
Troubleshooting:
  gpt-3.5-turbo: 8.0
  gpt-4o-mini: 7.0
  gpt-4o: 7.0
RECOMMENDATION:
gpt-3.5-turbo performs best with 8.3/10
COST vs PERFORMANCE:
gpt-3.5-turbo: Score 8.3 | $0.002/1k tokens | Value: 4
gpt-4o: Score 7.0 | $0.060/1k tokens | Value: 0
gpt-4o-mini: Score 6.3 | $0.015/1k tokens | Value: 0
Summary saved to model_summary.json
```

## **How it works…** 

The logic for evaluating the model is pretty straightforward. As with many tasks, the devil is in the details. For the first script, the number and quality of the questions are key. We should come up with as many relevant questions in each category as possible. For example, instead of `Configure OSPF on a router` , we can use `Configure OSPF area 0 on a Cisco router running IOS-XE with Loopback 0 as the router id` . 

The key to the second script is the prompt. In our case, we use a simple prompt and ask the AI model to score based on accuracy and usefulness. That might be good enough for now, but a better prompt could include instructions to use a different role, or use a different AI provider, such as Anthropic, to evaluate the responses from OpenAI, and so on. 

The third script centers on what we care about the most. The script assumes we want to strike a balance between cost and accuracy, but perhaps we want to put more weight on accuracy. This is where a judgment call needs to be made. 

## **There’s more…** 

Try out different models from other providers, such as Anthropic models (Claude Sonnet 4, Claude Opus 4, etc.) or use one of the local models we installed in _Chapter 4_ . 

_Building a Network Co-Pilot_ 

226 

## **See also** 

_Recipe 4.1_ from _Chapter 4_ : _Downloading Code Llama models_ 

# **8.2 Building the core AI engine** 

The AI engine is the brain of our co-pilot. It should take the user’s questions, classify them with their intent, have a context-aware conversation (network engineering), and generate helpful results. 

Here is what we will do in this recipe to build our core AI engine: 

1. Create mock data to include network device information, responses from the AI model, and context data so that we can test the script without actual network devices. 

2. Identify intent with keywords; for example, if `configure` is in the question, we will see it as belonging to the `configuration` category. 

3. Add a conversation-aware context for any conversation previously. 

4. Add networking context. 

5. Generate a response from the AI LLM. 

Let’s get started. 

## **Getting ready** 

We will use mock data in this recipe; however, understanding how we derived the response data was the topic of _Recipe 4.1_ . 

## **How to do it…** 

This script is long; therefore, we will only show the relevant configuration and explain. Please see the entire script from the GitHub repository created with this book ( `https://github.com/ PacktPublishing/AI-Networking-Cookbook-First-Edition` ): 

1. We will create three mock data files: `devices.json` , `network_context.json` , and `ai_ examples.json` . 

2. The simple AI engine has one class, `NetworkCopilot` . The `init()` function creates an empty list to store all the chat exchanges, tracks the device the user is working on, picks the model to use, and calls the `load_data()` function to load the mock data files: 

```
classNetworkCopilot:
def__init__(self, model_name="gpt-4o-mini"):
self.conversation = []
```

_Chapter 8_ 

227 

```
self.current_device = None
self.model_name = model_name
self.load_data()
```

3. We use the `get_intent()` function to use keywords in the question to “guess” the user’s intent: 

```
defget_intent(self, message):
"""Simple intent detection"""
        msg = message.lower()
if"configure"in msg or"create"in msg or"setup"in msg:
return"configuration"
elif"problem"in msg or"troubleshoot"in msg or"down"in
        msg or"not working"in msg:
return"troubleshooting"
elif"explain"in msg or"what is"in msg or"how does"in
        msg:
return"explanation"
return"general"
```

4. We use the `get_device_context()` function to load the device information from our mock data, such as the device type, device model, location, protocol, neighbors, and so on. These files are mocked for now, but can be from your production network: 

```
defget_device_context(self, message):
"""Get detailed device context"""
        msg = message.lower()
        context_parts = []
```

```
# Find mentioned device
```

```
for device_name, device_info inself.devices.items():
if device_name.lower() in msg:
self.current_device = device_name
                context_parts.append(f"Device: {device_name}")
                context_parts.append(
f"Type: {device_info['type']} ({device_info[
                    'model']})"
                )
                context_parts.append(
```

_Building a Network Co-Pilot_ 

228 

```
f"Location: {device_info['location']}"
                )
                context_parts.append(f"IP: {device_info['ip']}")
                context_parts.append(
f"Protocols: {', '.join(
device_info['protocols'])}"
                )
…
```

5. We use the `get_network_context()` function to retrieve relevant network information based on what the user is asking about. For example, we will add OSPF area information if they mention OSPF and add VLAN information if they mention VLAN: 

```
defget_network_context(self, message):
"""Get relevant network context based on message content"""
        msg = message.lower()
        context_parts = []
# Add topology info
        context_parts.append(
f"Network: {self.network_context['network_info'][
            'topology']}"
)
# Add protocol-specific context
if'ospf'in msg:
            context_parts.append(
f"OSPF: {self.network_context['network_info'][
                'routing_protocol']}"
            )
…
```

6. Now, we can load the relevant AI examples from before. If the user asks `"configure ospf on R1"` , we will look for examples in `configuration_examples` and look for **`ospf_basic`** : 

```
defget_ai_examples(self, message, intent):
    msg = message.lower()
    examples = []
# If we have examples for this intent
```

_Chapter 8_ 

229 

```
if intent inself.ai_examples
        intent_examples = self.ai_examples[intent + "_examples"]
for topic in ['ospf', 'bgp', 'vlan']:
if topic in msg: # If user mentions OSPF
for key, example in intent_examples.items():
if topic in key: # Find OSPF examples
                        examples.append(
f"Example approach: {example}"
                        )
break
…
```

7. Now, we add everything together and create our prompt for OpenAI in the `call_openaui()` function: 

```
defcall_openai(
self,
        message,
        intent,
        device_context,
        network_context
    ):
"""Call OpenAI API with rich context"""
import openai
        client = openai.OpenAI()
```

```
# Get relevant examples for context
```

```
        example_context = self.get_ai_examples(message, intent)
```

```
        system_prompt = """You are an expert network engineering
        assistant with deep knowledge of Cisco networking equipment
        and protocols. Provide clear, accurate technical guidance
        for network configuration, troubleshooting, and best
        practices. Use the provided network context
        and examples to give specific, actionable advice."""
```

```
…
```

_Building a Network Co-Pilot_ 

230 

### 8. Now, we can initialize the chat: 

```
defchat(self, message):
"""Main chat function with rich context"""
        intent = self.get_intent(message)
        device_context = self.get_device_context(message)
        network_context = self.get_network_context(message)
        response = self.call_openai(
            message,
            intent,
            device_context,
            network_context
        )
# Store conversation
self.conversation.append({
"user": message,
"response": response,
"device": self.current_device,
"intent": intent
        })
return response
```

9. When the script is executed by itself, we will initiate the `NetworkCopilot` class, grab the user input, and call the chat function: 

```
if __name__ == "__main__":
print("Network Co-Pilot (OpenAI-powered with Rich Context)")
print("Type 'quit' to exit")
print("=" * 50)
try:
        copilot = NetworkCopilot()
# Show available devices
print("\nAvailable devices:", ", ".join(
copilot.devices.keys())
```

_Chapter 8_ 

231 

```
        )
print(
"Try: 'Configure OSPF on R1' or 'Troubleshoot VLAN
issues on SW1'\n"
            )
whileTrue:
            user_input = input("You: ").strip()
if user_input.lower() == 'quit':
break
ifnot user_input:
continue
try:
                response = copilot.chat(user_input)
print(f"\nCo-Pilot: {response}")
                …
```

### 10. Let’s see an example in action: 

```
$ python network_ai_engine.py
Network Co-Pilot (OpenAI-powered with Rich Context)
Type 'quit' to exit
```

```
==================================================
```

```
Available devices: R1, R2, SW1, SW2
Try: 'Configure OSPF on R1' or 'Troubleshoot VLAN issues on SW1'
```

```
You: Configure OSPF on R1
```

```
Co-Pilot: To configure OSPF on your Cisco ISR4431 router (R1) in a
hub-and-spoke topology, you will need to follow these steps. The
configuration will enable OSPF in area 0, which is the backbone area
for your internal routing.
```

```
### Step-by-Step OSPF Configuration on R1
```

_Building a Network Co-Pilot_ 

232 

#### `1. **Access the Router:**` 

```
   Connect to your router via console or SSH.
```

`2. **Enter Global Configuration Mode:**` 

```
   ```bash
   enable
   configure terminal
   ```
```

`3. **Configure OSPF:**` 

```
   You will need to define the OSPF process and specify the router
ID. The router ID is typically the highest IP address on the router
or can be manually set.
```

```
   ```bash
```

```
   router ospf 1
```

```
   router-id 192.168.1.1  # Set the router ID to the IP of R1
   ```
```

`4. **Define OSPF Networks:**` 

```
   You need to specify the networks that will participate in OSPF.
Assuming R1 has interfaces connected to R2 and SW1, you will need to
include those networks. For example, if R2 is on the 192.168.2.0/24
network and SW1 is on the 192.168.3.0/24 network, you would
configure it as follows:
```

```
   ```bash
```

```
   network 192.168.1.0 0.0.0.255 area 0  # R1's own subnet
   network 192.168.2.0 0.0.0.255 area 0  # R2's subnet
   network 192.168.3.0 0.0.0.255 area 0  # SW1's subnet
   ```
```

```
   The `0.0.0.255` is the wildcard mask that specifies which bits of
the IP address are significant for OSP
```

```
[Working on: R1 - router at Main Office]
```

_Chapter 8_ 

233 

```
You: quit
Session ended. Total conversations: 1
```

## **How it works…** 

In summary, here is the flow of the script: 

1. The AI engine receives rich network context, such as device model, location, and protocol. 

2. The AI engine receives common troubleshooting examples and best practices. 

3. The AI engine integrates the AI example, perhaps from _Recipe 4.1_ . 

4. We enhance the response with user intent. 

5. We keep the conversation going. 

## **There’s more…** 

There are so many areas for enhancement. Here are some examples of what you could do: 

- Add more devices and network context 

- Include more configuration standards and templates 

- Continue to add more baseline data 

## **See also** 

_Recipe 4.1_ for model selection. 

# **8.3 Network knowledge integration** 

We built a pretty good co-pilot in the last recipe. It seems really smart, but one glaring area for improvement is that it does not know a lot about our network data. For example, in our mock data, our co-pilot knows about `SW2` 's IP, model, and protocols, but it does not know where the `GigabitEthernet0/1` interface connects to and `SW2` 's position in our network topology. 

In this recipe, we will start building integration points where our co-pilot can ingest our network information. 

## **Getting ready** 

Please complete _Recipe 8.2_ . 

_Building a Network Co-Pilot_ 

234 

## **How to do it…** 

1. Let’s begin by deciding what additional information we would like to include. How about a more detailed network topology relationship? We will create a file named `topology.json` under the `mock_data` folder that includes connections and dependencies: 

```
{
"connections": {
"R1": {
"GigabitEthernet0/0": {
"connects_to": "SW1",
"interface": "GigabitEthernet1/0/1",
"vlan": "trunk"
            },
"GigabitEthernet0/1": {
"connects_to": "R2",
"interface": "GigabitEthernet0/0",
"subnet": "10.1.1.0/30"
            },
"Serial0/0/0": {
"connects_to": "ISP",
"interface": "Serial0/0/0",
"subnet": "203.0.113.0/30"
            }
        },
        …
    },
"dependencies": {
"inter_vlan_routing": [
"R1",
"SW1"
        ],
        …
    }
}
```

_Chapter 8_ 

235 

2. We can also add configuration templates, which are similar to Jinja templates but more basic: 

```
{
"configurations": {
"ospf_interface": {
"template": "interface {interface}\n ip ospf {process_
id} area {area}\n ip ospf network point-to-point",
"variables": [
"interface",
"process_id",
"area"
            ],
"device_types": [
"router"
            ]
        },
"vlan_access_port": {
"template": "interface {interface}\n switchport
mode access\n switchport access vlan {vlan_id}\n spanning-
tree portfast",
"variables": [
"interface",
"vlan_id"
            ],
"device_types": [
"switch"
            ]
        }
…
```

3. Now, we are ready to enhance our network co-pilot with this additional information. We won’t show the code here, but we will load the additional information in the `init()` function. 

_Building a Network Co-Pilot_ 

236 

4. We will add a new function to create relationships between devices. Now, we know that 

   - `R1` connects to `SW1` via `GigabitEthernet0/0` : 

```
defget_device_relationships(self, device_name):
"""Get connected devices and interface mappings"""
if device_name notinself.topology['connections']:
return {}
        relationships = {}
        connections = self.topology['connections'][device_name]
for local_interface, connection_info in connections.items():
            remote_device = connection_info['connects_to']
            remote_interface = connection_info['interface']
            relationships[remote_device] = {
'local_interface': local_interface,
'remote_interface': remote_interface,
'connection_type': connection_info.get(
                    'vlan', connection_info.get('subnet', 'unknown')
                )
            }
return relationships
```

5. The dependencies should let us know when `R1` goes down, as it will impact internet access, as well as impacting `SW1` and `R2` : 

```
deffind_affected_devices(self, device_name):
"""Find devices that might be affected by changes"""
        affected = set()
# Direct connections
        relationships = self.get_device_relationships(device_name)
        affected.update(relationships.keys())
# Check service dependencies
for service, dependent_devices in (
self.topology['dependencies'].items()
```

_Chapter 8_ 

237 

```
):
if device_name in dependent_devices:
                affected.update(dependent_devices)
```

```
        affected.discard(device_name)  # Remove self
returnlist(affected)
```

6. We will add configuration templates: 

```
defget_configuration_template(self, config_type, device_type):
"""Get appropriate configuration template"""
        templates = self.templates['configurations']
```

```
for template_name, template_info in templates.items():
if (
config_type in template_name
                and device_type in template_info.get(
'device_types', [])
            ):
return template_info
returnNone
```

7. We will tie the two new functions together in the `analyze_network_impact()` function: 

```
defanalyze_network_impact(self, device_name, proposed_change):
"""Analyze potential impact of network changes"""
        analysis = {
'affected_devices': self.find_affected_devices(
device_name
            ),
'services_impacted': [],
'recommendations': []
        }
# Check service dependencies
for service, devices inself.topology['dependencies']
.items():
```

_Building a Network Co-Pilot_ 

238 

```
if device_name in devices:
                analysis['services_impacted'].append(service)
```

8. We also have a new `build_enhanced_context()` function to include relationships and templates: 

```
defbuild_enhanced_context(self, message, intent):
"""Build comprehensive context including relationships and
        templates"""
        context_parts = []
# Get basic device context
        device_context = self.get_device_context(message)
if device_context != "Standard network":
            context_parts.append(device_context)
```

```
# Add relationship information
ifself.current_device:
            relationships = self.get_device_relationships(
self.current_device
)
if relationships:
                connections = []
for remote_device, conn_info in (
relationships.items()
                ):
                    connections.append(
                        f"{remote_device} via {conn_info[
                        'local_interface']}"
)
                context_parts.append(
f"Connected to: {', '.join(connections)}"
)
```

```
# Add relevant templates
```

```
if intent == "configuration"andself.current_device:
            device_type = self.devices[self.current_device]['type']
```

_Chapter 8_ 

239 

```
            msg_lower = message.lower()
            …
```

9. With the enhanced context, our OpenAI call can now include impact analysis: 

```
defcall_openai_with_knowledge(
self,
        message,
        intent,
        enhanced_context
    ):
"""Call OpenAI with enhanced network knowledge"""
import openai
        client = openai.OpenAI()
```

```
# Analyze potential impact
        impact_analysis = {}
ifself.current_device and intent == "configuration":
            impact_analysis = self.analyze_network_impact(
self.current_device, message
            )
```

```
        system_prompt = """You are an expert network engineering
        assistant with deep knowledge of network topologies, device
        relationships, and configuration standards. Always consider
        the impact of changes on connected devices and dependent
        services. Use provided templates and follow security best
        practices. Provide specific, actionable guidance."""
```

```
        user_prompt = f"""Enhanced Network Context:
{enhanced_context}
```

```
User Intent: {intent}
User Message: {message}"""
```

```
if impact_analysis and impact_analysis['affected_devices']:
        user_prompt += f"""
```

_Building a Network Co-Pilot_ 

240 

```
Impact Analysis:
- Affected devices: {', '.join(impact_analysis['affected_devices'])}
- Services impacted: {', '.join(impact_analysis['services_impacted']
)}
- Recommendations: {'; '.join(impact_analysis['recommendations'])
}"""
user_prompt += (
"\n\nProvide specific networking guidance considering "
        "device relationships, templates, and potential impacts. "
    )
…
```

### 10. The chat can include device relationships: 

```
defchat(self, message):
"""Enhanced chat with network knowledge integration"""
        intent = self.get_intent(message)
        enhanced_context = self.build_enhanced_context(
            message,
            intent
        )
        response = self.call_openai_with_knowledge(
            message,
            intent,
            enhanced_context
        )
# Store conversation with enhanced metadata
self.conversation.append({
"user": message,
"response": response,
"device": self.current_device,
"intent": intent,
"relationships": self.get_device_relationships(
self.current_device) ifself.current_device else {}
        })
```

_Chapter 8_ 

241 

```
return response
```

### 11. The following code also includes device relationships: 

|<br> <br>`relationships`|`if copilot.current_device:`<br>`relationships = copilot.get_device_`<br>`(copilot.current_device)`|
|---|---|
||`if relationships:`|
|<br> <br>|`connected =list(relationships.keys())`<br> `print(`<br> `f"\n[{copilot.current_device} is "`|
|<br>|`f"connected to:{', '.join(connected)}]"`<br>`)`|
||`print()`|



## **How it works…** 

We provided an extensive explanation in the previous section. Let’s summarize all the enhancements: 

|Feature|Recipe 8�2|Recipe 8�3|
|---|---|---|
|Device<br>knowledge|Basic info only|Full topology awareness|
|Relationships|None|Interface-level connections|
|Impact analysis|None|Service dependencymapping|
|Templates|None|Confguration templates|
|Context|Simple device info|Rich context with relationships|
|AIprompts|Basic|Enhanced with impact analysis|
|User experience|Simple device tracking|Topologyview + connection     display|
|Data fles|Two fles (`devices.json`,<br>`responses.json`)|Four fles (`devices.json`,`network_context.`<br>`json`, `topology.json`, `templates.json`)|
|New functions|None|Five new functions (`get_device_`<br>`relationships`,`find_affected_devices`,<br>`get_configuration_template`,`analyze_`<br>`network_impact`, `build_enhanced_context`)|



_Building a Network Co-Pilot_ 

242 

|Feature|Recipe 8�2|Recipe 8�3|
|---|---|---|
|OpenAI<br>integration|`call_openai()`|`call_openai_with_knowledge()`|
|Conversation<br>storage|Basic metadata|Enhanced metadata with relationships|
|Interactive<br>commands|None|`topology`command to view connections|
|Errorprevention|None|Impact analysis warns about changes|
|Template support|None|Matches templates to device types and intents|
|Security<br>integration|None|Applies security standards and requirements|



_Table 8.1: Comparison of the second and third recipes_ 

## **There’s more…** 

The next step would be to load real device configuration and integrate our tool into a configuration database so that we do not need to keep updating it manually. 

## **See also** 

The _Building a core AI engine_ recipe. 

_Chapter 8_ 

243 

# **Summary** 

In this chapter, we built the foundation of our network co-pilot that understands our network environment. We started with basic model selection and evaluation to build our core AI co-pilot engine. The engine included features such as intent recognition, device context, network context, and a chat function that interacts with OpenAI. 

In the more advanced version of our AI co-pilot, we added topology, dependencies, and a configuration template. 

In the next chapter, we will integrate AI with network monitoring and performance use cases. 



<!-- Start of picture text -->
Get This Book’s PDF Version and<br>Exclusive Extras<br>Scan the QR code (or go to  packtpub.com/unlock ). Search for this<br>book by name, confirm the edition, and then follow the steps on<br>the page.<br>Note: Keep your invoice handy. Purchases made directly from Packt<br>don’t require an invoice.<br><!-- End of picture text -->

