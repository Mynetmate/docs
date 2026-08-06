# **The Python Requests Library** 

You’ve seen how to make HTTP-based API calls from the command line with cURL, or maybe you used the Postman GUI. These are great mechanisms for learning how to use a given API—but realistically, to write a script or a program that helps automate network devices, you need to be able to make API calls from within a script or program. In this section, we introduce the Python Requests library, which simplifies working with web-based APIs. 

To enable an easy mapping between the previous section and this one, we reuse the same examples from “Exploring HTTP-based APIs with cURL” on page 402, the Cisco Meraki API, and the Arista eAPI. This section is meant to be read from start to finish, as the core focus is getting started with using the Requests library. 



To install Requests, you can use `pip3` within your virtual environ‐ ment. Remember that you can review basic Python concepts in Chapter 6. Here’s the installation command: 

```
$ pip3 install requests
$ pip3 list | grep requests
requests                          2.26.0
```

## **Automating the Meraki API with Requests** 

Let’s dive in and take a look at our first example using Requests. We’re going to create a complete Python script to retrieve the first network, from the first organization, from a Cisco Meraki account. We’ve already executed this same GET request with cURL in Examples 10-2 and 10-3. Remember to check the Meraki API documenta‐ tion if needed. 

Now, in Example 10-22, we focus on the first part of a script to retrieve the organiza‐ tions available in Cisco Meraki. 

_Example 10-22. Using Requests to get Meraki organizations_ 

```
#!/usr/bin/env python3
```

> _`# The Python Requests library is used to issue and work HTTP-based systems.`_ **`import requests`** 

> _`# This executes if our script is being run directly.`_ **`if`** `__name__ == "__main__":` 

> _`# This token is taken from Cisco Developer Hub to experiment with the API`_ `my_token = "6bec40cf957de430a6f1f2baa056b99a4fac9ea0"` 

> _`# This statement creates a Python dictionary for the HTTP request`_ 

> _`# headers that are going to use in the API calls.  The first two`_ 

> _`# headers we are setting are Content-Type and Accept.`_ 

> _`# The last one uses a custom Meraki header for authentication`_ 

**452 | Chapter 10: Working with Network APIs** 

```
headers= {
"Accept": "application/json",
```

```
"Content-Type": "application/json",
"X-Cisco-Meraki-API-Key": my_token,
    }
```

```
# The URL is saved as a variable called base_url to modularize our
# code and simplify the next statement.
base_url="https://api.meraki.com/api/v1"
```

```
# In the Requests library, there is a function per HTTP verb, and in
# this example we are issuing a GET request, so we are therefore
# using the get function. We pass two objects into the get function.
# The first  object passed in must be the URL, and the others should be
# keyword arguments (key=value pairs). Then, we pass the proper headers.
response=requests.get(f"{base_url}/organizations", headers=headers)
```

At the end of this Python script, the `response` variable contains the response from the Meraki API. You could reproduce the same steps in an interactive Python session, as noted in Chapter 6. Actually, it’s a great idea to try this to better understand the content of the `response` variable. So, let’s run the previous script in the interactive interpreter, using the `-i` flag. It is a great way to test and troubleshoot: 

```
ch10-apis/python_requests$python3-iget_networks.py
# The interactive execution leave us at the end of our script, after the
# response = requests.get(f"{base_url}/organizations", headers=headers)
>>>response
<Response [200]>
```

The `response` variable contains a 200 HTTP response, so you should assume every‐ thing worked as expected. Indeed, one important piece of data is missing: where is the content of the response, containing the _organizations_ ? 

Being in the Python interactive interpreter session, you can inspect the `response` with `dir()` , displaying all attributes and methods of a given object: 

```
>>>dir(response)
[ # output omitted for brevity
'apparent_encoding', 'close', 'connection', 'content',
'cookies', 'elapsed', 'encoding', 'headers', 'history',
'json', 'links', 'next', 'ok', 'raise_for_status', 'raw', 'reason',
'request', 'status_code', 'text', 'url']
```

From all the attributes and methods available in the `response` , we will review two: `status_code` and `json` . 

The `status_code` attribute gives us access to the HTTP response code as an integer: 

```
>>>print(response.status_code)
200
```

The `json()` method returns the response content as a `dict` , decoding the JSON contained in the `text` attribute (which stores the actual response): 

