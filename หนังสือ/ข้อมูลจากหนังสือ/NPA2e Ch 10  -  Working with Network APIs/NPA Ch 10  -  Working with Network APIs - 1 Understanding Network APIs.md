CHAPTER 10 Working with Network APIs From Python, Go, and data formats to configuration templating with Jinja, we’ve explored key foundational technologies and skills that will make you a better network engineer. In this chapter, you’re going to put these skills to practical use and start to consume and communicate with various types of network device APIs to start automating your network. As we introduced in Chapter 2, nowadays there are multiple options to interact with network platforms. Along with the traditional CLI and SNMP, we have new alterna‐ tives—from network-specific APIs (such as NETCONF, RESTCONF, and gNMI) to multipurpose APIs (such as HTTP-based ones or the Linux shell). Not every device supports all of these options, so understanding their capabilities will determine your automation options. All interfaces are viable for automation, each one with its own pros and cons. The goal of this chapter is to introduce these APIs, showcasing how you can use them programmatically in Python and Go. To best help you understand how to start interacting with networks programmati‐ cally, this chapter is organized into two sections: Understanding network APIs We examine the architecture and foundation of APIs, including RESTful and non-RESTful HTTP-based APIs, NETCONF, RESTCONF, and gRPC/gNMI. In each case, we introduce common tools used for testing and show how to use each one. Automating using network APIs We introduce some popular Python and Go libraries that allow you to start creating applications to interact with your network. We’ll look at the Python Requests and Go HTTP libraries for consuming HTTP-based APIs (including 397 RESTCONF), the Python ncclient for interacting with NETCONF devices, the Go gNMIc for interacting with the gNMI interface, and the Python Netmiko library for automating devices over SSH. As you read this chapter, keep in mind one thing: this chapter is not a comprehensive guide on any particular API and should not serve as API documentation. We provide examples using different vendor implementations of a given API, as it’s common to be working in a multivendor environment. It’s also important to see the common patterns and unique contrasts among APIs.
# **Understanding Network APIs** 

Our focus is on four of the most common types of APIs you’ll find on network devices: HTTP-based APIs, NETCONF, RESTCONF, and gRPC/gNMI. We’re going to start by looking at foundational concepts for each type of API; once we review them, we’ll explore the consumption of these APIs with hands-on examples using multiple vendors. 



For each network API type, we have used one or two network platforms. This doesn’t imply that each API is the only interface a platform supports. Actually, each platform usually supports multi‐ ple interfaces, but for illustrating multiple vendors and interfaces, we have used an arbitrary mapping to show diversity, without extra considerations. 

As we start our journey of _consuming_ and interacting with network APIs, in each API subsection, our focus is just like the focus we’ve had thus far throughout the book—on vendor-neutral tools and libraries. More specifically, we are going to look at tools such as cURL for working with HTTP-based APIs (RESTCONF included), NETCONF over SSH for working with NETCONF APIs, and gNMIc to interact with the gNMI interface. 

It’s important to note that this section is about _exploring_ network APIs in that we showcase how to get started using and testing network APIs without writing any code. We want you to understand the concepts from each particular API type before putting them to use in the next section. This section is _not_ about the tools and techniques you would use for automating production networks. Those types of tools and libraries are covered in “Using Network APIs for Automation” on page 451. Let’s get started by diving into HTTP-based APIs. 

**398 | Chapter 10: Working with Network APIs** 

## **Getting Familiar with HTTP-Based APIs** 

HTTP-based APIs are not exclusively used for network management. They are one of the most common interprocess connection types; thus most of the concepts intro‐ duced in this section apply to general use cases. Within the context of network automation, you will learn how to use APIs to manage network services using HTTP APIs as the management interface. For instance, HTTP APIs are used in Chapter 12 to provision dynamic network infrastructure via Terraform providers. In the same chapter, HTTP APIs are used to fetch data from a source of truth (SoT) containing the network device inventory and to create a dynamic inventory for Nornir. 

You should understand two types of HTTP-based APIs in the context of network APIs: RESTful HTTP-based APIs and non-RESTful HTTP-based APIs. To better understand them and what the term _RESTful_ means, we are going to start by examin‐ ing RESTful APIs. Once you understand RESTful architecture and principles, we’ll move on and compare them with non-RESTful HTTP-based APIs. 

