

## **Comparing NETCONF, RESTCONF, and gNMI** 

At this point, you likely have questions about the differences between the three interfaces using a data-model-driven approach (NETCONF, RESTCONF, and gNMI). In this section, we want to give you more insight into how they are related. 

Everything started with NETCONF (the first RFC published in 2006) trying to address the limitations of SNMP to manage network configurations. At that moment, SNMP was widely used to monitor network’s operational state, but it was not adopted for network management. Because of this, as we explained in “Using NETCONF” on page 410, new ideas were introduced: multiple data stores, RPC operations, effective config management in transactions, and the use of data models to update/retrieve configuration data and retrieve operational data. 

Notice that we stress configuration management as the primary use case for NET‐ CONF. Implicitly, it was acknowledging that the SNMP monitoring approach, ported to NETCONF, was good enough. However, later, new concerns about a better way to retrieve operational data appeared, and the IETF started (around 2014–2015) to get requirements to implement streaming telemetry (a continuous and customized stream of data from a YANG data store), which we present in “Understanding model-driven telemetry” on page 448. 

Around the same time (2014), the OpenConfig consortium was founded and led by Google, focused on implementing streaming telemetry as one of the main drivers of gNMI, a new network management interface defined as an open source project (with the first commit in 2017), instead of an internet standard. For the rest of the func‐ tionalities, it used NETCONF ideas as a reference with a simpler implementation. 

More or less in parallel (2017), the IETF created the RESTCONF interface that brought together the NETCONF approach and the simpler, well-known RESTful API paradigm to promote more adoption of data-model-driven management when not all the NETCONF requirements are needed. 

Table 10-6 compares the three interfaces by focusing on their main differences. 

**446 | Chapter 10: Working with Network APIs** 

_Table 10-6. Comparing data-model-driven interfaces_ 

||**NETCONF**|**RESTCONF**|**gNMI**|
|---|---|---|---|
|Encoding|XML|JSON or XML|protobuf or JSON|
|Transport|SSH|HTTP/TLS|gRPC over HTTP/2|
|Transaction scope|Network-wide|Single-target, single-shot|Single-target, single-shot, sequenced|



Let’s take a closer look at these three main differences: 

#### _Encoding_ 

NETCONF used the most popular encoding when it was defined (XML), and RESTCONF, even though still supporting XML (likely for reusability from NET‐ CONF scripts), promoted JSON as a more popular encoding (and easier to read). However, gNMI chose protobuf because this binary encoding reduced the payload when compared to XML. Streaming operational data was an important use case for this interface, and this creates a lot of network traffic. 

#### _Transport_ 

NETCONF can support multiple transport protocols, but the most common one when it was defined was SSH, and it became the de facto one. RESTCONF lever‐ aged HTTP to become yet another REST API, and gNMI adopted the Google internal protocol gRPC to support protobuf encoding. 

#### _Transaction scope_ 

NETCONF came from operator best practices whereby the network itself is used to test and deploy configurations that can affect multiple devices, so the network-wide transaction scope was implemented. RESTCONF, to adhere to REST principles, doesn’t support state and can deal with only one target at a time, without any relevant operation sequence. gNMI is the simplest of all, assuming a specific order of all the operations. This simple approach comes from software-oriented teams managing infrastructure, where the configuration validation is most likely done out of the box, in a development environment. 

Next, so you can better understand the interfaces, we compare the development lifecycle of the organizations behind them, which are also developing vendor-neutral data models. 

### **Network interfaces development lifecycle** 

NETCONF and RESTCONF are defined and promoted by the IETF. On the other side, gNMI is developed under the umbrella of the OpenConfig community. Each group has a completely different way of working, which affects how these protocols and interfaces are defined, developed, and adopted: 

**Understanding Network APIs | 447** 

#### _IETF_ 

Its mission—defined in RFC 3936—is to develop technical recommendations to design, use, and manage the internet. This is done via an open process, with volunteers, and rough consensus from multiple parts. 

#### _OpenConfig_ 

This working group of network operators and vendors is focused on building a vendor-independent software layer for managing network devices. It operates as an open source project, with direct contributions. 

Both have the common goal to create better ways to manage networks. However, the difference is in the way they achieve it. IETF’s process of proposal, approval, and implementation usually takes longer than the same process under OpenConfig. In open source projects with strong leadership, the proposal, review, and adoption process leads to a faster release cycle. A standard addresses diverse use cases and will be stable for a while, but when you work on an open source project, you can move quickly to solve more concrete use cases and leave the door open for future changes. This capacity to deliver, especially for streaming telemetry, was one of the key factors for the adoption and popularity of the gNMI interface. 

Having multiple options to solve a problem is nothing new in the networking world. Successful nonstandard solutions have been adopted multiple times, and afterward, these solutions (with small differences) were adopted by IETF (e.g., NetFlow and Internet Protocol Flow Information Export, or IPFIX). The experience says that both could likely coexist, solving different usage approaches. 

OpenConfig and IETF are working on more than network management interfaces. A main focus of both organizations is to implement the right data models to describe the network information needed for configuration and operational validation. These models should work well under any of the interfaces—for instance, using an Open‐ Config data model under the NETCONF interface, as you saw in “NETCONF with Cisco IOS XE” on page 423. However, as we mentioned, the structure of the data models differ in how the intended and operational data is organized. 

Last, we will delve into streaming telemetry. 

### **Understanding model-driven telemetry** 