**Using Network APIs for Automation | 453** 

```
>>>response.json()
[
  {
'id': '573083052582915028',
'name': 'Next Meraki Org',
'url': 'https://n18.meraki.com/o/PoiDucs/manage/organization/overview',
'api': {
'enabled': True
    },
'licensing': {
'model': 'co-term'
    },
'cloud': {
'region': {
'name': 'North America'
      }
    }
  },
# other entries omitted for brevity
]
>>>
```

You can start using this output by saving it as a variable and extracting the value of the `name` key from the first organization: 

```
>>>organizations=response.json()
>>>type(organizations)
<type'list'>
>>>organizations[0]["name"]
'Next Meraki Org'
```

In our script, we also store the response data in an `organizations` variable, and you can resume the script that will get the _networks_ from a given organization, as shown in Example 10-23. 

### _Example 10-23. Using Requests to get Meraki networks_ 

```
# Continues from the previous code snippet
```

```
# We pick the id from the first organization to later gather the related networks
first_organization_id=organizations[0]["id"]
```

```
# Similar get request, composing the URL with the organization id
response=requests.get(
        f"{base_url}/organizations/{first_organization_id}/networks", headers=headers
    )
```

```
networks=response.json()
```

We pick the identifier from the first available organization, accessing the `0` index in the list of organizations. 

**454 | Chapter 10: Working with Network APIs** 

If we explore the content of `networks` , we will see another dictionary—this time containing the network data from the Meraki API. 

Let’s continue to build on this; you are now going to create a new network (within an organization) by using Requests, as in Example 10-4. As you may guess, you need to only extend the previous script, adding the same content used in the cURL example: update the URL, update the HTTP request type, and send data in the body of the request, as we do in Example 10-24. 

### _Example 10-24. Using Requests to create a Meraki network_ 

```
# Continues from the previous code snippet
```

```
# first_organization_id comes from the previous script
```

```
# json library is used to encode a dictionary object as a JSON string
importjson
```

```
# Payload contains the data necessary to define the expected
# data to create a new network in the API
payload= {
"name": "my brand new automated network",
"productTypes": ["switch"],
    }
```

```
# Using the post method instead of get to create an object
response=requests.post(
        f"{base_url}/organizations/{first_organization_id}/networks",
headers=headers,
data=json.dumps(payload)
    )
```

```
print(response.json())
```

Pay attention to the HTTP verb being used. This particular request uses the `post()` function as a resource is being created. To update a resource, you’d use the `patch()` function, and to replace a resource, you’d use `put()` . You’ll see these functions in more examples later in the chapter. 

Let’s focus on how to send data in the body of the HTTP request. This is where you need to differentiate between a Python dictionary and a JSON string. While you work with dictionaries in Python to construct the required body, this is sent over the wire as a JSON string. To convert the dictionary to a well-formed JSON string, you use the `dumps()` function from the `json` module. This function takes a dictionary and converts it to a JSON string. You finally take the string object and pass it over the wire by assigning it to the `data` key being passed to the `post()` function. 

**Using Network APIs for Automation | 455** 



We typically know which payload data is required to create/update an API resource by checking the API documentation. Some of the attributes will use some defaults, but for the rest, we need to provide some data. In the example, `name` looks like an obvi‐ ous mandatory piece of data. But `productTypes` could be missed, assuming that it could be a default product type. In these cases, the API response should provide a useful error message to guide you, pointing out what is missing in the request payload. 

Finally, when running the script, you get a response (from the POST). It provides a new network with the `name` and the `productTypes` defined before, plus the rest of the parameters automatically assigned in creation: 

```
ch10-apis/python_requests$python3create_network.py
{
'id': 'N_573083052583238204',
'organizationId': '573083052582915028',
'productTypes': ['switch'],
'url': 'https://n18.meraki.com/my-brand-new-aut/n/vAQKbcs/manage/usage/list',
'name': 'my brand new automated network',
'timeZone': 'America/Los_Angeles',
'enrollmentString': None,
'tags': [],
'notes': None,
'isBoundToConfigTemplate': False
}
```

You have learned about using the Python Requests library for the Cisco Meraki API. Next, we continue exploring Requests but for the Arista eAPI (as in the cURL examples). 

## **Consuming eAPI in a Python script** 