### **Understanding RESTful APIs** 

_RESTful APIs_ are becoming more popular and more commonly used in the network‐ ing industry, although they’ve been around since the early 2000s. Most of the APIs that exist today within network infrastructure are HTTP-based RESTful APIs. There‐ fore, when you hear about a RESTful API on a network device or SDN controller, it is an API that will be communicating between a client and a server. 

The client is an application such as a Python script or web UI application, and the server is the network device or controller. Moreover, since HTTP is being used as transport, you’ll perform some operations using URLs just as you do already as you browse the internet. Thus, if you understand that when you’re browsing a website, HTTP GETs are performed, and when you’re filling out a web form and clicking Submit, an HTTP POST is performed, you already understand the basics of working with RESTful APIs. 

Let’s look at examples of retrieving data from a website and retrieving data from a network device via a RESTful API. In both instances, an HTTP GET request is sent to the web server (see Figure 10-1). 

In Figure 10-1, one of the primary differences is the data that is sent to and from the web server. When browsing the internet, you receive HTML data that your browser will interpret so that it can properly display the website. On the other hand, when issuing an HTTP GET request to a web server that is exposing a RESTful API (remember, it’s exposing it via a URL), you receive data back that is mostly encoded using JSON or XML. This is where you’ll use what we reviewed in Chapter 8. Since you receive data back in JSON/XML, the client application must understand how to 

**Understanding Network APIs | 399** 

interpret JSON and/or XML. Let’s continue with the overview, so you have a more complete picture before we start to explore the use of RESTful HTTP APIs. 



_Figure 10-1. Understanding REST by looking at HTTP GET responses_ 

Let’s take our high-level overview one step further and look at the origins of RESTful APIs. The birth and structure of modern web-based RESTful APIs came from a PhD dissertation by Roy Fielding in 2000. In “Architectural Styles and the Design of Network-based Software Architectures,” he defined the intricate detail of working with networked systems on the internet that use the architecture defined as REST. 

An interface must conform to six architectural constraints in order to be considered RESTful. For the purposes of this chapter, we’ll look at three: 

#### _Client-server_ 

This is a requirement to improve the usability of systems while simplifying the server requirements. Having a client-server architecture allows for the portability and changeability of client applications without the server components being changed. This means you could have different API clients (web UI, CLI) that consume the same server resources (backend API). 

#### _Stateless_ 

The communication between the client and server must be stateless. Clients that use stateless forms of communication must send all data required for the server to understand and perform the requested operation in a single request. This is in contrast to interfaces such as SSH, which have a persistent connection between a client and a server. 

#### _Uniform interface_ 

Individual resources in scope within an API call are identified in HTTP request messages. For example, in RESTful HTTP-based systems, the URL used refer‐ ences a particular resource. In the context of networking, the resource maps to a network device construct such as a hostname, interface, routing protocol configuration, or any other _resource_ that exists on the device. The uniform 

**400 | Chapter 10: Working with Network APIs** 

interface also states that the client should have enough information about a resource to create, modify, or delete a resource. 

These are just three of the six core constraints of the REST architecture, but you likely can already see the similarity between RESTful systems and how you consume the internet through web browsing on a daily basis. Keep in mind that HTTP is the primary means of implementing RESTful APIs, although the transport type could, in theory, be something else. To really understand RESTful APIs, then, you must also understand the basics of HTTP. 

**Understanding HTTP request types.** While every RESTful API you look at is an HTTPbased API, you will eventually look at HTTP-based APIs that do not adhere to the principles of REST and therefore are not RESTful. In either case, the APIs require an understanding of HTTP. Because these APIs are using HTTP as transport, you’re going to be working with the same HTTP request types and response codes that are used on the internet already. 

Common HTTP request types include GET, POST, PATCH, PUT, and DELETE. As you can imagine, GET requests are used to request data from the server, DELETE requests are used to delete a resource on the server, and the three Ps (POST, PATCH, PUT) are used to make a change on the server. In Table 10-1, we list each method’s definition along with its meaning in the context of networking. 

