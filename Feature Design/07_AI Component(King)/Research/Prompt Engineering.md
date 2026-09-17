#book #AI 
# The Prompt
Is an **Instruction** given to a model to **perform** tasks. Can asking with simple question or more complex.

## Component of Prompt

1. Task description : Role want model to play, output format.
2. Example : Provide a few example to model to detect something like bad words.
3. The task :  Concrete task you want model to doing.

![[Prompt-component.png.webp]]

# Context Learning

**Shot** is a word for count the example that give to LLMs to prevent cut-off dated model trained.

- Few Shot : Give some example
- 5-Shot : Give 5 example
- Zero-shot : Not give example

Number of example should experimental and find the **optimal** number of examples for **better** learn. It's limited by model's maximux context length.

---
# System Prompt and User Prompt

- **System** Prompt : Tasks description / **Role-playing** have 1st priority.
- **User** Prompt : The **tasks**

```
**System prompt:** You’re an experienced real estate agent. Your job is to read each 
disclosure carefully, fairly assess the condition of the property based on this 
disclosure, and help your buyer understand the risks and opportunities of each 
property. For each question, answer succinctly and professionally.

**User prompt:**
Context: [disclosure.pdf]
Question: Summarize the noise complaints, if any, about this property.
Answer:
```



---
## Special Token

This example from lama 2 (Meta)

- `<s>` and `</s>` : These are the **BOS** and **EOS** **tokens** from SentencePiece. When multiple messages are present in a multi turn conversation, they separate them, including the user input and model response.
- `[INST]` and  `[/INST]` : These tokens enclose **user messages** in **multi** turn **conversations**.
- `<<SYS>>` and  `<</SYS>>` : These enclose the **system message**.

Example Message
```
<s>[INST] <<SYS>>
{{ system_prompt }}
<</SYS>>

{{ user_message_1 }} [/INST] {{ model_answer_1 }} </s>
<s>[INST] {{ user_message_2 }} [/INST]

```

These are example of **special token** used to tell ai what's section of prompt, And only **low-level** library that you need to manipulate with it.

> [!warning] Accidentally used mismatch **special token** can change model behavior

---
# Context Length and Context Efficiency

**Context length** is limited maximum's per prompt and answer that LLMs can hold.

## Lost in the middle
The all part of **prompt is not equal**. **Beginning** and **end** of the prompt actually significant more than middle of prompt from experimental.


> [!tip] Prompt = System prompt + User prompt + Example + Context

---

# Relevant 

- [[03 Resources/02 Literature notes/Prompt Engineering Best Practices]]