We’re now going to look at Arista’s eAPI. As you learned in “Understanding nonRESTful HTTP-based APIs” on page 408, as you go through the next examples with eAPI, keep the following points in mind: 

- eAPI is a non-RESTful HTTP-based API. In other words, it’s an HTTP-based API that doesn’t follow all the principles of REST. An HTTP POST is used no matter which operation is being performed—even if `show` commands are used, a POST is still used. Specifically, it uses the JSON-RPC protocol to communicate between you (the client) and the switch (the server). 

- Remember POST requests require data to be sent in the data payload of the request. This is where solid API tools and documentation come into play. 

- The URL format for eAPI API calls is always _http(s)://<ip-address-eos>/ command-api_ . 

**456 | Chapter 10: Working with Network APIs** 



Arista switches have a built-in tool called the _Command Explorer_ that you could leverage to learn the required structure of the pay‐ load object. The API documentation provides details about this tool. 

We start with a basic Python script in Example 10-25. This code uses the Requests library to communicate to the Arista API (eAPI), executing the `show vlan brief` CLI command. This command should return the VLAN information with the device. At the end of the script, the code will output the response and the HTTP status code. 

_Example 10-25. Using Python Requests with Arista eAPI_ 

```
importjson
importsys
importrequests
fromrequests.authimportHTTPBasicAuth
if __name__ =="__main__":
# requests class to create the basic authentication header
auth=HTTPBasicAuth('ntc', 'ntc123')
url='http://eos-spine1/command-api'
# payload expected by the API
payload= {
"jsonrpc": "2.0",
"method": "runCmds",
"params": {
"format": "json",
"timestamps": False,
"cmds": [
"show vlan brief"
            ],
"version": 1
        },
"id": "EapiExplorer-1"
    }
```

```
# Even though we retrieve data with the "show vlan brief",
# the API uses the POST method
response=requests.post(url, data=json.dumps(payload), auth=auth)
```

```
# Helper output onscreen to show the status code, and the response
'
print(f'STATUS CODE: {response.status_code})
print(f'RESPONSE: {json.dumps(response.json(), indent=4)}')
```

`HTTPBasicAuth` class, from the Requests library, to create the basic authentication format (using a Base64 encoding). 

**Using Network APIs for Automation | 457** 

Using an _http_ endpoint is not recommended for production. If we use a selfsigned certificate or unverified HTTPS connection (adding `verify=False` to the requests method), we will receive a warning, which can be disabled with `requests.packages.urllib3.disable_warnings()` . 

Even though we are _retrieving_ data, the HTTP method used is POST. So, it requires a _payload_ , which defines several parameters required by the API. 

When you execute the script, it should give a similar output: 

```
ch10-apis/python_requests$python3eapi-requests.py
STATUSCODE: 200
RESPONSE:
{
"jsonrpc": "2.0",
"id": "EapiExplorer-1",
"result": [
        {
"sourceDetail": "",
"vlans": {
"1": {
"status": "active",
"name": "default",
"interfaces": {
"Ethernet1": {
"privatePromoted": false
                        },
# Omitted other interfaces for brevity
                    },
"dynamic": false
                },
"20": {
"status": "active",
"name": "VLAN0020",
"interfaces": {},
"dynamic": false
                },
"30": {
"status": "active",
"name": "VLAN0030",
"interfaces": {},
"dynamic": false
                }
            }
        }
    ]
}
```

The response is a nested JSON object, as expected. 

The output of the commands (only one in this example) is a list of dictionaries. There would be a list element for each command executed. 

**458 | Chapter 10: Working with Network APIs** 

It’s noticeable that, even though you send a CLI command ( `show vlan brief` ), the format of the response content is JSON. This makes it much easier to interact with the API programmatically. However, if you are interested in the traditional text CLI output, you can specify it with `"format": "text"` in the payload, and the response would contain an `output` key with a string: 

```
RESPONSE: {
"jsonrpc": "2.0",
"id": "EapiExplorer-1",
"result": [
        {
"output": "VLAN  Name                             Status    Ports\n
----------------------------------------------------------------"
# output omitted for brevity
        }
    ]
}
```

Next, we go a bit further with a more elaborate example to show the potential of automating the network via API-based scripts. 

**Using eAPI to autoconfigure interface descriptions based on LLDP data.** Let’s continue to use eAPI to build something a little more useful. How about a Python script that auto‐ configures interface descriptions for Ethernet interfaces based on LLDP neighbors for two Arista spine switches? 