_Table 10-1. HTTP request_ 

|**Request type**|**Description**|**In networking context**|
|---|---|---|
|GET|Retrieves a specifed resource|Obtaining confguration or operational data|
|PUT|Creates or replaces a resource|Making a confguration change|
|PATCH|Creates or updates a resource object|Making a confguration change|
|POST|Creates a resource object|Making a confguration change|
|DELETE|Deletes a specifed resource|Removing a particular confguration|



**Understanding HTTP response codes.** Just as the request types are the same if you’re using a web browser on the internet or using a RESTful API, the same is true for response codes. 

Ever see a `401 Unauthorized` message when you were trying to log in to a website and used invalid credentials? Well, you would receive the same response code if you were trying to log in to a system using a RESTful API and you sent the wrong credentials. The same is true for successful messages or if the server has an error of its own. Table 10-2 lists the common types of response codes you see when working with HTTP-based APIs. This list is not exclusive; others exist too. 

**Understanding Network APIs | 401** 

_Table 10-2. HTTP response codes_ 

|**Response code **|**Description**|
|---|---|
|1_XX_|Informational|
|2_XX_|Successful|
|3_XX_|Redirect|
|4_XX_|Client error|
|5_XX_|Server error|



Remember, the response code types for HTTP-based APIs are no different from standard HTTP response codes. We are merely providing a list of the types and will leave it as an exercise for you to learn about individual responses. 

### **Exploring HTTP-based APIs with cURL** 

_cURL_ is a command-line tool for working with URLs. From the Linux command line, you can send HTTP requests by using the cURL program. While cURL uses URLs, it can communicate to servers using protocols besides HTTP, including FTP, SFTP, TFTP, Telnet, and many more. You can use the command `man curl` from the Linux command line to get an in-depth look at all the various options cURL supports. 



cURL isn’t limited to Linux. It’s available in multiple OSs such as macOS and Windows. For installation instructions, check _https:// curl.se/docs/install.html_ . 

Multiple alternatives to cURL are available, either as command-line tools or GUIs, but all share the same concepts. Once you understand the basic ideas, you can apply them to the other tools. However, using a user-intuitive web GUI frontend, such as Postman, could make it much easier to learn and test HTTP APIs. These GUI tools put the focus on using the API without worrying about writing code. You’ll see an example shortly in Figure 10-2 to help you understand the look and feel. 