Current large-scale network architectures have uncovered the operational limitations of SNMP for network monitoring. Even though SNMP is still in use, its model to retrieve data via a _poll_ method, with the management server _asking_ for data every time, was adding delay and extra processing to get data continuously. 

**448 | Chapter 10: Working with Network APIs** 

These performance limitations, together with the adoption of data-model manage‐ ment (e.g., NETCONF or gNMI), led to the definition of _model-driven telemetry_ . It adopts a _push_ model to stream data from network devices continuously, providing near real-time access to operational data. Now, instead of _asking_ for data, the man‐ agement applications can _subscribe_ to specific data from the supported data models defined with YANG. The retrieved data is structured and can be published at a defined cadence or as it changes. 

With model-driven telemetry, you decide which data you need, when you need it, and where to send (or receive) it. You can subscribe to telemetry streams in two ways: dial-in and dial-out (represented in Figure 10-4). 

#### _Dial-in_ 

This is a dynamic model: an external application opens a session to the network device and establishes one or more subscriptions (to different parts of the data store) over the same session. The network devices send operation data for as long as the session stays up. 

#### _Dial-out_ 

This is a configured model: the subscriptions are configured on the network device in advance using any of the available interfaces, and it’s up to the device to open a telemetry session to the receiver. If this session goes down, the network device will open a new one. 



_Figure 10-4. Model-driven telemetry_ 

**Understanding Network APIs | 449** 

gNMI implemented the first streaming telemetry via the dial-in model, and it’s still the most widely adopted one. However, the dial-out model adds some benefits: 

- Reduces a network device’s exposure to external threats as the connection is initiated from the device itself and avoids firewall configurations to let access in. 

- Collectors can be stateless; they need to only listen and store the collected data. The control is on the configuration management system that created the subscription on the network device. 

Nowadays, both NETCONF and gNMI support the dial-in model. Dial-out mode is simply a configuration setting, which can be done via any configuration interface (including CLI), and the data is exported over a transport protocol (TCP or UDP). 

The first model-driven telemetry implementation was the gNMI `SubscribeRequest` operation, a dial-in mode. This has been, for a long time, one of the key benefits of gNMI versus NETCONF, which took more time to come up with its implementation definition. At the time of this writing, the adoption of streaming telemetry is much more mature in gNMI, which is widely adopted by most vendors. NETCONF dial-in and dial-out are still in their early stages. 

Dial-out telemetry has some incipient implementations—for instance, by Cisco and Juniper, using gRPC as the transport protocol. In parallel, the IETF is working on standards grouped as YANG Push, UDP and HTTPS/TCP transport options, and support for JSON and CBOR encoding. 



Concise Binary Object Representation or CBOR standardized in RFC 8949, is a binary data format based on JSON that supports schema definition directly with the YANG language. 

Model-driven telemetry has prioritized TCP as a transport protocol over UDP (used by SNMP) for providing more reliable data transfer, and with nonrepudiation. How‐ ever, UDP support provides some benefits in highly intense event traffic, such as in sampling mode when TCP benefits are not mandatory. 

As we will explore in Chapter 14 when discussing the role of model-driven telemetry in a network automation strategy, telemetry is usually combined with message brok‐ ers to distribute data from the collectors, adding some features such as data schema validation, versioning, or routing. 

Which solution will prevail is hard to predict. gNMI is well established and supported by a lot of vendors. On the other side, YANG Push supports more use cases (e.g., more encoding options) and comes from a standardization body (IETF) that is important for some network industry actors (e.g., service providers). 

**450 | Chapter 10: Working with Network APIs** 

Now that we’ve explained the API interfaces available to manage network devices and controllers, you must understand how to automate them via these APIs. We’ll now take a look at using Python and Go to automate these interfaces, and also SSH. 

# **Using Network APIs for Automation** 

As we’ve stated, the tools for _exploring_ and _learning_ to use an API differ from the tools used to _consume_ an API within a programmatic solution. Thus far, we’ve looked at cURL for exploring HTTP-based APIs, an interactive NETCONF over SSH session for exploring the use of NETCONF, and gNMIc for exploring gNMI. In this part of the chapter, we’ll look at how to use Python and Go to automate network devices, using some popular libraries: 

#### _Python Requests_ 

An intuitive and popular HTTP library for Python. This is the library we will use for automating devices and controllers with both RESTful HTTP-based APIs and non-RESTful HTTP-based APIs. 

#### _Go net/http_ 

A built-in package to serve as an HTTP client or server. Introduced in Chapter 7, it’s similar to Python Requests, and we will use it to demonstrate how to interact with RESTCONF. 

#### _Python ncclient_ 

This is a NETCONF client for Python, so we will use it for automating devices using NETCONF. 

#### _Go OpenConfig gNMIc_ 

We used this gNMI client as a CLI in the previous section. Here, we will use the package directly in Go applications to interact via the gNMI interface. 

#### _Python Netmiko_ 

This is a network-first SSH client for Python. This is the library we will use for automating devices via native SSH for devices without programmatic APIs. 



Even though we cover multiple APIs in this chapter, it is meant to be read from start to finish and not as API documentation for any given API. All the scripts created in this chapter have loose error handling because we are prioritizing simplicity to show the ideas instead of creating production-ready code. Be aware that the examples shown depend on the library’s version. The syntax and signature can change from one version to another. 

Let’s start by looking at the Requests library and communicating with HTTP-based APIs. 

**Using Network APIs for Automation | 451** 


![[Screenshot 2026-07-16 160329.png]]