To do this, you _should_ modularize the script to support multiple devices as well as have a simple way to send multiple API calls without requiring multiple payload objects in the script. Our goal is to autoconfigure interface descriptions such that they will look like the following (this is an example, and you will see the actual LLDP data and the final description later): 

```
interface Ethernet2
  description Connects to interface Ethernet2 on neighbor eos-leaf1.ntc.com
  no switchport
!
interface Ethernet3
  description Connects to interface Ethernet2 on neighbor eos-leaf2.ntc.com
  no switchport
!
```

To easily digest the code, we split it into three parts so you can progressively under‐ stand the complete example. 

First, in Example 10-26, you create the `issue_request()` function, which takes two arguments: the target device and the commands. The data is the only data in the requests’ operation. So, with this helper function, you could later pass different target devices and different commands to obtain the response (already converted from 

**Using Network APIs for Automation | 459** 

JSON to a Python object). This is a good example of the Don’t Repeat Yourself (DRY) software development principle. 

_Example 10-26. Wrapping requests in a helper function_ 

```
importjson
importsys
importrequests
fromrequests.authimportHTTPBasicAuth
# Helper method to issue "commands" to a "device", and return the result
defissue_request(device, commands):
"""Make API request to EOS device returning JSON response."""
payload= {
"jsonrpc": "2.0",
"method": "runCmds",
"params": {
"format": "json",
"timestamps": False,
"cmds": commands,
"version": 1
        },
"id": "EapiExplorer-1"
    }
response=requests.post(
'http://{}/command-api'.format(device),
data=json.dumps(payload),
auth=HTTPBasicAuth('ntc', 'ntc123')
    )
returnresponse.json()
```

```
# continues in the next example
```

The code of this function is exactly the same as Example 10-25, but has been modularized for reusability. 

Next, in Example 10-27, we leverage the `issue_request()` function to get the specific information we want from the API response (in this case, `lldpNeighbors` ). This implies knowledge of the data structure from the response, which you can get by experience or from the documentation. 

### _Example 10-27. Extracting LLDP neighbors from the response_ 

```
# continues from the previous example
```

```
defget_lldp_neighbors(device):
"""Get list of neighbors
```

```
    Sample response for a single neighbor:
```

**460 | Chapter 10: Working with Network APIs** 

```
        {
          "ttl": 120,
          "neighborDevice": "eos-spine2.ntc.com",
          "neighborPort": "Ethernet2",
          "port": "Ethernet2"
        }
    """
# Define the target methods
commands= ['show lldp neighbors']
response=issue_request(device, commands)
# Extract the neighbors' data from the result of the first and only command
# and return it as a list of dictionaries
returnresponse['result'][0]['lldpNeighbors']
```

```
# continues in the next example
```



Creating readable code takes practice, but in Example 10-27 you can observe two useful approaches: 

- Using self-descriptive naming: `get_lldp_neighbors` clearly defines its intent 

- Leveraging function docstrings to explain the function’s pur‐ pose—in this case, the format of the response 

Finally, in Example 10-28, we add another helper function, `configure_inter faces()` , and the `main` function to run the script. The `configure_interfaces()` function does exactly what it describes: takes the list of neighbors, and with _configura‐ tion_ commands, updates the description of the interfaces. In the `main` function, you define all the target devices to iterate on and perform two operations: get the LLDP information, and configure the interfaces description accordingly. 

_Example 10-28. Configuring the interfaces description with LLDP information_ 

```
# continues from the previous example
```

```
defconfigure_interfaces(device, neighbors):
"""Configure interfaces in a single API call per device."""
command_list= ['enable', 'configure']
forneighborinneighbors:
local_interface=neighbor['port']
iflocal_interface.startswith('Eth'):
# Excluding Management as it has multiple neighbors
description= (
              f"Connects to interface {neighbor['neighborPort']} on neighbor "
              f"{neighbor['neighborDevice']}"
            )
description='description '+description
interface= f'interface {local_interface}'
# Extending the list of commands, in the proper order
command_list.extend([interface, description])
```

**Using Network APIs for Automation | 461** 

```
# Retrieve the output from the commands created from the neighbors
response=issue_request(device, command_list)
```