We start our exploration of HTTP APIs by using cURL with the Cisco Meraki RESTful API (Meraki’s API documentation is available at _https://oreil.ly/zHOWy_ ). _Cisco Meraki_ is a cloud networking controller that helps to illustrate how to interact with this type of network infrastructure. Many modern NOSs also offer REST APIs, usually (but not limited to) implementing the RESTCONF interfaces, covered in “Using RESTCONF” on page 425. 

**Using the HTTP GET method to retrieve information.** As we’re just getting started with RESTful APIs, we’ll begin with a simple HTTP GET request to retrieve all _organiza‐ tions_ from the API, targeting the URL _https://api.meraki.com/api/v1/organizations_ . 

**402 | Chapter 10: Working with Network APIs** 



_Organization_ is an abstract concept from Cisco Meraki created to support multiple tenants for the same account. Each will contain different network resources. 

In Example 10-1, we use a cURL statement to call the Cisco Meraki URL and retrieve a list of all the organizations. 



Full versions of the code examples in this chapter can be found in the book’s GitHub repo at _https://github.com/oreilly-npa-book/exam ples/tree/v2/ch10-apis_ . 

#### _Example 10-1. Retrieving Meraki organizations with cURL_ 

- `$ curl 'https://api.meraki.com/api/v1/organizations'` **`\`** 

- `-H 'X-Cisco-Meraki-API-Key: 6bec40cf957de430a6f1f2baa056b99a4fac9ea0'` **`\`** 

- `-L` 

```
# response omitted
```

The URL is generic; it is shared by all Cisco Meraki customers. It’s offered as IaaS, covered in Chapter 4. 

We have not defined any HTTP operation. Nevertheless, by default, cURL per‐ forms a GET operation. This behavior can be modified using the `-X` flag, as in next examples. You can see all the available cURL customizations via the command documentation: `man cURL` . 

The `-H` argument, or `--header` , is used to include HTTP headers in the HTTP request. HTTP headers are key-value pairs used to pass metadata to the server, useful for things like authentication. 

The `-L` flag, or `--location` , allows the client to follow any redirects issued by the server. 



The Cisco Meraki API token used in Example 10-1 has been taken from Cisco Developer Hub. You can use the same one if it is still active. If not, a new one will likely be available on this website, for API exploration. 

Also, note that in the previous URL, the base URL path contains `/v1/` . This is an arbitrary way to indicate the targeted version of this API. As with any other applica‐ tion, the API can evolve over time, adding, changing, and removing resources. Using 

**Understanding Network APIs | 403** 

API versioning is a common pattern to offer a predictable behavior to consumer applications, without facing breaking changes (i.e., accessing a path that has been removed). In other APIs, the version may be specified via the `api_version` query parameter. This way, the URL path is not modified, and only the query parameter is appended; here’s an example: 

```
$ curl https://my_application.com/api/my_path?api_version=1.3
```

The omitted output from the cURL statement in Example 10-1 is an output word wrapped on the terminal, which is hard to read. Alternatively, as shown in Exam‐ ple 10-2, you can _pipe_ the response to `python3 -m json.tool` to pretty-print the response object, making it much more human-readable. 

_Example 10-2. Using the Python json.tool to render a JSON response_ 

```
$curl'https://api.meraki.com/api/v1/organizations'\
-H'X-Cisco-Meraki-API-Key: 6bec40cf957de430a6f1f2baa056b99a4fac9ea0'\
-L\
|python3-mjson.tool
[
{
"id":"573083052582915028",
"name":"Next Meraki Org",
"url":"https://n18.meraki.com/o/PoiDucs/manage/organization/overview",
"api":{
"enabled":true
},
"licensing":{
"model":"co-term"
},
"cloud":{
"region":{
"name":"North America"
}
}
},
# other organizations omitted for brevity
]
```

The object retrieved is a JSON object, which converts to a list in Python because it begins and ends with square brackets. Each item in the list is a dictionary, repre‐ senting an organization and all its attributes. The response media type (in this case, JSON), can be influenced by the `Accept` header (expressing the client wish), but in this case, it has no impact because JSON is the only media type supported by this API. 

To compare the user experience from cURL to Postman, Figure 10-2 shows an equivalent HTTP GET request done via the Postman GUI. 

**404 | Chapter 10: Working with Network APIs** 



_Figure 10-2. Postman GET request_ 



The UI you get from Postman may differ from the one in this book. UIs are evolving with the product, so it’s likely to change over time. However, the concepts remain the same. 

In Figure 10-2, you can appreciate the same request and output from Example 10-1, but in a better visual presentation. Following the same pattern, you could reproduce all the examples in this section in Postman. 



Postman allows you to create and publish Postman Collections as common API examples to be reused (using variables for custom‐ ization). These collections can serve as a good reference for com‐ mon operations on APIs. As an example, Nick Russo maintains an interesting collection for several network APIs at _https://oreil.ly/ QBJmd_ . 

Commonly, behind a REST API, different resources are _related_ . From Cisco Meraki documentation, we know that each organization can contain _networks_ . So, similar to the previous API endpoint for organizations, there is one for networks: `/api/v1/ organizations/{organizationId}/networks` . Between the curly braces, the `organi zationID` must be replaced by the actual organization identifier. 

**Understanding Network APIs | 405** 

This identifier is the most relevant attribute for each organization that you retrieved in Example 10-2. It is represented by the `id` key in each dictionary. Taking this ID, you can continue exploring the nested networks that belong to each organization. It’s interesting to notice the nested nature of this API, so you can’t list all the networks directly, but use the organizations they belong to as a reference. In Example 10-3, the organization ID is used to retrieve the networks that belong to it. 

_Example 10-3. Retrieving Meraki networks with cURL_ 

```
$curl'https://api.meraki.com/api/v1/organizations/573083052582915028/networks'\
-H'X-Cisco-Meraki-API-Key: 6bec40cf957de430a6f1f2baa056b99a4fac9ea0'\
-L\
|python3-mjson.tool
[
{
"id":"L_573083052582989052",
"organizationId":"573083052582915028",
"name":"Long Island Office",
"productTypes":[
"appliance",
"camera",
"switch"
],
"timeZone":"America/Los_Angeles",
"tags":[
"tag1",
"tag2"
],
"enrollmentString":null,
"url":"https://n18.meraki.com/Long-Island-Offi/n/kWaHAbs/manage/usage/list",
"notes":"Combined network for Long Island Office",
"isBoundToConfigTemplate":false
},
# other networks removed for brevity
]
```

The URL path contains the organization ID that limits the scope of the request to the networks belonging to that organization. 

The response is a list of dictionaries, each representing a network. And in each dictionary, we can find each network’s attributes. 

Similar to the previous organization’s example, the `id` key is used to uniquely identify the network. 

Next, we continue exploring HTTP methods introduced in “Understanding HTTP request types” on page 401. In particular, we’ll start with a method you can use to modify resources on the API: the POST. 

**406 | Chapter 10: Working with Network APIs** 

**Using the HTTP POST method to create a new resource.** In Example 10-3, you retrieved the networks belonging to a specific organization. Now, for the same organization, you want to create a new network (Example 10-4). 

_Example 10-4. Creating a Meraki network with cURL_ 

```
curl-XPOST'https://api.meraki.com/api/v1/organizations/573083052582915028/networks'\
-H'X-Cisco-Meraki-API-Key: 6bec40cf957de430a6f1f2baa056b99a4fac9ea0'\
-L\
-d'{"name": "my new automated network", "productTypes": ["switch"]}'\
-H'Content-Type: application/json'\
|python3-mjson.tool
```

```
{
"id":"N_573083052583237701",
"organizationId":"573083052582915028",
"productTypes":[
"switch"
],
"url":"https://n18.meraki.com/my-new-automated/n/mQ9KWds/manage/usage/list",
"name":"my new automated network",
"timeZone":"America/Los_Angeles",
"enrollmentString":null,
"tags":[],
"notes":null,
"isBoundToConfigTemplate":false
}
```

The HTTP method to create new objects is `POST` , and it is specified with the `-X` flag. The POST method requires _data_ . 

With the `-d` flag, or `--data` , we pass a JSON object with the attributes of the new network in the form of a key-value pair ( `name` and `productTypes` ). 

The `Content-Type` header is used to specify the data format. In this case, we are using JSON, but other formats are also supported (e.g., XML). 



Learning how to construct a proper API request requires becoming familiar with API documentation. The API documentation (the API definition and specs) defines what a given URL must be, the HTTP request type, headers, and what the body needs to be for a successful API call. For instance, in the previous example, we passed the required attributes for the POST request, but we could have also passed optional attributes, such as `timeZone` or `tags` . All these attributes are defined in the _API documentation_ . Additionally, performing GET requests offers some hints of the required attributes, as you can see in the output of the `networks GET` (in Example 10-3) and the data used for the `POST` . 

**Understanding Network APIs | 407** 

Now that you understand the principles of REST and HTTP, it’s important to also take note of non-RESTFul HTTP-based APIs. 

### **Understanding non-RESTful HTTP-based APIs** 

RESTful APIs are the most popular HTTP-based APIs, and other HTTP-based APIs are not compliant with REST principles. In the network industry, during the adop‐ tion of newer interfaces, such as RESTful ones, some APIs were built on top of CLIs, meaning that the API call actually sends a command to the device versus sending native structured data. Obviously, the preferred approach is to have any modern network platform’s CLI or web UI use the underlying API, but for legacy or preexisting systems that were built using commands, it is common to see the use of non-RESTful APIs, as it was easier to add an API this way rather than rearchitect the underlying system. 

RESTful HTTP-based APIs and non-RESTful HTTP-based APIs have two major dif‐ ferences. RESTful APIs use particular verbs (e.g., GET, POST, PATCH, etc.) to dictate the type of change being requested of the target server. For example, in the context of networking, a configuration change would never occur if you’re doing an HTTP GET, since you’re simply retrieving data. However, systems that are HTTP based but do not follow RESTful principles could use the same HTTP verb for every API call. This means if you’re retrieving data or making a configuration change, all API calls could be using a POST request. Another common difference is that non-RESTful HTTP-based APIs always use the same URL and do not allow you to access a specific resource via a URL change. You can see both characteristics in Example 10-5. 

Within the non-REST HTTP-based APIs, there is one popular methodology, the RPC, which was available before the REST APIs become popular. An RPC is a simple calling to a function in a remote system, with a data payload containing a method, and some other attributes. Depending on how the data is codified, we could talk about XML-RPC or JSON-RPC. This command-and-action approach makes it more performant, but also more obscure in terms of predictability. 



Both types, REST and RPC, can coexist on the same API server, in different parts of the API, leveraging their benefits for different use cases. We will present more RPC use cases in “Using NETCONF” on page 410 and “Understanding gRPC” on page 434. 

One example of a JSON-RPC API is the Arista eAPI. It offers an RPC endpoint ( `/command-api` ) to run CLI commands via the HTTP API. Example 10-5 uses cURL again to request the execution of the CLI commands providing the proper JSON payload. 

**408 | Chapter 10: Working with Network APIs** 

_Example 10-5. Running CLI commands via the Arista eAPI_ 

```
$curl--insecure\
-H"Content-Type: application/json"\
-XPOST\
-d'{"jsonrpc":"2.0", "method":"runCmds", "params":{ "version":1,
  "cmds":["show version"], "format":"text"}, "id":""}'\
https://ntc:ntc123@eos-spine1/command-api\
|python3-mjson.tool
{
"jsonrpc":"2.0",
"id":"",
"result":[
{
"output":" vEOS\nHardware version:    \nSerial number:       \n
            System MAC address:  5254. 0097.1b5e\n\nSoftware image version:
            4.22.4M\nArchitecture:           i686\nInternal build version:
            4.22.4M-15583082.4224M\nInternal build ID:
            08527907-ec51-458e-99dd-e3ad9c80cbbd\n\nUptime:
            15 weeks, 4 days, 13 hours and 22 minutes\nTotal memory:
            2014520 kB\nFree memory:            1335580 kB\n\n"
}
]
}
```

We are using the POST method to retrieve data. As we’ve commented, in nonREST APIs, the method is not meaningful. Actually, with the same method, depending on the CLI commands passed, we could be retrieving the state or changing it. 

We define the _operation_ to be executed remotely with the `method` ( `runCmds` ), and the `cmds` parameter, which contains a list of all the commands to be executed. 

The authentication parameters ( `ntc:ntc123@` ) are passed in the URL that is equivalent to the standard HTTP `Authorization` header. 

The `result` key contains the output of the command executed—in this case, the output of the `show version` command without any formatting, simply the raw text (i.e., what we get via an SSH CLI access). 

**Understanding Network APIs | 409** 



Alternatives to RESTful APIs other than RPC have appeared. For instance, GraphQL was published in 2015 by Facebook. It defines a data query language that simplifies the way data is con‐ sumed, allowing clients to define the structure/filtering of the data required, which will be served by the server. This approach reduces the amount of data transferred but can impede caching of the results. GraphQL is especially useful for retrieving data from an SoT, collecting the relevant data from one object (including nested resources). We dig into this in more detail in Chapter 14. 

As you start to use various types of HTTP-based APIs on network devices, keep in mind the following points: 

- HTTP APIs can use XML or JSON for data encoding, but the device may imple‐ ment only one or the other. The API’s author determines what gets supported. 

- Tools such as cURL and Postman are helpful as you get started with APIs, but to write code to interact with HTTP APIs, you need a library that _speaks_ HTTP, such as the Python Requests library or Go net/http package (covered in “Using Network APIs for Automation” on page 451). 

- Pay close attention to the HTTP verbs used when making configuration changes—using the wrong verb can have unintended consequences. 

- You need to use API documentation to understand how to construct a proper API request. You’ll need the URL, headers, HTTP method, and body. 

Now that we’ve introduced HTTP-based APIs, let’s shift our focus and introduce the NETCONF API. 


![[Screenshot 2026-07-16 153918.png]]

![[Screenshot 2026-07-16 160057.png]]