```
if __name__ =="__main__":
# device names are FQDNs
devices= ['eos-spine1', 'eos-spine2']
fordeviceindevices:
neighbors=get_lldp_neighbors(device)
configure_interfaces(device, neighbors)
print('Auto-configured Interfaces for {}'.format(device))
```



Going through this example, you may be wondering if you could have organized the code differently. Maybe you could combine `get_lldp_neighbors` with the `configure_interfaces()` function, to get a bigger one. Or you could call `issue_request` out of the other functions, in the main code. The point here is that you have a myriad of options to create valid code. Choose one, experiment with it, and look for better patterns toward reusability and read‐ ability, while keeping it simple. 

Let’s run the script that will update the interfaces’ descriptions according to the LLDP neighbor: 

```
ch10-apis/python_requests$python3eapi-autoconfigure-lldp.py
Auto-configuredInterfacesforeos-spine1
Auto-configuredInterfacesforeos-spine2
```

Using the Requests Python library is an easy way to interact with APIs in your Python applications. However, to make it even simpler, some APIs provide their own libraries, the SDKs. We will give a quick glance at SDKs next. 

## **Using API SDKs** 

An _API SDK_ is a software package that abstracts access to an API by using functions, methods, and/or classes. It allows faster development because it comes with all the common conventions implemented. Therefore, you don’t need to reinvent the wheel every time, reducing development time. The SDK makes the code simpler and more readable. On the other hand, it could introduce some constraints due to non-implemented features available in the API or introduce library dependencies, increasing the footprint of your application. 

Most API platforms offer SDKs in the most popular languages in their user commu‐ nity. Both APIs explored in the previous section offer Python SDKs: 

- Cisco Meraki 

- Arista eAPI 

**462 | Chapter 10: Working with Network APIs** 

It’s not the purpose of this book to document using any specific SDK, but showing how an SDK is used enables you to see what one looks like. For detailed information about an SDK, check its reference docs page. 

**Exploring the Meraki API SDK.** Using the Meraki API SDK instead of the Requests library, you will get the same output as in Example 10-22 without having to know about some API conventions. For instance, you don’t need to know about the custom authentication header the API expects. This is also useful for maintainability because if this header key changes, you don’t need to update your code. 



Use `pip3` to install the Meraki API SDK: 

```
$ pip3 install meraki
$ pip3 list | grep meraki
meraki                            1.25.0
```

After importing the library, you have to instantiate the class `meraki.DashboardAPI` , which contains all the methods to interact with the API. This initialization requires only the API key used before, but not the URL or the authentication header key, as these are implicitly defined by the library: 

```
>>>importmeraki
>>>
>>>meraki_client=meraki.DashboardAPI(
...api_key="6bec40cf957de430a6f1f2baa056b99a4fac9ea0")
2022-10-0116:18:28meraki: INFO>MerakidashboardAPIsessioninitializedwith...
# output omitted for brevity
>>>
```

Then you can retrieve the organization, as you did in Example 10-22. Instead of crafting the HTTP request, you use the `getOrganizations()` method in `meraki_ client.organizations` : 

```
>>>my_orgs=meraki_client.organizations.getOrganizations()
2022-10-0116:18:49meraki: INFO>GEThttps://api.meraki.com/api/v1/organizations
2022-10-0116:18:50meraki: INFO>GEThttps://n392.meraki.com/api/v1/organizations
2022-10-0116:18:50meraki: INFO>organizations, getOrganizations-200OK
>>>
>>>my_orgs[0]
{
'id': '573083052582915028',
'name': 'Next Meraki Org',
'url': 'https://n18.meraki.com/o/PoiDucs/manage/organization/overview',
'api': {'enabled': True},
'licensing': {'model': 'co-term'},
'cloud': {'region': {'name': 'North America'}}
}
>>>
```

**Using Network APIs for Automation | 463** 

By now, you’re likely feeling comfortable interacting with HTTP APIs with Python. You’ve interacted with a native RESTful HTTP API, Cisco Meraki, and a non-RESTful one, Arista eAPI. As a reminder, every request to eAPI is an HTTP POST, and the URL is the same for every request, whereas a truly RESTful API using HTTP as its transport has a different URL based on the resource in question (e.g., organization, network, or routes in Cisco Meraki API). 

Next, we will use the other programming language covered in the book, Go, to explore a specific HTTP API, the RESTCONF interface. 

