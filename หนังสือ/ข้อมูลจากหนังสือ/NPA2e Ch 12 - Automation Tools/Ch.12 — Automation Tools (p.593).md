CHAPTER 12
Automation Tools
No discussion of network automation would be complete without evaluating the role
that automation tools—like Red Hat Ansible, Nornir, and HashiCorp Terraform—
play in a network automation context.
Traditionally, this tooling has been more focused on the server automation use case.
This was understandable given that some of these tools had their origins in automating
server operating systems and managing OS and/or application configurations.
In recent years, though, multiple companies have expended a great deal of effort
to enhance the network automation functionality of their products. These enhancements
make these products much more useful and powerful for network automation.
Automated configuration management was the primary use case in the beginning.
But with the advent of dynamic infrastructure services offered mainly by public cloud
providers, tooling has evolved and new actors have entered the playground to enable
the IaC paradigm.
This chapter introduces how to use some popular open source automation tools in
the context of network automation:
• Ansible
• Nornir
• Terraform
Before we get into the details and examples of using these tools for network automation,
let’s take a quick look at an overview of them.
567
Reviewing Automation Tools
While all of these tools are focused on automation, each has its own architecture and
approaches automation in a slightly different way. This gives each tool its own set of
strengths and weaknesses. In this section, we quickly review each of the tools so that
you can begin to see how they might be used in your environment.
At a high level, some of the major architectural/conceptual differences among the
tools include the following:
Configuration management versus infrastructure provisioning
Infrastructure provisioning is the process used to create infrastructure—network
services, virtual machines, databases, etc. Configuration management is the
process of automating the installation of software components and performing
configuration management tasks. So, you could understand infrastructure provisioning
as a day 0 activity and configuration management as a day 1 activity. In
spite of most automation tools being able to achieve both, this chapter will help
you understand where each one shines.
Agent-based versus agentless
Some tools require an agent—a piece of software—to be running on the system
or device being managed. In a network automation use case, this could prove
to be a problem, as not every NOS supports running agents on a network
device. If a NOS doesn’t support running an agent natively on the device, there
are sometimes workarounds involving a proxy agent. Agentless tools, obviously,
don’t require an agent and may be more applicable in network automation use
cases.
Centralized versus decentralized
Agent-based architectures often also require a centralized master server. Some
agentless products also use a master server, but most are decentralized.
Custom protocol versus standards-based protocol
Some tools use a custom protocol; this is often tied to agent-based architectures.
Other tools leverage SSH. Given the ubiquity of SSH in network devices, tools
leveraging SSH as their transport protocol may be better suited to network
automation use cases.
DSL versus standards-based data formats and general-purpose languages
Some tools have their own domain-specific language (DSL); users of these tools
must create the appropriate files in that DSL to be consumed by the automation
tool. A DSL is a language purpose-built for a specific domain (or tool). For
organizations that aren’t already familiar with the DSL, this might create an
additional learning curve. Other tools leverage YAML, which is considered a
568 | Chapter 12: Automation Tools
general-purpose language in this context. Remember, we discussed YAML in
Chapter 8.
Declarative versus imperative
Some tools use a declarative approach to define the final state of the infrastructure:
independent of the definition order, the proper dependencies and tasks
will be inferred and executed to enforce the target state. Other tools use the
imperative approach: each step is a procedure to be performed, and the definition
order determines the execution order.
Extensibility
Most of these automation tools allow you to add or extend functionality via
high-level scripting languages, such as Python or Go.
Push versus pull versus event-driven
Some automation tools operate in a push model: information is pushed from
one place out to the devices or systems being managed. Others operate in a
pull model, typically pulling configuration information or instructions (often on
some sort of scheduled basis). Finally, event-driven tools perform an action in
response to another event or trigger.
Mutable versus immutable
Traditionally, when you needed to change an infrastructure’s configuration, you
simply mutated its state by applying changes to the current state. This process
is known as the mutable approach and is how configuration management tools
work. In contrast, in an immutable approach, you need to replace/restart the
infrastructure with a new one to change its state. Even the smallest change, such
as changing a server’s hostname, would then require you to reprovision that
server and start from scratch. Depending on the focus, some tools are more
suited than others for each case.
State management
Configuration management tools don’t manage the lifecycle of the remote infrastructure.
You can gather the state at each step, but it’s not implicitly tracked.
Conversely, the tools based on the immutable pattern need to decide when it’s
necessary to re-create an infrastructure component, so they usually keep the state
of the remote infrastructure that was provisioned by them.
With this high-level set of architectural differences in mind, let’s take a quick look at
the three tools covered in this chapter:
Ansible
Ansible uses a decentralized, agentless architecture with SSH as the underlying
transport protocol. It is typically operated in a push model, though it also
supports a pull model. Ansible is built using Python and leverages Python for
Reviewing Automation Tools | 569
extensibility. Ansible supports templating using the Jinja templating language.
Ansible originally targeted a way to run ad hoc commands on servers, but has
since evolved into task orchestration using playbooks that perform idempotent
tasks on target systems. Playbooks can be written in standard YAML or an
Ansible derivation of YAML.
Nornir
Nornir is a lightweight Python framework (not a CLI) designed for network
automation that can be extended via plug-ins adding new features (e.g., tasks or
inventory sources) without having to write them from scratch. It is an alternative
to automation tools like Ansible because, being pure Python, it gives you full
control of the logic and direct access to all the libraries and tools available.
Nornir comes with a few Python constructs that make it easy to use the inventory
of hosts, run tasks, and process the results, everything in a structured way. And,
by default, Nornir uses multithreading, so the tasks are performed in parallel per
host.
Terraform
Terraform takes a dramatically different approach from the other tools listed
here. Terraform is focused on infrastructure provisioning instead of configuration
management, and lets you define your infrastructure (and manage its
lifecycle) in human-readable and declarative configuration files, using a Terraform
configuration language. It is agnostic to the infrastructure providers and
easy to extend via providers, becoming the most relevant tool in the IaaS
ecosystem.
Other popular network automation tools are not covered in this
book because of space constraints. However, at https://oreilly-npabook.
github.io, you have available content from the first edition of
this book, covering two extra tools:
• Salt can use either an agent-based architecture or an agentless
architecture. Salt started as a tool for remote server management,
like Ansible, with idempotent configuration management
via Salt States, written in YAML. One distinction to
make with Salt is that it is also a platform for event-driven
automation (using a message bus) beyond general configuration
management.
• StackStorm focuses on event-driven automation; tasks are performed
in response to events. StackStorm leverages Python to
build sensors that emit events or actions to trigger a task.
570 | Chapter 12: Automation Tools
Now, let’s dive a bit deeper into how Ansible, Nornir, and Terraform can be used
for network automation. We’ve arranged the in-depth discussion of the products in
alphabetical order, so we’ll start with Ansible.
Using Ansible
Ansible takes months (or more) to master. Our goal in this section is to provide
enough information that you can start automating common tasks immediately. To
facilitate this jump start, we’ve divided this section into seven major areas:
• Discovering the Ansible framework
• Understanding how Ansible works
• Constructing an inventory file
• Executing an Ansible playbook
• Understanding variable files
• Writing Ansible playbooks for network automation
• Using third-party collections and modules
Ansible is constantly evolving and adding new features to the
framework. A newer one, not covered in this book, is the Event-
Driven Ansible automation that, at a glance, introduces the
capacity to subscribe to an event source (e.g., Kafka) to trigger
workflows (implementing if this, then that instructions) and generate
scheduled events.
By the time you complete this section, you’ll have a solid foundation on Ansible,
the different types of network automation you can accomplish using Ansible, and
most importantly, enough to continue on your automation journey. We’ll start by
presenting the various projects under the Ansible umbrella.
Discovering the Ansible Framework
Ansible is an open source community project sponsored by Red Hat, and since
version 2.9, it’s been split into two main components: Ansible Core (ansible-core)
and the Ansible community (ansible) packages:
Ansible Core package
This core building block of the Ansible framework contains all the functionalities
(language, runtime, and built-in plug-ins). It’s useful for a minimal installation
footprint and development environments.
Using Ansible | 571
Ansible community package
This package includes a range of community-curated collections with hundreds
of modules (you’ll learn more about modules in “Getting familiar with Ansible
tasks and modules” on page 583). It requires the ansible-core package.
You can install both packages via PyPI by executing pip3 install ansible, as
shown in Example 12-1.
Full versions of the code examples in this chapter can be found in
the book’s GitHub repo at https://github.com/oreilly-npa-book/exam
ples/tree/v2/ch12-automationtools.
Example 12-1. Getting the Ansible version
$ pip3 install ansible
# omitted output
$ pip3 list | grep ansible
ansible 4.8.0
ansible-core 2.11.6
$ ansible --version
ansible [core 2.11.6]
config file = /etc/ansible/ansible.cfg
configured module search path = ['/etc/ntc/ansible/library']
ansible python module location =
/usr/local/lib/python3.8/site-packages/ansible
ansible collection location =
/home/ntc/.ansible/collections:/usr/share/ansible/collections
executable location = /usr/local/bin/ansible
python version = 3.8.12 (default, Oct 13 2021, 09:22:51) [GCC 8.3.0]
jinja version = 3.0.2
libyaml = True
Installs two packages, ansible and ansible-core, which are the versions used in
this book
Displays more details about the Ansible installation
AWX is another open source project in the Ansible ecosystem.
This project helps build more sophisticated network automated
solutions on top of Ansible. AWX provides a web-based UI, REST
API, and a task engine, so it could work as the orchestrator and
workflow executor of multiple Ansible tasks. It is also worth noting
that Red Hat does sell a commercial product with enterprise support
called Ansible Automation Platform.
572 | Chapter 12: Automation Tools
Now that you’re aware of the components, it’s time to understand how Ansible works.
Understanding How Ansible Works
The first thing we’re going to review is how Ansible works from an architectural perspective
when automating not only network devices but also Linux servers. Subtle but
important differences exist in these two options, and these differences are ultimately
reflected in the automation workflows we create with Ansible.
Automating Linux servers
When Ansible is used to automate Linux servers, it operates in a distributed fashion.
The Ansible control host, the machine that has Ansible installed, connects via SSH
to each server being automated. The control host subsequently copies Python code to
each server—this code is what performs the automation task at hand.
These tasks include anything from restarting a Linux process and installing Linux
packages to updating text files, pulling updates down from a Git repository, or simply
running a bash script on the target Linux hosts being automated. If 100 Linux servers
are being automated, 100 servers execute the Ansible code (or modules) to perform
the task.
Ansible can also be used to automate Windows servers, but the
context here is to describe the origins and most common use of
Ansible and how that compares to automating networking devices.
Automating network devices
How Ansible works when automating network devices is a little different: it works in
a local, or centralized mode. When automating network devices, the Ansible control
host gets configured to run in local mode. When Ansible runs in local mode, Ansible
does not connect to each device via SSH and copy Python code to each network
device. In fact, when running in local mode, Ansible actually connects to itself and
executes the Python code locally.
The Python code that runs locally may still connect to the network device via SSH,
but it may also be via an API (or Telnet or SNMP). However, even when Ansible
connects via SSH for network devices, Python files are not copied to the device,
and CLI commands are simply sent over an SSH connection. From an extremely
high-level view, this becomes analogous to executing Python scripts on a server and
automating multiple network devices in parallel.
Using Ansible | 573
It is possible to have network modules not operate in local mode,
but it requires updates to many NOSs. To support this, the network
device must permit you to SSH into the device, copy Python files
to a temp directory, and then execute those files with a Python
execution engine. With the rise of Linux-based NOSs, running
Python code inside the box is getting more and more common.
Now that you understand how Ansible operates differently for network devices as
compared to Linux hosts (which is what Ansible was initially built for), let’s review
some Ansible vernacular that’s critical to getting started.
Constructing an Inventory File
The first Ansible file we’re going to look at is the Ansible inventory file. The inventory
file is one of two files required to start automating network devices with Ansible. The
second, which we cover next, is the playbook.
Traditionally, the inventory file has been defined as an INI-like file that contains the
devices that will be automated with Ansible. Example 12-2 shows a basic Ansible
inventory file.
Example 12-2. Basic Ansible inventory INI file
10.1.100.10
10.5.10.10
nyc-lf01
This example is one of the simplest inventory files you can have. It has three lines
in it, one per device. As you can see, by default you can use either IP addresses or
hostnames (which are fully qualified domain names).
Alternatively, you could also define the inventory file by using the YAML syntax. In
Example 12-3, you get the same result as in Example 12-2.
Example 12-3. Basic Ansible inventory YAML file
all:
hosts:
"10.1.100.10":
"10.5.10.10":
nyc-lf01:
You can notice two new dictionary keys, all and hosts (we elaborate on them in
the following sections). So, the YAML format is a bit more verbose and even more
precise. Both options are valid and easy to write and read, but for consistency we use
only one through the chapter, the INI notation.
574 | Chapter 12: Automation Tools
While an inventory file can seem basic, you can gradually add more structure and
data to it as you start doing more with Ansible. If you’re testing and getting started
with only a few devices, the previous example may suffice. However, you need to
consider more realistic scenarios such as having larger quantities of devices, having
different types of devices, and deploying those devices in different parts of a network
(e.g., data center, DMZ, WAN, or access, just to name a few). The upcoming examples
introduce how to create groups and define variables in the inventory file.
Let’s walk through building out an inventory file that will represent the devices for
two regions, EMEA and AMERS, and two device roles, dc and cpe (see Figure 12-1).
Each device role per region comprises different types of network equipment, as you
can see in the diagram.
Figure 12-1. Network topology diagram
Working with inventory groups
As you can see, you have two core geographic locations, the AMERS and EMEA
regions, with different device types. You’ll create different groups so you can easily
automate all devices of a certain type, for a certain operating system, or within a given
location.
Using Ansible | 575
We start in Example 12-4 by creating two groups for the devices in the AMERS
region called amers-cpe and amers-dc. Each group will have two devices. The cpe
group will have two Cisco IOSXE devices, and the dc group will have two Cisco
NXOS switches. Instead of using IP addresses, we use the router fully qualified
domain name (FQDN) defined in your local /etc/hosts file.
Example 12-4. Ansible inventory file with groups
[amers-cpe]
csr1
csr2
[amers-dc]
nxos-spine1
nxos-spine2
The bracket [] syntax creates logical groups within the inventory file. You’ll see later
how to reference these groups in a playbook so they are easily automated.
Using nested groups in an inventory file
You can also create groups of groups, or nested groups, in an inventory file. For
example, you may want to automate all devices in the AMERS region. To do this,
you’ll add a group called amers that contains amers-cpe and amers-dc, as shown in
Example 12-5.
Example 12-5. Ansible inventory file with groups for AMERS
[amers:children]
amers-cpe
amers-dc
[amers-cpe]
csr1
csr2
[amers-dc]
nxos-spine1
nxos-spine2
When creating nested groups, you must use :children in the group name definition.
After you’ve added the amers group, your inventory file has three explicitly defined
groups: amers, amers-cpe, and amers-dc.
Using the same approach, you can build out the inventory for the EMEA region as
shown in Example 12-6.
576 | Chapter 12: Automation Tools
Example 12-6. Ansible inventory file with groups for EMEA
[emea:children]
emea-cpe
emea-dc
[emea-cpe]
vmx1
vmx2
[emea-dc]
eos-spine1
eos-spine2
You may also want to create groups to automate all devices of a particular role in
the network, such as all CPE devices or all DC devices. To do this, you can create
additional groups, as shown in Example 12-7.
Example 12-7. Ansible inventory file with groups for device roles
[all-cpe:children]
amers-cpe
emea-cpe
[all-dc:children]
amers-dc
emea-dc
As you’re seeing, inventory files can be extremely basic when you’re just getting
started but can quickly expand based on how you want to automate your network
devices.
After getting your group structure defined and into your desired state, it’s good to
know that you can even define variables within your inventory file.
Using variables in Ansible
You can define two types of variables in your Ansible inventory file:
• Group variables
• Host variables
Managing group variables. Group variables are assigned at the group level. For example,
you may define a variable such as the NTP Server IP address to use for all devices
in the AMERS region and then another NTP IP address for devices in EMEA. This is
reflected in an inventory, as shown in Example 12-8.
Using Ansible | 577
Example 12-8. Group variables
[amers:vars]
ntp_server=10.1.200.11
[emea:vars]
ntp_server=10.10.200.11
As you can see, when you define group variables, you create a new section in
the inventory file with the name of the group and append :vars. In this section,
you define group-based variables. Our example creates a single variable called
ntp_server. When you’re automating devices in the AMERS group and reference
this variable, the value of 10.1.200.11 is used, and when automating devices in the
EMEA group, the value of 10.10.200.11 is used.
There is no specific requirement around the ordering of groups
and variables in your inventory file. You can have all groups and
then all variables, or group 1, group 1 variables, group 2, group 2
variables, and so on.
Managing host variables. You can also define host variables that are specific to a given
device in the inventory file. To define a host variable, you put the variable on the
same line as the host. One scenario, given our NTP example, is that there is a
dedicated NTP server per region. But what if there is a device called nxos-spine1 that
must use a different address? This is accomplished as shown in Example 12-9.
Example 12-9. Host variables
[amers-dc]
nxos-spine1 ntp_server=10.1.200.200
nxos-spine2
Adding variable=value on the same line as the device is how you add host-specific
variables within the inventory file. You can also add multiple variables on the same
line, such as in Example 12-10.
Example 12-10. Defining multiple host variables
[amers-dc]
nxos-spine1 ntp_server=10.1.200.200 syslog_server=10.1.200.201
nxos-spine2
578 | Chapter 12: Automation Tools
Understanding variable priority. More-specific variables have priority, so if you have
nested groups such as amers and amers-cpe, a group variable in amers-cpe will
override the same variable if defined as an amers group variable. If there was a
host-specific variable for a device in amers-cpe, that would then have higher priority
and override the amers-cpe group variable.
Ansible provides many more ways to use variables than this book outlines. Although
variable priority may not seem like an issue when you’re getting started, it’s a much
more significant topic to consider in large Ansible projects. Variable precedence is
well defined in Ansible’s documentation, with more than 20 possibilities!
Getting familiar with the all group. Be aware that there is an implicit group that always
exists, called all. This group is used to automate all devices in an inventory file.
Example 12-11 shows how you can also assign group variables in the all group.
Example 12-11. Group-based variables in the all group
[all:vars]
ntp_server=10.1.200.199
syslog_server=10.1.200.201
Variables defined in the all group end up being defaults and are used only if the
given variable isn’t defined in a more specific group or as a host-based variable.
You need to know how group and host-based variables work, but
the inventory file is not the proper place to define all your variables
for a given project. Dedicated files are recommended for defining
variables—these files are covered in “Managing host variables” on
page 578.
If you’re testing along as you’re reading, you may want to add a few more groups and
variables to the inventory file, as shown in Example 12-12.
Example 12-12. Creating groups per OS
[nxos]
nxos-spine1
nxos-spine2
[nxos:vars]
ansible_network_os=nxos
[eos]
eos-spine1
eos-spine2
[eos:vars]
Using Ansible | 579
ansible_network_os=eos
[iosxe]
csr1
csr2
[iosxe:vars]
ansible_network_os=ios
[junos]
vmx1
vmx2
[junos:vars]
ansible_network_os=junos
The reason we’ve added groups and group-based variables for each OS is that in
many cases this information is required to automate a given device because many
modules either (a) only work for a particular device OS or (b) are multivendor and
still require knowing the OS up front.
After combining the previous inventory snippets, you get a full
inventory. You can check it in the Ansible folder in the examples
repository, in the inventory file.
The easiest and most common way to get started with inventory is
to use the inventory file. However, if you happen to work in a very
dynamic or large environment, or have an existing configuration
management database (CMDB) or network management system
(NMS) that contains inventory data, Ansible can be integrated
with those systems. Ansible supports dynamic inventory scripts
such that an inventory file is replaced with a script. The script
queries your CMDB/NMS, normalizes the data, and then returns
valid JSON in the structure Ansible requires as defined in its docs
(out of scope for this book). You can also return variables in the
dynamic inventory script such that if you’re a large enterprise, all
you’d manage are playbooks—all inventory and variables are then
returned dynamically as you execute your playbook.
Earlier we stated that the Ansible inventory file is one of two files required to start
automating network devices with Ansible. The second file is the Ansible playbook—
this is what we’ll dive into next.
580 | Chapter 12: Automation Tools
Executing an Ansible Playbook
The Ansible playbook is a file that contains your automation instructions. In other
words, playbooks contain the individual tasks and workflows that you want to use to
automate your network. The playbook itself is written in YAML. This is when being
familiar with YAML, as covered in Chapter 8, will come in handy.
The term playbook comes from a sports analogy, and thus each playbook file contains
one or more plays. And if we expand on that, each play contains one or more tasks.
Let’s take a look at a playbook in Example 12-13 to better understand its structure
and associated terminology. We are going to review plays, tasks, modules, and using
variables in a playbook, as well as the link from the playbook to the inventory file.
Example 12-13. Ansible playbook (ch12-automationtools/ansible/snmp-intro.yml)
---
- name: "PLAY 1 - ISSUE SNMP COMMANDS"
hosts: "iosxe"
gather_facts: "no"
connection: "ansible.netcommon.network_cli"
tasks:
- name: "TASK1 - SHOW SNMP CONFIG"
ios_command:
commands:
- "show run | inc snmp"
- name: "TASK 2 - DEPLOY SNMP COMMANDS"
cisco.ios.ios_config:
commands:
- "snmp-server chassis-id {{ inventory_hostname }}"
A playbook is a YAML file that defines a list of plays. Every play is a dictionary
that includes several key-value pairs. Being familiar with the basics of YAML and
indentation from Chapter 8 should help you to manage it (remember to avoid
indentation issues, or Ansible will complain). YAML files generally start with
---, although it isn’t, strictly speaking, required. It’s required only when multiple
YAML documents are within a single file.
name is optional but recommended. This is used to define what the play is for and
what task is being performed. In other words, it’s arbitrary text.
hosts specifies which devices we want to automate. We can specify a host, group,
multiple of each, or even expressions that refer to names in our inventory file.
For example, if we want to automate all devices in EMEA by using our previous
Using Ansible | 581
inventory file, we can use hosts: emea; or for devices that are EOS and Junos
groups, we could use hosts: eos,junos denoting a comma-separated list.
gather_facts allows getting facts from the device running Ansible, but because
we’re automating network devices, we run Ansible locally, so we are not getting
facts. If we were running Ansible out of the box to automate Linux servers,
Ansible would by default collect facts from each node, including items such as
OS type, OS version, vendor, IPv4 addresses, and much more.
connection defines the connection type a play uses. We use Ansible.netcom
mon.network_cli to provide a CLI shell connection to remote devices over SSH,
implicitly using the local mode. The netcommon collection (we explain Ansible
collections in “Using Third-Party Collections and Modules” on page 611) also
contains other modules to use other network connections, such as netconf or
httpapi.
Within tasks, we define a list of tasks that will be executed sequentially by the
playbook.
Most network Ansible modules (such as ios_command) implemented
a provider parameter used together with connection:
local, for the same purpose as Ansible.netcommon.network_cli.
However, this option is now being deprecated in favor of net
work_cli, used at the play level.
It is important to notice that a module (such as Ansible.netcommon.network_cli
or ios_command), can take several parameters to tune its behavior. Some are mandatory,
and others are optional (they come with a default value), but they may be
tuned in three ways: Ansible variables, environment variables, or Ansible configuration
options. For instance, in Ansible.netcommon.network_cli, the parameter
host_key_checking defaults to Yes but can be changed via any of the following:
• Ansible configuration file, with the host_key_checking key
• Environment variables: ANSIBLE_HOST_KEY_CHECKING and ANSIBLE_HOST_KEY_
CHECKING
• Ansible variables: ansible_host_key_checking and ansible_ssh_host_key_
checking
We explain more about using these tuning options in “Executing a playbook” on page
584.
582 | Chapter 12: Automation Tools
We recommend checking the Ansible module documentation to
understand each module’s implicit configuration. It could save you
a lot of surprises when running your playbooks and will help you
better define the data population strategy.
Next, we’ll take a look at tasks and how they relate to modules.
Getting familiar with Ansible tasks and modules
After you define the high-level attributes of your play, such as the connection type
and the hosts you want to automate, you need to define tasks. Each task runs an
Ansible module, which is performing some form of automation. Our example has
two tasks, denoted by the task names.
On the same indent level as name in both tasks, you’ll see ios_command and
cisco.ios.ios_config. Called Ansible modules, these perform a specific operation.
In particular, ios_command issues exec-level commands to Cisco IOS devices, and
cisco.ios.ios_config sends configuration-level commands. We’ll cover many more
modules in this section as we walk through example playbooks.
You may be also wondering why we refer to one module as simply ios_command,
but the ios_config module includes a cisco.ios prefix. The reason is that the
ios_command module existed prior to the introduction of the collections feature in
Ansible. With collections, modules are grouped into namespaces, and in the case of
the ios_config module, located within the cisco.ios namespace. The old syntax is
kept for backward compatibility with old playbooks, serving as an alias to the actual
new collection syntax.
Ansible has over 750+ modules, grouped in collections, that allow
you to automate Linux servers, network devices, Windows servers,
public cloud environments, and much more. You can get an index
to all these modules in the Ansible documentation.
Let’s focus on the first task in Example 12-14, which uses the ios_command module.
Example 12-14. Getting the SNMP config with Ansible
tasks:
- name: "TASK1 - SHOW SNMP CONFIG"
ios_command:
commands:
- "show run | inc snmp"
- "show snmp"
Using Ansible | 583
A task is a dictionary in the tasks list, within a play.
The task name is optional but helpful to follow tasks’ execution.
ios_command is the module we use to run this task. It takes several parameters
that will be passed into the module, similar to passing variables or key-value pairs
into a Python function.
commands indicates a list of strings (CLI commands) that will be executed in the
device. It’s important to understand YAML data types because you will find them
everywhere, including strings, integers, or dictionaries.
Because this is a list, we can concatenate commands as desired.
Now, in Example 12-15, we focus on the second task, to configure SNMP settings.
Example 12-15. Deploying SNMP commands with Ansible
- name: "TASK 2 - DEPLOY SNMP COMMANDS"
cisco.ios.ios_config:
commands:
- "snmp-server chassis-id {{ inventory_hostname }}"
In this case, we are using the long module syntax that resolves to the same
module as the ios_command in Example 12-14.
We are using an Ansible variable—more specifically, a Jinja variable. You should
recognize this from the Jinja configuration templates in Chapter 9. This particular
variable, inventory_hostname, is a built-in Ansible variable that is equal to
the device name as defined in the inventory file. In our example playbook, we’re
automating all devices in the group called iosxe, which is two Cisco routers: csr1
and csr2. For all devices in that group, both tasks are executed by Ansible. When
the device being automated is csr1, inventory_hostname is equal to csr1; when
the device being automated is csr2, inventory_hostname is equal to csr2.
We’ve now provided a high-level overview of how to construct a playbook. As this
section progresses, we’ll continue to dive into more detail on how certain modules
work and cover much more about Ansible and automating network devices.
Executing a playbook
As we’ve stated, the two files required to get started with Ansible are the inventory file
and the playbook. We’ve reviewed both and are ready to execute a playbook against a
set of network devices.
584 | Chapter 12: Automation Tools
In our example, we saved the inventory file as inventory and the
playbook as snmp-intro.yml. Both filenames are arbitrary and user
defined.
To execute a playbook, you use ansible-playbook and the playbook file. Along with
these two basic components, you can customize the execution, defining a specific
inventory file by using the -i flag, or passing Ansible variables with the -e flag.
In Example 12-16, you run your first playbook with a full command to specify all
the options that you want this playbook to take into account, and you will simplify it
later.
Example 12-16. Executing an Ansible playbook
$ ansible-playbook snmp-intro.yml \
-i inventory \
-e ansible_user="ntc" \
-e ansible_password="ntc123"
PLAY [PLAY 1 - ISSUE SNMP COMMANDS] *******************************************
TASK [TASK1 - SHOW SNMP COMMANDS] *********************************************
ok: [csr2]
ok: [csr1]
TASK [TASK 2- DEPLOY SNMP COMMANDS] *******************************************
changed: [csr2]
changed: [csr1]
PLAY RECAP ********************************************************************
csr1 : ok=2 changed=1 unreachable=0 failed=0
skipped=0 rescued=0 ignored=0
csr2 : ok=2 changed=1 unreachable=0 failed=0
skipped=0 rescued=0 ignored=0
In the playbook execution output, you can observe a global PLAY section, with TASK_
sections inside. In each task, you identify the hosts, the tasks that have been executed,
and the result. Using the ios_commands, you have not actually changed the configuration,
but by using ios_config, you can check that the result is showing a changed
state. At the end, you can see the summary of the play execution.
You also have the option to not specify the inventory file every time you execute a
playbook. To do this, you can either use the default inventory file /etc/ansible/hosts,
set the ANSIBLE_INVENTORY environment variable, or define it in the ansible.cfg file. In
Example 12-17, we show how to use the environment variable.
Using Ansible | 585
Example 12-17. Setting the ANSIBLE_INVENTORY environment variable
$ export ANSIBLE_INVENTORY=inventory
$ ansible-playbook snmp-intro.yml -e ansible_password="ntc" -e ansible_user="ntc123"
Depending on the scenario, when connecting to the network devices, you may want
to disable host_key_checking for the SSH connections. This is the case in our demo
scenario, where security is not critical. So far, you have not seen how to disable this
option; it is enabled by default. We have chosen to update the Ansible configuration
file (see Example 12-18), but we could have used an environment variable.
Example 12-18. Ansible configuration file
$ cat /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
# omitted other options
You may have already noticed that Ansible has several options for
tuning execution: configuration file, command-line arguments, or
environment variables. Choose what works better for your case.
You have already simplified the playbook execution command, but there are still two
variables. These are implicitly used by network_cli to authenticate to the devices
(ansible_user and ansible_password) that we are passing in the command line
because, being secrets, they should not be stored in the clear-text inventory file.
Luckily, Ansible offers different options to gather secrets, one of which we’ll explore
next.
Using Secrets
The simplest way to define secrets in Ansible is by using Ansible Vault (installed with
the Ansible package), which provides content encryption and decryption capabilities.
We define our secrets in a clear-text file that then is encrypted for storage and
decrypted when we need to use it.
In Example 12-19, you see how from an initial unencrypted file (secrets.enc), you
create an encrypted one that we can use next.
586 | Chapter 12: Automation Tools
Example 12-19. Using secrets in Ansible Vault
$ cat secrets.enc
ansible_user: ntc
ansible_password: ntc123
$
$ ansible-vault encrypt secrets.enc
New Vault password:
Confirm New Vault password:
Encryption successful
$
$ cat secrets.enc
$ANSIBLE_VAULT;1.1;AES256
65303637356337346533333433343935323539373037316534383838353262366530396164613363
6537373434333231343961643037613137393366396161370a313532303132653663656163373539
36393034663965616537303736663437336238633037613665633531306536343962653866333863
3033663062663837380a653931653031646136663030646537666339313636356637663630343030
31353061343539656362376161373339636364643064633438303935366439396434313361383833
3933363863316333663362383435663361306234373036303933
With secrets.enc from Example 12-19, you need to use only the file in your playbook
execution with the -e argument option:
$ ansible-playbook snmp-intro.yml -e @secrets.enc --ask-vault-pass
Vault password:
When using --ask-vault-pass, you will be prompted to enter the password used
to encrypt the file. This is OK(ish) when running playbooks manually, but in an
automated environment, it would be better to use --vault-password-file, which
can take the password from a file that will be created on the fly.
When working with secrets, even if you have them encrypted at
rest, do not forget to protect them from being accidentally leaked
in the Ansible log file—for instance, when using the extra verbose
level of execution (see “Understanding check mode, verbosity, and
limit” on page 597). When your task could output secrets, use
no_log: True to avoid it.
Ansible Vault is only one of the several options for improving the security posture
of your playbook execution. If you have another secrets manager backend, an integration
option would likely be available.
After this brief introduction to secrets, we go deep into how to customize regular
variables for each individual/group from the inventory.
Using Ansible | 587
Using Variable Files
If you understand how to construct an inventory file with groups and variables
and the basics of writing playbooks, you can accomplish quite a bit with Ansible.
However, the inventory file is not the recommended place to keep many variables.
It’s quick and easy for testing, but when managing a production implementation, you
should use variable files (when not using dynamic inventory and a CMDB).
Using variable files requires that you understand their naming. The concept of using
variables is no different from group- and host-based variables in the inventory file—
the only difference is that they are stored in YAML files.
Group-based variable files
To store group variables in YAML files, you must store them in a directory called
group_vars, often in the same directory as your playbooks for basic projects. This is a
special and unique name for Ansible—this directory must be called group_vars.
In the group_vars directory, you have two options. The first and most common for
getting started with Ansible is to have YAML files that are equal to the group names
as they’re defined in the inventory file. When constructing our inventory file, you
had explicitly defined groups such as emea, amers, and iosxe, but also the implicitly
defined group called all. To define variables in these files, you’d need files named
emea.yml, amers.yml, iosxe.yml, and all.yml. These files are required only if you need
to define group variables for that specific group.
Example 12-20 defines group variables for the amers group.
Example 12-20. AMERS group variables
$ cat group_vars/amers.yml
---
snmp:
contact: Joe Smith
location: AMERICAS-NJ
communities:
- community: public
type: ro
- community: public123
type: ro
- community: private
type: rw
- community: secure
type: rw
You would do the same for each group you need to define variables for.
588 | Chapter 12: Automation Tools
As you define more variables for a given group, it may seem logical to want to have
particular variables in their own files—for example, AAA variables in their own, NTP
in their own, and so on. This is the second option.
In this option, you create a subdirectory equal to the group name, and in it, you put
multiple files named whatever you like. Here is an example showing both options:
$ tree group_vars
.
├── amers.yml
└── emea
├── aaa.yml
├── interfaces.yml
└── ntp.yml
1 directory, 4 files
Host-based variable files
Using host-based variable files is exactly like using group variables, but the directory
is called host_vars, and files (or directories) need to match the device name as defined
in the inventory file.
This is an example showing both options, analogous to the previous group variables
example:
$ tree host_vars
.
├── csr1.yml
├── csr2.yml
└── vmx1
├── interfaces.yml
└── ntp.yml
1 directory, 4 files
Now that we’ve covered variables and how to use them in a more robust manner, it’s
time to move on to writing more useful Ansible playbooks.
Writing Ansible Playbooks for Network Automation
At this point, we’ve presented the Ansible architecture, reviewed the Ansible inventory
file and playbook, and introduced common Ansible terminology such as plays,
tasks, modules, parameters, and variables. In this section, we introduce more Ansible
modules and specific Ansible functionality while highlighting what is possible with
Ansible, specifically for network automation. Our focus is on showing how Ansible is
used to automate the following tasks:
• Creating multivendor configuration templates and autogenerating configurations
• Deploying configurations and ensuring that a given configuration exists
Using Ansible | 589
• Gathering data from network devices
• Performing compliance checks
• Generating reports
Breaking down common core network modules
Before we walk through the aforementioned tasks and examples, we need to review
the set of modules that Ansible has for many network vendors and operating systems.
Understanding these modules is critical, as they are included with the Ansible package
and all operate similarly. Ansible has three types of common network modules:
command
Sends exec-level commands to network devices. These are implemented and
named as xos_command (e.g., ios_command, eos_command, junos_command).
config
Sends configuration commands to network devices. These are implemented and
named as xos_config (e.g., ios_config, eos_config, junos_config).
facts
Gathers information from network devices such as OS version, hardware platform,
serial number, hostname, neighbors, and much more. These are implemented
and named as xos_facts (e.g., ios_facts, eos_facts, junos_facts).
With these three modules per network OS, you can accomplish quite a bit with Ansible
for network automation. Each module does have parameters, such as commands,
which we previously looked at (as well as a number of others). We’ll review a few
more of these in our upcoming examples.
To see which parameters a given module supports, along with a
few examples, you can use the ansible-doc utility. For example,
to learn how to use eos_config, you can enter the following command
at your Linux bash prompt:
$ ansible-doc eos_config
> ARISTA.EOS.EOS_CONFIG (/usr/local/lib/python3.8/
site-packages/ansible_collections/arista/eos/plugins/
modules/eos_config.py)
Notice that the eos_config module is a shortcut to
arista.eos.eos_config, part of the arista.eos collection. You
can use the short or the long format.
Since the introduction of Ansible collections (you’ll learn more details in “Using
Third-Party Collections and Modules” on page 611), each collection is defined by
590 | Chapter 12: Automation Tools
a namespace. Some vendors have their own namespaces (such as cisco.nxos and
arista.eos), and others are nested under community.network (such as Nokia SR
modules in community.network.sros_***).
Now that you understand the more common network modules, we’ll walk through
our first real network example.
Creating and using configuration templates
In our first example, the goal is to show that you can use Ansible to autogenerate
SNMP configurations, provided you have SNMP configuration templates and the
associated input data.
The following SNMP CLI commands for IOS are what we want to deploy for IOS,
but the goal is to deploy the same data across Arista EOS, Cisco NX-OS, and Juniper
Junos too. You need to consider this when building out an Ansible project. Here are
the commands:
snmp-server location AMERICAS-NJ
snmp-server contact Joe Smith
snmp-server community public RO
snmp-server community public123 RO
snmp-server community private RW
snmp-server community secure RW
At this point, you need to deconstruct the CLI commands into configuration templates
by using Jinja and YAML files that will store our inputs as variables—more
specifically, group-based variable files.
Since the goal is to support four operating systems, you’re going to need a Jinja
template per network OS. You also need to consider that there could be different
input data for a given geography, which our example happens to have. We are going
to show how to use the same template, but use different data since we have different
SNMP community strings, contacts, and locations per region.
Creating variable files. First, we’ll show our data variables in each respective group
variables file. We already defined the SNMP data for the devices in the AMERS
region in Example 12-20. In Example 12-21, we’ll use the same structure for the data
required for the EMEA region.
Example 12-21. EMEA group variables
$ cat group_vars/emea.yml
---
snmp:
contact: Scott Grady
location: EMEA-IE
communities:
- community: public123
Using Ansible | 591
type: ro
- community: supersecure
type: rw
We aren’t spending time covering the details or data types of a
given YAML variable and how to consume that in Jinja, as this has
already been covered in Chapters 8 and 9.
If you need data to apply to all devices in our inventory, you could use the
group_vars/all.yml file to store it.
Creating Jinja templates. The SNMP data is now defined that’ll be used for configuration
inputs. Next, the associated Jinja templates need to be created. Ansible automatically
looks for templates in the directory your playbooks are executed from and in a
directory called templates relative to the same path. You are going to store the SNMP
templates in ./templates/snmp.
You can prebuild our files per platform as shown here:
$ tree templates/
templates/
└── snmp
├── eos.j2
├── ios.j2
├── junos.j2
└── nxos.j2
Example 12-22 is the template that was constructed in ios.j2.
Example 12-22. IOS SNMP Jinja template
snmp-server location {{ snmp.location }}
snmp-server contact {{ snmp.contact }}
{% for community in snmp.communities %}
snmp-server community {{ community.community }} {{ community.type | upper }}
{% endfor %}
The IOS template is straightforward; however, it does show the use of the Jinja
filter called upper, which capitalizes the type we’ve defined as ro or rw in the
YAML data file. While both work on the IOS CLI, the upper filler translates to RO
and RW when entered into the configuration.
592 | Chapter 12: Automation Tools
Filters are a Jinja feature; refer to Chapter 9 for details. Ansible
comes with extra built-in filters and with an extensible option to
create new custom filters as Ansible plug-ins.
Ansible plug-ins augment Ansible’s core functionality via Python
code and serve several purposes, including filtering, connection,
callback, or inventory, among others. For instance, inventory plugins
allow dynamic inventories, integrating with external data sources.
We don’t cover plug-in development in this book, but you can
get more details from the Ansible docs.
Example 12-23 shows the Juniper template to configure the SNMP data on a Junos
device, stored in junos.j2.
Example 12-23. Junos SNMP Jinja template
set snmp location {{ snmp.location }}
set snmp contact {{ snmp.contact | replace(' ', '_') }}
{% for community in snmp.communities %}
{% if community.type | lower == "rw" %}
set snmp community {{ community.community }} authorization read-write
{% elif community.type | lower == "ro" %}
set snmp community {{ community.community }} authorization read-only
{% endif %}
{% endfor %}
The replace filter is used since Junos doesn’t support spaces in its contact. The
other option is to change the data itself, but we want to show how a template for
one OS compares to a template for another OS.
The lower filter normalizes the community type to lowercase for a convenient
comparison.
A conditional is added because ro and rw aren’t used in Junos commands, and we
need to map our data to the right Junos commands.
The previous Jinja templates, and the EOS and NX-OS ones, are
all available at https://github.com/oreilly-npa-book/examples/tree/v2/
ch12-automationtools/ansible/templates/snmp.
Generating network configuration files. Now that the data variables and templates are in
place, the final step prior to deployment is to generate the SNMP configuration files.
To do this, you’ll use the Ansible module called template. This module automates the
creation of files by rendering input data (variables) with Jinja templates.
Using Ansible | 593
Example 12-24 shows how to use the template module. It uses the src and dest
parameters. The src parameter references the proper template you want to use, and
the dest parameter points to the location where you want the final rendered config to
be stored.
Example 12-24. Generating SNMP configurations by using the template module
---
- name: "PLAY 1 - GENERATE SNMP CONFIGURATIONS"
hosts: "all"
connection: "local"
gather_facts: no
tasks:
- name: "GENERATE CONFIGS FOR EACH OS"
template:
src: "./templates/snmp/{{ ansible_network_os }}.j2"
dest: "./configs/snmp/{{ inventory_hostname }}.cfg"
Uses the local connection instead of ansible.netcommon.network_cli, because
we don’t actually need to connect to any device. Everything is happening locally
to the computer running the playbook.
In our test environment, we manually created the configs directory
and the snmp subdirectory. You could have also automated this
with Ansible by using the file module.
Note in the previous example that you can also use variables within paths, values, or
anywhere else within a playbook. That way, within a single task in a playbook, you
can autogenerate the required configurations for any number of devices regardless of
OS type.
Remember that you added ansible_network_os as a group-based
variable when constructing the inventory file earlier in this section.
This variable name was selected on purpose to be also implicitly
reused by the ansible.netcommon.network_cli connection.
At this point, the playbook is ready to be executed to generate the desired configs.
This is shown in Example 12-25.
594 | Chapter 12: Automation Tools
Example 12-25. Executing the SNMP playbook to generate configurations
$ ansible-playbook snmp.yml -e @secrets.enc --ask-vault-pass
PLAY [PLAY 1 - GENERATE SNMP CONFIGURATIONS] **********************************
TASK [GENERATE CONFIGS FOR EACH OS] *******************************************
changed: [nxos-spine1]
changed: [eos-spine1]
changed: [csr1]
changed: [eos-spine2]
changed: [csr2]
changed: [vmx2]
changed: [vmx1]
# omitted some output
After the playbook is executed, you end up with the following files automatically
created by inserting the proper data variables into the respective Jinja templates. You
can validate the existence of the files by checking the content in the configs/snmp
folder:
$ tree configs/snmp/
configs/snmp/
├── csr1.cfg
├── csr2.cfg
├── eos-spine1.cfg
├── eos-spine2.cfg
├── nxos-spine1.cfg
├── nxos-spine2.cfg
├── vmx1.cfg
└── vmx2.cfg
0 directories, 8 files
To validate that each of the YAML data variables was inserted correctly, let’s see the
outputs for one device in AMERS (csr1), and one device in EMEA (vmx1):
$ cat configs/snmp/csr1.cfg
snmp-server location AMERICAS-NJ
snmp-server contact Joe Smith
snmp-server community public RO
snmp-server community public123 RO
snmp-server community private RW
snmp-server community secure RW
$ cat configs/snmp/vmx1.cfg
set snmp location EMEA-IE
set snmp contact Scott_Grady
set snmp community public123 authorization read-only
set snmp community supersecure authorization read-write
Using Ansible | 595
Creating templates, variables, and a single-task playbook is one of the common ways
to get started with Ansible, as it doesn’t require access to the network devices. It
allows you to gradually hone your Jinja and YAML skills while building and standardizing
network device configurations.
Ensuring that a configuration exists
The previous example automatically generated eight configurations. In this example,
you’re going to deploy those configurations and ensure that they exist on each device.
Understanding idempotency. As you go through this example, pay attention to the
words and phrases being used, such as configuring SNMP versus ensuring that the
SNMP configuration exists. A traditional Python script may send the SNMP commands
every time you execute it. With Ansible, like many DevOps configuration
management tools, the approach for configuration management is to be idempotent,
meaning to make the change only if needed. In the context of networking modules,
each module has added intelligence to ensure that configuration commands are sent
to the device only if they are needed to get the device into its desired state.
From a high level, modules accomplish this by always first collecting the existing
configuration of the device. The commands that you want to exist on the device
are compared against the current state (running configuration). Only if the desired
commands do not exist in the current configuration are they sent to the device. This
is safer in that the module runs a playbook N times and sends the commands to the
device only once.
This is exactly how the config modules work within Ansible. By default, they obtain
a show run, and the commands within the playbook are sent to the device only if they
don’t exist within show run.
Using the config module. Now, let’s extend Example 12-24 into a complete SNMP
provisioning playbook example (snmp.yml). In Example 12-26, you start using the
arista.eos.eos_config module to deploy the SNMP configuration file for the
Arista EOS devices.
Example 12-26. Deploying SNMP commands for Arista devices
- name: "PLAY 2 - ENSURE EOS SNMP CONFIGS ARE DEPLOYED"
hosts: "eos"
connection: local
gather_facts: no
tasks:
- name: "DEPLOY CONFIGS FOR EOS"
arista.eos.eos_config:
src: "./configs/snmp/{{ inventory_hostname }}.cfg"
596 | Chapter 12: Automation Tools
provider:
username: "{{ ansible_user }}"
password: "{{ ansible_password }}"
host: "{{ inventory_hostname }}"
This play was added to the existing playbook that generated the configurations
as shown here, denoted by PLAY 2; we also could have created a new playbook
strictly for deploying configurations.
This play contains its own configuration, with a specific scope defined with
hosts: eos and using the local connection in combination with the provider
parameter within the eos_config module. This method is being deprecated, but
it serves to illustrate that we can combine different connection types per play in
the same playbook.
The config modules accept multiple parameters, while the previous task simply
uses src. The src parameter can reference a config file or a Jinja template
directly. As you can see, you’re referencing the exact file that was generated in the
first play.
The following are other common parameters used in the config modules:
commands
Mutually exclusive with src; rather than reference a template or configuration
file, it allows you to embed a list of commands directly in the playbook.
parents
List of parent commands that identify the hierarchy that commands should
be evaluated against (required when you’re using commands and configuring a
device with commands that go outside global configuration mode). For instance,
an example parent is ['interface Eth1'] and the commands list is ['duplex
full'] when you’re trying to configure duplex on Eth1.
Even more parameters are available for the config modules, such as those that
allow you to issue a particular command before and after issuing the commands
from parents and commands. Remember to use ansible-doc <os>_config to see all
parameters supported and more examples.
Understanding check mode, verbosity, and limit. Before executing the playbook that’ll
create the configurations and deploy them, let’s review a few other features you need
to know when running Ansible playbooks:
Using Ansible | 597
Check mode
This is the ability to run playbooks in dry run mode—the ability to know if
changes will occur. It does everything as you’d expect when running a task, but
does not actually make the given change. To use check mode, add the --check
flag when executing your playbook. Check mode is a feature of individual
modules.
Verbosity
Every module returns JSON data. This JSON data contains metadata about the
task at hand. For the config modules, the data contains the commands being
sent to the device; for command modules, it contains the response from the device.
To run a playbook in verbose mode and see the JSON data returned from each
module, add the -v flag when executing the playbook. You can use up to four v’s
(-vvvv) when troubleshooting.
Limit
The common place to change the devices being automated is in the play definitions
of a playbook by using hosts, such as hosts: all. If you want to automate
just junos devices, one option is to change the playbook scope to hosts: junos.
Of course, this depends on having junos defined in your inventory file. Another
option is to use the --limit flag when executing a playbook, such as --limit
junos. What you pass in with the --limit flag must be in the group or groups
defined already within the hosts key in the playbook. You can also pass in a
single device, group, or multiple of each, as in --limit junos,eos,csr1.
Example 12-27 shows how you can use all three of these flags when running a single
playbook. Using check mode in conjunction with verbose mode is valuable when
deploying configurations—because it shows exactly which commands will get sent to
the device but does not actually deploy them.
Example 12-27. Using limit, check mode, and verbose mode
$ ansible-playbook snmp.yml -e @secrets.enc --ask-vault-pass \
--limit eos-spine1 --check -v
PLAY [PLAY 1 - GENERATE SNMP CONFIGURATIONS] **********************************
TASK [GENERATE CONFIGS FOR EACH OS] *******************************************
ok: [eos-spine1] => {"changed": false,
"checksum": "fd14c0ad92649fd7379316241550429516f62b81",
"dest": "./configs/snmp/eos-spine1.cfg", "gid": 0, "group": "root",
"mode": "0644", "owner": "ntc", "path": "./configs/snmp/eos-spine1.cfg",
"size": 133, "state": "file", "uid": 1000}
PLAY [PLAY 2 - ENSURE EOS SNMP CONFIGS ARE DEPLOYED] **************************
598 | Chapter 12: Automation Tools
TASK [DEPLOY CONFIGS FOR EOS] *************************************************
changed: [eos-spine1] => {"changed": true,
"commands": ["snmp-server location EMEA-IE", "snmp-server contact Scott Grady",
"snmp-server community public123 ro", "snmp-server community supersecure rw"],
"session": "ansible_1650603615", "updates": ["snmp-server location EMEA-IE",
"snmp-server contact Scott Grady", "snmp-server community public123 ro",
"snmp-server community supersecure rw"]}
PLAY RECAP ********************************************************************
eos-spine1 : ok=2 changed=1 unreachable=0 failed=0
skipped=0 rescued=0 ignored=0
As you can see, much more output is displayed because the example is executed in
verbose mode; this allows us to see the JSON data returned by each task and module.
One other important point in reading playbook output is to understand what ok and
changed are referring to. In the previous example, the last line states ok=2 changed=1.
This tells us that two tasks successfully executed but only one made a change (since
this was run in check mode). If you are running a fully idempotent playbook for the
second or more time, you’ll always have changed=0, as no changes would occur.
You can now easily add subsequent plays that’ll deploy the SNMP per OS. Example
12-28 deploys commands for Junos.
Example 12-28. Deploying SNMP commands for Juniper devices
- name: "PLAY 3 - ENSURE JUNOS SNMP CONFIGS ARE DEPLOYED"
hosts: junos
connection: "ansible.netcommon.netconf"
gather_facts: no
tasks:
- name: "DEPLOY CONFIGS FOR JUNOS"
junipernetworks.junos.junos_config:
src: "./configs/snmp/{{ inventory_hostname }}.cfg"
We use the ansible.netcommon.netconf connection because the junos_config
module supports only this connection type. Ansible modules have their own
requirements and should provide useful error messages to guide you in their
usage. This limitation is not for all the junipernetworks.junos collection modules.
Other modules, such as junos_commands, can work with the network_cli
connection.
Then, to complete the SNMP provisioning example, you are missing only Cisco
devices, which you’ll deploy next.
Using Ansible | 599
Filtering tasks with when
In Example 12-29, you use a single play for both Cisco platforms (hosts:
"iosxe,nxos"), so all the play parameters are used for all the tasks. In this case,
you use the same connection type.
Example 12-29. Deploying SNMP commands for Cisco devices
- name: "PLAY 4 - ENSURE CISCO (IOS,NXOS) SNMP CONFIGS ARE DEPLOYED"
hosts: "iosxe,nxos"
connection: "ansible.netcommon.network_cli"
gather_facts: no
tasks:
- name: "DEPLOY CONFIGS FOR IOS"
cisco.ios.ios_config:
src: "./configs/snmp/{{ inventory_hostname }}.cfg"
when: ansible_network_os == 'ios'
- name: "DEPLOY CONFIGS FOR NXOS"
cisco.nxos.nxos_config:
src: "./configs/snmp/{{ inventory_hostname }}.cfg"
when: ansible_network_os == 'nxos'
Even though both Cisco platforms support the same connection type, we have
to use the proper Ansible module for each platform, ios or nxos. Each module
is specialized for one platform type or the other, and running the module on a
different platform could generate errors.
To allow conditional execution of tasks, we can use the when parameter. We use
the ansible_network_os variable, coming from the inventory, to use the proper
module for each NOS.
When executing the playbook, notice that for PLAY 4, you are still targeting all the
hosts (in the iosxe and nxos inventory groups) for each task, but when running each
task, the network devices that do not match the condition will be skipped, as you can
see in Example 12-30.
Example 12-30. Playbook output when filtering out hosts
$ ansible-playbook snmp.yml -e @secrets.enc --ask-vault-pass
# omitted some output
PLAY [PLAY 4 - ENSURE CISCO (IOS,NXOS) SNMP CONFIGS ARE DEPLOYED] *************
TASK [DEPLOY CONFIGS FOR IOS] *************************************************
skipping: [nxos-spine1]
skipping: [nxos-spine2]
600 | Chapter 12: Automation Tools
ok: [csr1]
ok: [csr2]
TASK [DEPLOY CONFIGS FOR NXOS] *************************************************
skipping: [csr1]
skipping: [csr2]
ok: [nxos-spine2]
ok: [nxos-spine1]
Gathering and viewing network data
Ansible, like many automation tools, is often used to deploy configurations. However,
Ansible also makes it possible to automate the collection of data from network
devices. We’re going to focus on two key methods for gathering data: using the core
facts modules and issuing arbitrary show commands with the command module.
Using the core facts modules. Core facts modules return the data in Table 12-1 as
JSON.
Table 12-1. Core facts modules for automating data collection from network devices
Core facts module Result
ansible_net_model The model name returned from the device
ansible_net_serialnum The serial number of the remote device
ansible_net_version The OS version running on the remote device
ansible_net_hostname The configured hostname of the device
ansible_net_config The current active config from the device
ansible_net_all_ipv4_addresses All IPv4 addresses configured on the device
ansible_net_all_ipv6_addresses All IPv6 addresses configured on the device
ansible_net_interfaces A hash of all interfaces running on the system
ansible_net_neighbors The list of LLDP neighbors from the remote device
After running a task to gather facts, you can access each of the previous keys directly
in a playbook or a Jinja template, just like any other variable (usually with double
curly braces). Let’s take a look at Example 12-31, defined in collect.yml.
Example 12-31. Using the ios_facts and debug modules
---
- name: "PLAY 1 - COLLECT FACTS FOR IOS"
hosts: iosxe
connection: "ansible.netcommon.network_cli"
gather_facts: no
tasks:
- name: "COLLECT FACTS FOR EOS"
Using Ansible | 601
cisco.ios.ios_facts:
- name: "DEBUG OS VERSION"
debug:
var: ansible_net_version
- name: "DEBUG HOSTNAME"
debug:
var: ansible_net_hostname
You could optionally add more plays to gather facts per device type based on the OS.
Running the ios_facts module task alone, without verbose mode, will not produce
any output. However, adding the -v when running it will allow you to see all the
data collected in the form of a dictionary. To show the relevant data in the playbook
output, you use the next module: debug.
Using the debug module. To view the facts being returned from the module, you can
run the playbook in verbose mode or simply use the debug module with the var
parameter while referencing a valid facts key, as shown here:
# play definition omitted
- name: "DEBUG OS VERSION"
debug:
var: ansible_net_version
- name: "DEBUG HOSTNAME"
debug:
var: ansible_net_hostname
You usually reference variables with double curly braces within a
playbook and Jinja template. Using the debug module with the var
parameter is one of the times you do not use the curly brace notation!
And remember, any variable in the playbook is also accessible
in a Jinja template.
Running the collect.yml playbook with the task shown before, and limited to only
iosxe devices, produces the output in Example 12-32.
Example 12-32. Viewing facts with the debug module
$ ansible-playbook collect.yml -e @secrets.enc --ask-vault-pass
PLAY [PLAY 1 - COLLECT FACTS FOR IOS] ****************************************
TASK [COLLECT FACTS FOR IOS] *************************************************
ok: [csr2]
ok: [csr1]
602 | Chapter 12: Automation Tools
TASK [DEBUG OS VERSION] ******************************************************
ok: [csr2] => {
"ansible_net_version": "17.01.01"
}
ok: [csr1] => {
"ansible_net_version": "17.01.01"
}
TASK [DEBUG HOSTNAME] ********************************************************
ok: [csr2] => {
"ansible_net_hostname": "csr2"
}
ok: [csr1] => {
"ansible_net_hostname": "csr1"
}
Note the playbook output and the exact variables being referenced in the debug
statements.
Issuing show commands and writing data to a file
You now know how to gather facts and debug the data being returned. In this section,
we perform the same operation, but with the core command module. We’ll show how
to issue show commands, debug the response, and then subsequently write the show
command output to a file.
Remember that one way to view JSON response data from a task is simply executing
the playbook in verbose mode. There is another way that allows you to use the
debug module—to use this approach, you must first save the JSON response from the
module as a variable and then debug that variable. Note that you don’t need to save
facts as a variable since facts are available to use natively within Ansible.
Using the register task attribute. To save the JSON output that is returned from a module,
you use the register task attribute. This allows you to save the JSON response
data as a variable of the dictionary data type.
A task attribute gets inserted on the same indent level as the module name. In
this example, you’ll use the ios_command module, and thus you’ll use the register
attribute as a key on the same indent level as ios_command; register’s associated
value is the variable you want to save the data in. This is shown in the following
snippet from the snmp-debug.yml example:
- name: "ISSUE SHOW COMMAND"
cisco.ios.ios_command:
commands:
- "show run | inc snmp-server community"
register: snmp_data
Using Ansible | 603
After the playbook is executed, the value of snmp_data is the JSON object returned by
the ios_command module, which you also see when running the playbook in verbose
mode.
Since the snmp_data variable is now created, or registered, the debug module can be
used to view the data. In Example 12-33, you see the playbook output for the previous
task after the playbook was executed in verbose mode.
Example 12-33. Viewing the response data from ios_command, limited to csr1
$ ansible-playbook snmp-debug.yml -e @secrets.enc --ask-vault-pass --limit csr1
TASK [TASK1 - SHOW SNMP CONFIG] ***********************************************
ok: [csr1] => {
"changed": false,
"stdout": [
"snmp-server community ntc-public RO\nsnmp-server community ntc-private
RW\nsnmp-server community public RO\nsnmp-server community public123 RO\n
snmp-server community private RW\nsnmp-server community secure RW"
],
"stdout_lines": [
[
"snmp-server community ntc-public RO",
"snmp-server community ntc-private RW",
"snmp-server community public RO",
"snmp-server community public123 RO",
"snmp-server community private RW",
"snmp-server community secure RW"
]
]
}
# omitted some output
When you run the playbook in verbose mode, you can understand the data structure
of the task output, as well as how to access the data desired, to be used in subsequent
tasks. For example, command modules return keys such as stdout and stdout_lines.
Each of those respective values is a list. The stdout key is a list of command responses
with a list length equal to the quantity of commands sent to the device, and
each element is the command response for that particular ordered command. The
stdout_lines key is a nested object: the outer object is a list, and the inner object
changes based on the transport being used—a list for CLI/SSH or a dictionary for
API (such as eAPI). Our focus is on using stdout.
As you can see, using register along with the debug module provides a way to save
and view the response data. This means if you want to debug only the actual response
as a string, you need to use one of the debug statements in Example 12-34.
604 | Chapter 12: Automation Tools
Example 12-34. Using debug with output from register
- name: "DEBUG COMMAND STRING RESPONSE WITH JINJA SHORTHAND SYNTAX"
debug:
var: snmp_data.stdout.0
- name: "DEBUG COMMAND STRING RESPONSE WITH STANDARD PYTHON SYNTAX"
debug:
var: snmp_data['stdout'][0]
Additionally, as we’ve said, any variable in a playbook is also accessible in a template,
so if you want to write the data to a file, you can use the template module with a
basic template like the following:
{{ snmp_data['stdout'][0] }}
You can then use a single task to write the data to a file using the previously defined
template:
- name: "WRITE DATA TO FILE"
template:
src: "basic.j2"
# this template was saved in the templates directory, so there is
# no need to add the implicit ./templates/ folder
dest: "./commands/snmp/{{ inventory_hostname }}.txt"
# the commands and snmp directories were created manually
It’s critical to understand that every module returns JSON, and that data is saved
with the register task attribute. This approach is used not only for debugging data
or writing data to file, but also for performing compliance checks and generating
reports, which we cover next.
Performing compliance checks
Compliance checks are quite often done manually by SSHing into devices and verifying
something is either enabled or disabled, or configured or not configured, in
order to satisfy a given network or security requirement. Automating these types of
checks streamlines the process of ensuring that the configuration and operational
state is always as expected. These checks are always helpful for security engineers
too—for example, when they’re looking to validate that devices are hardened per
requirements.
To perform compliance checks with Ansible, we need to first cover two more
concepts:
set_fact
This module creates an ad hoc variable out of another complex set of data. For
example, if you already registered a new variable that is a large dictionary, you
may care only about a single key-value pair in that object. Using set_fact allows
you to save one of those values as a new fact or variable.
Using Ansible | 605
assert
It’s common in software development to use assert statements for testing to
ensure that a given condition is True or False. In Ansible, you can use the
assert module to ensure that a condition is True or False.
Let’s take a look at an example of asserting that VLAN 20 is configured on our two
Arista EOS switches. The example consists of the following tasks:
1. Gather VLAN data.
2. Save VLAN data as vlan_data.
3. Print (debug) all VLAN data to see what’s being returned.
4. Extract just the VLAN IDs from the full response.
5. Print just the VLAN IDs (validate that the extraction worked as expected).
6. Finally, perform the assertion that VLAN 20 is in the list of VLANs.
Example 12-35 is the associated playbook, defined in compliance.yml.
Example 12-35. Performing a compliance check with assert
---
- name: "PLAY 1 - VLAN COMPLIANCE"
hosts: eos
connection: "ansible.netcommon.network_cli"
gather_facts: no
tasks:
- name: "RETRIEVE VLANS JSON RESPONSE"
arista.eos.eos_command:
commands:
- "show vlan brief | json"
register: vlan_data
- name: "DEBUG VLANS AS JSON"
debug:
var: vlan_data
- name: "CREATE EXISTING_VLANS FACT TO SIMPLIFY ACCESSING VLANS"
set_fact:
existing_vlan_ids: "{{ vlan_data.stdout.0.vlans.keys() }}"
- name: "DEBUG EXISTING VLAN IDs"
debug:
var: existing_vlan_ids
- name: "PERFORM COMPLIANCE CHECKS"
assert:
that:
- "'20' in existing_vlan_ids"
606 | Chapter 12: Automation Tools
Running this playbook produces the output (Example 12-36) for the last task, showing
that the VLAN is configured on eos-spine1 (we did it manually before), but not
on eos-spine2.
Example 12-36. Playbook output from the assert task
$ ansible-playbook compliance.yml -e @secrets.enc --ask-vault-pass --limit eos
# omitted some output
TASK [PERFORM COMPLIANCE CHECKS] **********************************************
fatal: [eos-spine2]: FAILED! => {
"assertion": "'20' in existing_vlan_ids",
"changed": false,
"evaluated_to": false,
"msg": "Assertion failed"
}
ok: [eos-spine1] => {
"changed": false,
"msg": "All assertions passed"
}
Once you understand what data is being returned from a given task and show command,
you can perform an endless number of assertions based on your exact need.
Next, we’ll show how to autogenerate reports from data coming back from devices
too.
Generating reports
This section continues to build on the topic of gathering data. We first showed how
to gather data about device facts, issue show commands, register the data, write the
data to a file, and finally perform assertions. In this section, we’re going to refocus on
writing data to a file, but in the context of generating a report.
Earlier, we showed how to gather facts via the core facts modules. Now, in
Example 12-37, you’ll build three tasks in a single playbook that gathers facts via
eos_facts, ios_facts, and nxos_facts, filtering per NOS, and finally autogenerates
a facts report.
While our report is for device facts, the same approach can be
taken for any data returned from show commands or from any
other variable that exists in an Ansible project.
Using Ansible | 607
Example 12-37. Generating an automated report
---
- name: "PLAY 1 - CREATE REPORTS"
hosts: "iosxe,eos,nxos"
connection: "ansible.netcommon.network_cli"
gather_facts: no
tasks:
- name: "COLLECT FACTS FOR EOS"
arista.eos.eos_facts:
when: ansible_network_os == "eos"
- name: "COLLECT FACTS FOR IOS"
cisco.ios.ios_facts:
when: ansible_network_os == "ios"
- name: "COLLECT FACTS FOR NXOS"
cisco.nxos.nxos_facts:
when: ansible_network_os == "nxos"
- name: "GENERATE DEVICE SPECIFIC REPORTS"
template:
src: "./reports/facts.j2"
dest: "./reports/facts/{{ inventory_hostname }}.md"
- name: "CREATE MAIN REPORT"
assemble:
src: "./reports/facts/"
dest: "./reports/main-report.md"
delimiter: "---"
run_once: "true"
Denotes that this example is automating three groups of devices from the inventory
file.
The template task generates a Markdown-based (.md) report per device.
The assemble module assembles all the individual reports into a single master
report.
The --- in Markdown is a horizontal bar across the page. This is being used as a
device delimiter as the individual reports are combined into the master report.
run_once is, technically, not needed; but remember, we have several hosts being
automated in this play and need only one master report. So we simply tell Ansible
to run the task only for the first device that happens to get automated—since
the module is idempotent, even running it N times without run_once wouldn’t
adversely impact the system.
608 | Chapter 12: Automation Tools
To build on this, we could also include the task attribute called delegate_to and
use the line delegate_to: localhost so the task is run in the system (localhost)
versus running once on the first host automated. At this point, the choice is not
important because both options work and solve the problem.
Example 12-38 shows the template used to generate the facts report.
Example 12-38. Viewing the facts report template, facts.j2
# {{ inventory_hostname }}
## Facts
Serial Number: {{ ansible_net_serialnum }}
OS Version: {{ ansible_net_version }}
## Neighbors
| Device | Local Interface | Neighbor | Neighbor Interface |
|--------|-----------------|----------|--------------------|
{% for interface, neighbors in ansible_net_neighbors.items() %}
{% for neighbor in neighbors %}
| {{ inventory_hostname }} | {{ interface }} | {{ neighbor.host }} |
{{ neighbor.port }} |
{% endfor %}
{% endfor %}
## Interface List
{% for interface in ansible_net_interfaces.keys() %}
- {{ interface }}
{% endfor %}
This syntax builds a Markdown-based table. This renders as an HTML-like table if
you push it to GitHub, view it on Visual Studio Code (covered in Chapter 5), or use a
Markdown viewer.
Most web browsers have plug-ins for viewing Markdown files; you can also easily try
a Markdown editor such as StackEdit.
Viewing the rendered text output for a single device is shown in Example 12-39.
Example 12-39. Generated report as text
# csr1
## Facts
Serial Number: 9SAGBHTUEE9
OS Version: 17.01.01
## Neighbors
Using Ansible | 609
| Device | Local Interface | Neighbor | Neighbor Interface |
| ------ | ---------------- | ------------------- | ------------------ |
| csr1 | GigabitEthernet4 | csr2.ntc.com | GigabitEthernet4 |
| csr1 | GigabitEthernet1 | csr2.ntc.com | GigabitEthernet1 |
| csr1 | GigabitEthernet1 | eos-spine1.ntc.com | Management1 |
| csr1 | GigabitEthernet1 | vmx1 | fxp0 |
| csr1 | GigabitEthernet1 | eos-spine2.ntc.com | Management1 |
| csr1 | GigabitEthernet1 | vmx2 | fxp0 |
## Interface List
- GigabitEthernet4
- GigabitEthernet1
- GigabitEthernet2
- GigabitEthernet3
After pushing the rendered Markdown file to GitHub, you can see how it renders
when viewing it in Visual Studio Code (see Figure 12-2).
Figure 12-2. Viewing the Facts generated report in Visual Studio Code
You can create any kind of templates desired: we’ve looked at configuration templates
and Markdown templates, but you can just as easily create HTML templates too for
ever greater customization.
610 | Chapter 12: Automation Tools
Ansible Roles
In this introductory section to Ansible, we have run simple playbooks, but as your
network automation complexity grows, keeping all the tasks together in one file will
become difficult to manage. To give you the flexibility to enable task composition,
you can use roles. Ansible roles are organized in folders containing their own tasks,
variables, templates, and other information. Thus, you can imagine them as capsules
that you can combine as needed.
Let’s imagine that you create a role for each configuration feature (e.g., SNMP, BGP,
and ACLs) so that in each directory, all the necessary tasks are properly encapsulated,
and you don’t end up with a hundred lines in a YAML file. Then you can simply compose
your playbooks by using the proper roles, depending on your inventory groups.
For instance, you can create a playbook summarizing the configuration management
task, reusing roles as needed:
---
- hosts: "amers-dc,emea-dc"
roles:
- snmp
- bgp
- hosts: "emea-cpe,amers-cpe"
roles:
- snmp
- bgp
- acl
So far, you have used Ansible collections and modules in your playbooks, but now
let’s focus on using others that don’t come by default with the Ansible package.
Using Third-Party Collections and Modules
One of the biggest benefits of Ansible is its active community and how easy is
to reuse others’ work in your own playbooks. While you’ve always been able to
import and use others’ modules, the Ansible 2.9 release (in 2019) introduced a new
distributing artifact, Ansible collections, which can pack together playbooks, roles,
modules, and plug-ins. This packaging facilitates reusing Ansible content within an
organization and also with the community.
The simplest place to find these collections is the Ansible Galaxy hub. Ansible Galaxy
hosts collections from the community, and everyone can contribute with their own
collection, following the contributor guide.
By default, some collections come auto-installed with the Ansible package, but you
can always install a new one or get the latest version of a preinstalled collection.
To help you with this, Ansible comes with an ansible-galaxy CLI tool. It helps by
Using Ansible | 611
installing roles directly from Ansible Galaxy, but also from other sources (such as Git
or a local folder). For instance, you can update the general community collection:
$ ansible-galaxy collection install community.general --upgrade
You can build and distribute your own private collections without leveraging Ansible
Galaxy (you could run your own galaxy server), but the hub is the place to go if you’re
looking to make your collections available to the broader Ansible community.
All the examples we’ve reviewed in this chapter have used Ansible modules included
in the Ansible package. You can accomplish a tremendous amount with these modules,
from configuration to compliance checks to generating reports, as you’ve seen.
However, there is an active community for third-party Ansible modules/collections
relevant to network automation that are not part of the main Ansible package. In
this section, you’ll install third-party collections/modules and review two core sets of
open source third-party modules.
Getting familiar with NAPALM modules
As you will see in “Understanding NAPALM” on page 624, the NAPALM project is
a well-established open source community supporting multivendor network automation
integrations.
The NAPALM collection is available at Ansible Galaxy, so you need to use only the
ansible-galaxy client, as shown in Example 12-40.
Example 12-40. Installing the Ansible NAPALM collection
$ pip3 install napalm
# omitted output
$ ansible-galaxy collection install napalm.napalm
Ansible Galaxy takes care of installing collection dependencies if
they are defined in the collection dependencies metadata. If not,
you will need to install them manually (in this case, the napalm
Python library).
Then, you can list all the available modules, filtering for the NAPALM collection:
$ ansible-doc -l | grep napalm.napalm
# omitted deprecation warnings
napalm.napalm.napalm_cli Executes network device CLI commands and...
napalm.napalm.napalm_diff_yang Return diff of tw...
napalm.napalm.napalm_get_facts Gathers facts from a network dev...
napalm.napalm.napalm_install_config Installs the configuration taken from a ...
napalm.napalm.napalm_parse_yang Parse native config/state from a f...
napalm.napalm.napalm_ping Executes ping on the device and returns...
612 | Chapter 12: Automation Tools
napalm.napalm.napalm_translate_yang Translate a YANG object to native...
napalm.napalm.napalm_validate Performs deployment validat...
The NAPALM Ansible modules use the features offered by the library, mainly for
configuration management (e.g., the napalm_install_config module) and obtaining
configuration and operational state from devices (e.g., the napalm_get_facts
module).
Getting familiar with NTC modules
The company Network to Code made several multivendor Ansible modules open
source a few years ago. Now often referred to as NTC modules, they are available at
Ansible Galaxy as the netauto collection. To install and use NTC modules, you need
to follow the same steps you used with the NAPALM collection when installing the
pyntc library for backend logic.
This suite of modules is most commonly used for two primary reasons:
Automatic parsing of raw text output from legacy devices using prebuilt TextFSM
templates
TextFSM simplifies performing regular expressions on command output. All
templates are also open source on GitHub. This parsing is accomplished with
the ntc_show_command module, which is merely a wrapper for Netmiko and
TextFSM. The module also has an offline mode that allows you to use command
modules, write the data to a file, and still parse that data with this module.
Issuing commands on devices not yet supported by Ansible modules
Because ntc_show_command and ntc_config_command use Netmiko internally,
you can automate any device Netmiko supports (all via SSH). The Netmiko
library supports almost a hundred device types, so the support for these modules
is robust.
Other features are available, such as NOS upgrade management, validation of data
using the JSON schema, or leveraging the jdiff library to examine and compare
structured data.
Both NTC and NAPALM modules are multivendor, and the modules
themselves have a parameter that dictates the OS of the device
being automated. There is not a module per OS as in the previous
examples with a module per vendor.
Using Ansible | 613
Installing third-party collections and modules
As noted earlier, the collection or module you need is likely already available in Galaxy,
so installation should be straightforward (as in Example 12-40), with ansiblegalaxy
collection install name_of_the_collection.
However, you could use collections or modules not available in the Galaxy hub,
including self-developed ones. The installation for third-party open source or custom
collections or modules is also straightforward. Only a few steps are required:
1. Choose a path on your Linux system where you want to store all your third-party
collections or modules (or use the one already defined).
2. Navigate to that path and perform a git clone on each repository that has
collections or modules you want to use.
3. If you chose a different path than the default, you have to update the Ansible
config file (ansible.cfg) and update your collection, or module paths, with the
directory where you performed your clones. As we did in Example 12-1, you
can get all this information with ansible --version. You may find the collec
tions_paths for collections and the library for modules. If not defined, define
collections_paths to point to your target path.
4. Install any dependencies the collections/modules have. These should be documented
on each project’s GitHub site and probably require a few packages to
be installed via pip. If you’re using Python Virtualenv or a system with several
Python versions, you may need to use the ansible_python_interpreter variable
within Ansible.
If the collection is packaged as a tar.gz, you can install it from the
source, defining the destination path:
$ ansible-galaxy collection install /path/to/collection \
-p ./your-collections-folder
Ansible Summary
As you’ve now seen, Ansible is a robust and versatile option for network automation,
from compliance checks and reports to more general configuration management
and automation. Its agentless architecture enables Ansible to have a lower barrier to
entry for network automation. Note that we only scratched the surface by showing
what’s possible when using Ansible. For more information, check out https://docs.ansi
ble.com.
Next, we are going to take a look at Nornir, which takes a different approach to task
automation.
614 | Chapter 12: Automation Tools
Automating with Nornir
Nornir is a Python automation framework born as an alternative to low-code automation
frameworks driven by DSLs, such as Ansible or Salt. While simple ancillary files
like configuration and inventory files still use YAML, the workflows themselves are
defined in Python. This is in contrast to other frameworks, which define workflow
steps (playbooks) in a YAML-based DSL.
Nornir has a Go version, Gornir, but we focus on the Python version
in this section because it has more available options (plug-ins)
to extend it.
Defining all the logic directly in Python comes with four main differences as compared
to the DSL-based automation frameworks:
The barrier of entry
As a network engineer without experience in a programming language, DSL
languages like YAML (covered in Chapter 8) lower the barrier to getting started
versus learning a programming language (e.g., Python) to run Nornir. This
makes tools like Ansible easier to adopt for network engineers coming into
automation. However, there is no need to be an expert Python developer, because
Nornir comes with well-defined abstractions ready to use. After getting started
with Python in Chapter 6, you are ready to go!
Debugging
Once you feel comfortable with a programming language, being able to use the
language debugging tools (e.g. pdb in Python) eases a lot of the development
process. In contrast, a DSL (e.g., YAML) that is being interpreted by another
engine can offer only limited options for debugging (e.g., the Ansible debug
module).
Speed Nornir comes with less overhead than other automation frameworks that need
to serialize DSL definitions (e.g., Ansible YAML playbooks) to the automation
engine (e.g., Python in Ansible). Also, Nornir is really minimalist, so the overhead
is much less than in more opinionated automation frameworks.
Sophisticated logic
Even though automation frameworks using DSLs support some logic customization
(e.g., when or loop keywords in Ansible), the reality is that complex logic is
harder to define in a DSL than in a programming language. Nornir is also easier
to extend, adding new functionalities that can’t be achieved directly with DSLs in
other automation frameworks.
Automating with Nornir | 615
As opposed to Ansible and Terraform (community-based tools
with commercial support by Red Hat and HashiCorp, respectively),
Nornir is a pure community project; thus only community-based
support is available.
In this section, we explain how Nornir works; then we will illustrate how you can
use Nornir with other libraries (NAPALM, in this case) to create capable network
automation solutions.
Getting Started with Nornir
Nornir, a really minimalist and nonopinionated framework, has a few constructs that
we introduce in this section progressively, with examples. You’ll learn to use Nornir to
directly automate your networks via Python code.
The first step, as with other Python libraries, is to install the Nornir
package via pip:
$ pip3 install nornir
$ pip3 list | grep nornir
nornir 3.3.0
Initializing Nornir
Nornir comes with the InitNornir class to bootstrap Nornir and define how it will
behave (Example 12-44 provides more details). Before getting there, Example 12-41
defines a YAML configuration file for Nornir settings. You could define these settings
directly using a Python dictionary.
The following YAML files, and the final Python script, are available
in the examples repository at https://github.com/oreilly-npa-book/
examples/tree/v2/ch12-automationtools/nornir.
Example 12-41. Nornir configuration
---
inventory:
plugin: "SimpleInventory"
options:
host_file: "inventory/hosts.yaml"
group_file: "inventory/groups.yaml"
runner:
plugin: "threaded"
options:
num_workers: 20
616 | Chapter 12: Automation Tools
The inventory section defines how Nornir will build its inventory. The inventory,
similar to an Ansible inventory file, is the reference to the target objects
(e.g., network devices) with all their related data.
Nornir can be extended via various plug-in types. SimpleInventory implements
an inventory that uses local files to define the host, group, and default values.
Every plug-in type comes with different available options.
The runner section defines how the Nornir tasks will be executed.
The default, and most popular, runner option is threaded, which leverages
Python multithreading capabilities to run tasks in multiple threads (num_workers
defines the number of threads to be used in parallel). The actual implementation
is almost identical to the one used in Example 6-11.
Using inventory plug-ins, you can easily integrate Nornir with
external inventory systems that allow fetching data dynamically
without storing it statically in a file. A Nornir inventory plug-in
connects to external APIs and translates the data to Nornir constructs.
“Extending Nornir with plug-ins” on page 622 provides
examples of available inventory plug-ins along with other plug-in
types.
Defining the inventory
Using SimpleInventory, you define two files: one for the hosts and another for the
groups. Comparing these files to those in Ansible, the host file would match the
Ansible inventory and host_vars, and the groups file would match group_vars.
host_file. The host_file file contains a dictionary with all the hosts and with extended
data, such as the platform, access credentials, or any other relevant data per device.
In this section, we reuse exactly the same network scenario from Figure 12-1 to
facilitate the comparison with the Ansible example. An equivalent host_file is shown
in Example 12-42.
Example 12-42. Nornir host_file
---
csr1:
hostname: "csr1"
platform: "ios"
groups:
- "amers-cpe"
vmx1:
Automating with Nornir | 617
hostname: "vmx1"
platform: "junos"
groups:
- "emea-cpe"
eos-spine1:
hostname: "eos-spine1"
platform: "eos"
groups:
- "emea-dc"
nxos-spine1:
hostname: "nxos-spine1"
platform: "nxos"
groups:
- "amers-dc"
data:
ntp_server: "10.1.200.200"
syslog_server: "10.1.200.201"
# omitted one device per type for brevity
This YAML file represents a dictionary in which every item is a network device
in the topology. This key will be used in Nornir to identify each host. The value
of the items is another dictionary. In this inner dictionary, the hostname is a
mandatory key, as it represents the target IP or FQDN.
The platform is convenient to help the connection libraries choose the right
driver when using plug-in connections.
This optional key contains a list of the group names to which a host belongs.
Groups help reuse data across multiple hosts by defining them only once.
data is also optional and contains whatever extra information this host relates to.
In this host_file some basic information is missing on purpose. You may have noticed
that the hosts don’t have any data related to their credentials. This information could
have been defined here, but because all the devices use the same credentials, using
groups makes it simpler.
group_file. The group_file file should match the groups referenced in host_file. So, in
host_file, for the host csr1, you define the amers-cpe group. This group should be
defined here (if not matching, Nornir will complain when initializing).
You may be asking, which groups make sense to define? Well, this depends a lot on
every environment. Let’s examine our implementation in Example 12-43.
618 | Chapter 12: Automation Tools
Example 12-43. Nornir group_file
---
amers-cpe:
groups:
- "global"
emea-cpe:
groups:
- "global"
data:
syslog_server: "10.9.1.1"
amers-dc:
groups:
- "global"
emea-dc:
groups:
- "global"
global:
data:
ntp_server: "10.1.200.199"
syslog_server: "10.1.200.201"
username: "ntc"
password: "ntc123"
In the proposed network topology, the network devices are grouped into four
roles. The amers-cpe group does not contain, for now, any relevant data, but it is
already referencing another group: global.
The emea-cpe group, aside from referencing the global group, has a more
specific syslog_server.
All the groups are referencing a global one that contains the general data and
device credentials (the same for all the devices).
With so many options for merging data, you may be wondering which is the final
state of the data for a given host. If your intuition tells you that the more specific
wins, you’re right. But there’s nothing better than checking it in a real example. Let’s
get hands-on with Nornir (Example 12-44) using the Python interpreter!
Example 12-44. Reviewing the Nornir inventory
>>> from nornir import InitNornir
>>> nr = InitNornir(config_file="config.yaml")
>>> nr.inventory.hosts
{'csr1': Host: csr1, 'csr2': Host: csr2, 'vmx1': Host: vmx1, 'vmx2': Host: vmx2,
'eos-spine1': Host: eos-spine1, 'eos-spine2': Host: eos-spine2,
'nxos-spine1': Host: nxos-spine1, 'nxos-spine2': Host: nxos-spine2}
>>> nr.inventory.groups
Automating with Nornir | 619
{'global': Group: global, 'csr': Group: csr, 'vmx': Group: vmx,
'eos-spine': Group: eos-spine, 'nxos-spine': Group: nxos-spine,
'amers-cpe': Group: amers-cpe, 'emea-cpe': Group: emea-cpe,
'amers-dc': Group: amers-dc, 'emea-dc': Group: emea-dc}
>>> nr.inventory.hosts["nxos-spine1"].platform
'nxos'
>>> nr.inventory.hosts["nxos-spine1"]["syslog_server"]
'10.1.200.201'
>>> nr.inventory.hosts["vmx1"]["syslog_server"]
'10.9.1.1'
>>> nr.filter(platform="ios").inventory.hosts
{'csr1': Host: csr1, 'csr2': Host: csr2}
InitNornir initializes Nornir. We are using config_file, but we could do it directly
with a Python dictionary. Using the configuration from Example 12-41, Nornir
knows how to build the inventory and which runner to use.
Once Nornir is initialized in nr, we can access the defined Hosts and Groups.
This would also be valid for a dynamic inventory instead of a statically defined
one.
Within the inventory, we can navigate the hosts as a Python dictionary and check
which are the attributes—for instance, the platform or the data values (accessed
as a Python dictionary).
When multiple values are available for a host (because of group inheritance), the
merge order is from more specific to more general. For nxos-spine1, the value
of syslog_server is the one defined in hosts.yaml. For vmx1, because the group
emea-cpe has a value and also inherits from the global group, the more specific
(the emea-cpe one) wins.
A useful feature of the Nornir inventory is the filter option, which helps
narrow the scope of Nornir. In the example, only the hosts with the ios platform
are selected, so any related task will be applicable to these devices.
Once the inventory is in place, the fun part begins: running Nornir tasks!
Executing tasks
Apart from the inventory, the other two key constructs in Nornir are tasks and results.
The implementation follows a simple pattern: you define a function that takes as an
attribute the Task (and other arguments) and returns a Result. A Task is a wrapper
around a function that takes a callable (a function) as an argument, together with
other parameters for this function. The task contains a host attribute containing a
Host object from the Nornir inventory, with all its related data. The most important
method implemented is run(), which runs the wrapped function for a specific host
620 | Chapter 12: Automation Tools
and returns the Result containing some attributes such as the diff (the difference
between the state of the system before/after running the task) or the result that is the
output of the task function.
Example 12-45 defines a simple Nornir task. It does not contain any complex logic at
all (but it could have) but will help you understand how to build Nornir tasks.
Example 12-45. Defining Nornir tasks
>>> from nornir.core.task import Task, Result
>>> import time
>>> def check_config(task: Task, feature: str) -> Result:
... # here you could do whatever logic suits to you
... time.sleep(5)
... data_key = f"{feature}_server"
... message = f"{task.host.name} {feature} is {task.host[data_key]}"
... return Result(
... host=task.host,
... result=message,
... )
The Task and Result classes are imported from Nornir, and a new function is
created using them. Notice that we are using Python typing hints to inform about
the expected types.
Adding a sleep time will help to understand task parallelization when running
the task in Example 12-46.
The function can implement any complex logic we decide. We have access to the
Task object that contains all the inventory data related to the host.
Finally, a Result object is returned to the Nornir runner.
Once the task is defined, it is time to use it. In Example 12-46, you use the previously
defined task check_config via the run() method.
Example 12-46. Nornir run() tasks
>>> result = nr.run(task=check_config, feature="ntp")
>>> result["csr1"][0].result
'csr1 ntp is 10.1.200.199'
>>>
>>> from nornir_utils.plugins.functions import print_result
>>> print_result(result)
check_config********************************************************************
* csr1 ** changed : False ******************************************************
vvvv check_config ** changed : False vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv INFO
csr1 ntp is 10.1.200.199
Automating with Nornir | 621
^^^^ END check_config ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* csr2 ** changed : False ******************************************************
vvvv check_config ** changed : False vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv INFO
csr2 ntp is 10.1.200.199
^^^^ END check_config ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# omitted the other devices for brevity
* nxos-spine1 ** changed : False ***********************************************
vvvv check_config ** changed : False vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv INFO
nxos-spine1 ntp is 10.1.200.200
^^^^ END check_config ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The run() method takes as input the function defined and any extra arguments
to this function. Notice that the Nornir object contains the full inventory, and
if the filter method is not used, a task per device will be executed, producing
as many results. Even with the 5 seconds of sleep time inserted in the task (in
Example 12-45), the overall execution time, for the 8 devices, is 5 seconds. In
a serial execution, the overall time would be 40 seconds but, by default, Nornir
runs the tasks in parallel.
Once the Nornir run ends, the result contains one result per inventory host.
Notice that the index 0 is used, because a task could have multiple subtasks (see
Example 12-50).
Nornir has an extra package, nornir-utils, with helper methods such as
print_result, which provides a nice output format. Remember to install it
before using it (pip3 install nornir-utils).
You can observe in the output that every host would use the actual data extracted
from the inventory, after merging all the data available at the host and group
levels.
Extending Nornir with plug-ins
Nornir includes, by default, minimum features but can be easily extended with
third-party plug-ins, such as those available at nornir.tech.
Different types of plug-ins implement different feature types:
Functions
Helper methods around Nornir constructs.
Connection
Defines how to connect to a network device implementing two methods: open()
and close().
Inventory
Creates the inventory objects: hosts, groups, and defaults.
622 | Chapter 12: Automation Tools
Processors
Manipulates task results to adapt to different outcomes.
Tasks
Defines tasks to be used directly in the Nornir run() method. Usually, these tasks
are simple wrappers around a library, exposing the library methods as Nornir
tasks.
Runners
Determines how the tasks will be executed—for instance, you could add a retry
logic if necessary.
To give a glimpse of what you can do with plug-ins, let’s take a look at the Nornir
Nautobot plug-in that offers dynamic inventory, task, and processor features. Install it
with pip3 install nornir-nautobot, and you get access to the plug-in extensions.
Example 12-47 shows how the inventory is pulled from an external source—in this
case, a publicly available Nautobot instance (you’ll learn more info about Nautobot
and other sources of truth in Chapter 14). Finally, with a more complex inventory, we
will demonstrate some advanced filtering options.
Example 12-47. Nornir Nautobot inventory plug-in
>>> nr = InitNornir(
... inventory={
... "plugin": "NautobotInventory",
... "options": {
... "nautobot_url": "https://demo.nautobot.com",
... "nautobot_token": "a" * 40,
... },
... },
... )
>>> len(nr.inventory.hosts)
393
>>> from nornir.core.filter import F
>>> len(nr.filter(F(platform__contains="arista")).inventory.hosts)
345
>>> len(nr.
... filter(F(platform__contains="arista")).
... filter(F(data__pynautobot_dictionary__device_role__slug="edge")).
... inventory.hosts
... )
72
NautobotInventory (instead of SimpleInventory) loads the Nautobot inventory
plug-in.
The Nautobot inventory plug-in comes with options: mandatory ones, like the
URL and token, and optional ones, such as filter_parameters to limit the
Automating with Nornir | 623
scope of devices to load, to narrow the loaded inventory scope (also reducing the
loading time).
The F class allows some advanced filtering patterns, using filter operators (e.g.,
contains or accessing host data).
With __contains, we get all the hosts whose platform contains the word arista.
Nornir filters can be stacked, or filtered on a previous filter. In this case, we limit
the scope to only the device with the edge role for Arista devices.
In the next section, you will learn about nornir-napalm, a Nornir plug-in for the
popular NAPALM library. This plug-in provides tasks for interacting with network
devices from multiple platforms in a homogeneous way.
Using NAPALM with Nornir
This section brings together Nornir with NAPALM to illustrate how to use Nornir
with predefined tasks in a really straightforward way. But, we can’t get to the mixed
example without going a bit deeper with NAPALM first.
In this section, we first cover basic NAPALM concepts while retrieving information
from network devices. Second, we focus on the configuration management feature of
NAPALM combined with the Nornir framework.
Understanding NAPALM
NAPALM, which stands for Network Automation and Programmability Abstraction
Layer with Multivendor support, is a Python library that offers a robust set of operations
for managing network devices via a common set of Python objects, regardless
of how each operation is performed for a given device type. In NAPALM, note that
performing any given operation is the same, which vendor or OS you’re working
with, as long as there is a supported NAPALM driver and feature for the given
operation.
NAPALM supports many device vendors and uses various APIs to communicate
with each. For example, Cisco Nexus uses NX-API and SSH, Arista EOS uses eAPI,
Cisco IOS uses SSH, and the Juniper Junos drivers use NETCONF. When evaluating
NAPALM, you should be aware of which API is required for the device(s) you’re
working with. The core library comes with the support of the most popular APIs, but
you can find extensions for other platforms at the NAPALM Automation Community
Drivers repository on GitHub. Not all drivers have full feature parity, so it’s important
to review each driver’s capabilities to understand what can be done for each platform.
624 | Chapter 12: Automation Tools
For more details on supported APIs and devices, as well as on topics not covered in
this section, consult the NAPALM documentation. For now, we’ll start by looking at
retrieving operational data with NAPALM.
Retrieving operational data with NAPALM
The most common NAPALM feature, when getting started with it, is its capability to
retrieve information from network devices in a uniform fashion. Any data returned
from NAPALM is normalized for all devices in a consistent way.
As you may recall, when we looked at various APIs in Chapter 10, each vendor
or device returns vendor-specific key-value pairs. This is even more relevant when
the information is available only via text from a CLI. Some devices might support
vendor-neutral data models such as YANG models from the IETF or OpenConfig
working group mentioned in Chapter 8, but this is not fully adopted across all
platforms and vendors yet. Thus, NAPALM data normalization helps you with this
heterogeneity.
You can easily install NAPALM via pip:
$ pip3 install napalm
pip3 list | grep napalm
napalm 4.0.0
Getting started with NAPALM is straightforward: select the platform driver, initialize
it, and connect to the device to establish a connection, as shown in Example 12-48.
Example 12-48. Initializing NAPALM
>>> from napalm import get_network_driver
>>> driver = get_network_driver('eos')
>>> device = driver(
... hostname='eos-spine1',
... username='ntc',
... password='ntc123'
... )
>>> device.open()
The get_network_driver() function returns the proper object depending on the
driver identifier (eos corresponds to Arista EOS).
driver is the object that is instantiated with parameters to establish the connection
properly. It accepts optional_args to customize it as needed.
With the open() method, the connection is established and we are ready to
interact with the network device.
Automating with Nornir | 625
At this point, device is a NAPALM device object. Let’s use the dir() function,
which we originally introduced way back in Chapter 6, to see the methods that the
NAPALM device object supports:
>>> dir(device)
[...omitted methods..., 'commit_config', 'compare_config', 'compliance_report',
'config_session', 'confirm_commit', 'connection_tests', 'device', 'discard_config',
'eapi_kwargs', 'get_arp_table', 'get_bgp_config', 'get_bgp_neighbors', 'get_config',
'get_environment', 'get_facts', 'get_firewall_policies', 'get_interfaces',
'get_interfaces_counters', 'get_interfaces_ip', 'get_lldp_neighbors',
'load_merge_candidate', 'load_replace_candidate', 'load_template', 'lock_disable',
'locked', 'open', 'password', 'ping', 'rollback', 'traceroute']
>>>
In this list, you can see some methods for configuration management—e.g.,
load_merge_candidate() and load_replace_candidate())—but most of the methods
are get_ methods used to retrieve information from network devices. We’re going
to use a few of these now.
The first one we’ll look at is get_facts(). This retrieves common information from
the device, such as OS, uptime, interfaces, vendor, model, hostname, and FQDN:
>>> device.get_facts()
{'hostname': 'eos-spine1', 'fqdn': 'eos-spine1.ntc.com', 'vendor': 'Arista',
'model': 'vEOS', 'serial_number': '', 'os_version': '4.22.4M-15583082.4224M',
'uptime': 389825.1441075802, 'interface_list': ['Ethernet1', 'Ethernet2',
'Ethernet3', 'Ethernet4', ...omitted some interfaces..., 'Management1']}
>>>
The great thing about the data returned is that it’s structured exactly the same no
matter which vendor you’re using within NAPALM. In this case, NAPALM is normalizing
and doing the heavy lifting, making it so you don’t need to integrate/translate
each vendor you’re working with. NAPALM is already doing that for you.
Let’s take a look at a few more examples. The get_snmp_information() function
retrieves a dictionary that summarizes the SNMP configuration present on a device:
>>> device.get_snmp_information()
{
'chassis_id': '', 'location': '', 'contact': '',
'community': {'networktocode': {'acl': '', 'mode': 'ro'}}
}
>>>
The get_lldp_neighbors() function provides a dictionary that summarizes a list of
currently seen LLDP neighbors on a per-interface basis:
626 | Chapter 12: Automation Tools
>>> device.get_lldp_neighbors()
{
'Ethernet2': [{'hostname': 'eos-leaf1.ntc.com', 'port': 'Ethernet2'}],
'Ethernet3': [{'hostname': 'eos-leaf2.ntc.com', 'port': 'Ethernet2'}],
'Ethernet4': [{'hostname': 'vmx1', 'port': 'ge-0/0/3'}]
}
>>>
All these functions return a dictionary. We can create a small script to consume and
print the LLDP neighbors dictionary in a human-friendly format:
>>> for interface, neighbors in device.get_lldp_neighbors().items():
... print(f"INTERFACE: {interface}")
... print("NEIGHBORS: ")
... for neighbor in neighbors:
... print(f" - {neighbor["hostname"]}")
...
INTERFACE: Ethernet2
NEIGHBORS:
- eos-leaf1.ntc.com
INTERFACE: Ethernet3
NEIGHBORS:
- eos-leaf2.ntc.com
INTERFACE: Ethernet4
NEIGHBORS:
- vmx1
>>>
Now, we shift gears to, finally, combine NAPALM with Nornir to solve configuration
management challenges at scale.
Configuration management at scale
NAPALM offers two flavors for managing device configurations:
Configuration merge operation
This takes a partial configuration or just a few device commands and ensures that
they exist on the target network device. This works fine for all types of platforms,
including traditional ones.
Configuration replacement operation
Also known as declarative configuration management, the sole focus is on what
you want the device configuration to be. This is in stark contrast to worrying
about what it is, and how to go from what it is to what you want it to be. While
this is a major benefit and feature of NAPALM, it’s actually a by-product of
particular features that exist on the network devices. A few of these device-centric
features include candidate configurations with Juniper, configuration sessions
with Arista, and the config replace feature with Cisco IOS. In essence, we are
declaring what the configuration should be, not worrying about any no or delete
commands.
Automating with Nornir | 627
A configuration replacement requires pushing the full active configuration.
Being able to render a full intended configuration
requires an advanced maturity level of your automation and a
capable source of truth, as we explain in Chapter 14. For this
reason, a configuration merge is usually adopted first in brownfield
network environments and eventually, if supported by the network
infrastructure and the configuration rendering is complete, there is
a shift toward a configuration replacement. This shifting approach
is more realistic for those just starting their automation journey to
manage specific features.
The goal in this configuration management example is to configure a new SNMP
community (secret123) in all Arista devices. Example 12-49 shows how to leverage
Nornir and the NAPALM napalm_configure task, which support both configuration
modes (using the replace argument to choose). Before using the Nornir NAPALM
plug-in, install it with pip3 install nornir-napalm.
Example 12-49. Configuring devices with napalm_configure
>>> from nornir_napalm.plugins.tasks import napalm_configure
>>> from nornir import InitNornir
>>> nr = InitNornir(config_file="config.yaml")
>>> results = nr.filter(platform="eos").run(
... task=napalm_configure,
... dry_run=False,
... replace=False,
... configuration="snmp-server community secret123 rw"
... )
...
>>> print(results["eos-spine1"].diff)
@@ -8,6 +8,7 @@
ip domain-name ntc.com
!
snmp-server community networktocode ro
+snmp-server community secret123 rw
!
spanning-tree mode mstp
!
Using the Nornir filter option, we limit the scope to the Arista EOS devices.
The napalm_configure task is passed as the Nornir task, which will perform a
configuration operation.
The extra options available in Nornir allow a dry_run operation to not commit
the changes. The replace option is set to False by default, but we want to
explicitly define that this is a merge operation.
628 | Chapter 12: Automation Tools
The configuration argument allows passing a string of CLI commands. Alternatively,
it also accepts the filename to pass a file directly.
By accessing the diff attribute, we can review the changes in the configuration.
Using the NAPALM object (device) from Example 12-48, or connecting via SSH, you
can verify that the new SNMP community is there:
>>> device.get_snmp_information()
{
'chassis_id': '', 'location': '', 'contact': '',
'community': {
'networktocode': {'acl': '', 'mode': 'ro'},
'secret123': {'acl': '', 'mode': 'rw'}
}
}
A configuration merge does not purge any commands or specific configuration hierarchy
in a declarative fashion. However, if you know how NAPALM is functioning for
a specific device driver, you can use that information to your advantage to manage a
specific feature declaratively.
Several other plug-ins offer tasks to connect to network devices:
nornir_netmiko, nornir_scrapli, nornir_paramiko, nornir_netconf,
and many more. Check the updated list of Nornir plug-ins.
With all the Nornir features you have learned and your Python skills, you’re ready
to combine them and build more sophisticated workflows. For instance, in Example
12-50, a Python script uses Nornir to render configuration from the inventory
data and configure the proper NTP settings for each device. Remember, this example
is available in the book examples repository.
The Jinja tasks in Nornir are available in the nornir-jinja2 plug-in
that can be installed with pip3 install nornir-jinja2.
Example 12-50. Nornir complete example
from nornir import InitNornir
from nornir.core.task import Result, Task
from nornir_jinja2.plugins.tasks import template_string
from nornir_napalm.plugins.tasks import napalm_configure
from nornir_utils.plugins.functions import print_result
Automating with Nornir | 629
# TEMPLATE represents an option to manage multiple templates per platform
TEMPLATE = {
"eos": "ntp server {{ host['ntp_server'] }}",
"ios": "ntp server {{ host['ntp_server'] }}",
"nxos": "ntp server {{ host['ntp_server'] }}",
"junos": "set system ntp server {{ host['ntp_server'] }}",
}
def config_task(task: Task, template) -> Result:
"""Nornir task that combines two subtasks:
- Render a configuration from a Jinja template
- Push the rendered configuration to the device
"""
render_result = task.run(
task=template_string,
# The right template per platform is selected
template=template[task.host.platform],
)
config_result = task.run(
task=napalm_configure,
# The rendered configuration from the previous subtask is used
# as the configuration input
configuration=render_result.result,
# dry_run means the changes without applying them
dry_run=True,
)
return Result(host=task.host, result=config_result)
# Initialize Nornir inventory from a file
nr = InitNornir(config_file="config.yaml")
# The "config_task" will aggregate two subtasks
result = nr.run(
task=config_task,
template=TEMPLATE,
)
print_result(result)
In the output of this script, you can observe that the main Nornir task executes
two subtasks (and its outputs) per host—one to render the proper configuration per
device, and another to push it to show the potential changes (dry_run is set to True).
Notice how the proper NTP server IP, from our inventory definition, is used in the
configuration rendered here:
$ python example.py
# only showing one output per platform type, others omitted
config_task*********************************************************************
* csr1 ** changed : True *******************************************************
vvvv config_task ** changed : False vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv INFO
MultiResult: [Result: "napalm_configure"]
---- template_string ** changed : False ---------------------------------------- INFO
ntp server 10.1.200.199
630 | Chapter 12: Automation Tools
---- napalm_configure ** changed : True ---------------------------------------- INFO
+ntp server 10.1.200.199
^^^^ END config_task ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* eos-spine1 ** changed : True *************************************************
vvvv config_task ** changed : False vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv INFO
MultiResult: [Result: "napalm_configure"]
---- template_string ** changed : False ---------------------------------------- INFO
ntp server 10.1.200.199
---- napalm_configure ** changed : True ---------------------------------------- INFO
@@ -6,6 +6,8 @@
!
hostname eos-spine1
ip domain-name ntc.com
+!
+ntp server 10.1.200.199
!
snmp-server community networktocode ro
snmp-server community secret123 rw
^^^^ END config_task ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* nxos-spine1 ** changed : True ************************************************
vvvv config_task ** changed : False vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv INFO
MultiResult: [Result: "napalm_configure"]
---- template_string ** changed : False ---------------------------------------- INFO
ntp server 10.1.200.200
---- napalm_configure ** changed : True ---------------------------------------- INFO
ntp server 10.1.200.200
^^^^ END config_task ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
* vmx1 ** changed : True *******************************************************
vvvv config_task ** changed : False vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv INFO
MultiResult: [Result: "napalm_configure"]
---- template_string ** changed : False ---------------------------------------- INFO
set system ntp server 10.1.200.199
---- napalm_configure ** changed : True ---------------------------------------- INFO
[edit system]
+ ntp {
+ server 10.1.200.199;
+ }
^^^^ END config_task ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Nornir Summary
In this section, we covered the basic Nornir concepts—including building an inventory,
defining and running tasks (in a multithread execution), and working with the
results. These are the basic constructs needed to build complex network automation
tasks.
Moreover, the true power of Nornir comes from its extensibility via plug-ins, as
you saw with the NAPALM one. The NAPALM library by itself gives a useful abstraction
of multiple network interfaces and vendors to gain a consistent experience,
both for retrieving the operational state and for changing it. Even though using
Python directly could seem a bit overwhelming when getting started, when you
Automating with Nornir | 631
gain confidence with it, Nornir is a great option for giving you full control of your
network automation tasks.
Finally, in the last section of the chapter, we review how Terraform approaches
infrastructure automation, using a declarative approach.
Managing Dynamic Infrastructure with Terraform
As introduced in Chapter 1, during the 2010s, cloud infrastructure adoption became
mainstream and changed the way we manage IT infrastructure. Now, infrastructure
resources are dynamic and can be spun up on demand and consumed as a service. In
plain language, if we want a MySQL database, we no longer need to physically install
and connect the server and then apply the proper OS configuration to, finally, set
up the MySQL service. In the cloud, you simply do a REST API call to provision a
MySQL service, with some parametrization in the data payload, and in a few seconds
or minutes, your MySQL database will be ready to consume.
The API is, usually, the main entry point for infrastructure management in the cloud,
and the rest of the interfaces, such as CLI, SDKs, or GUIs, are built on top of it.
This new paradigm enables infrastructure as code (IaC): you define in code how your
infrastructure should look, and then tooling interprets it, translating it to API calls.
This is a perfect match for the declarative approach. We define what we want, not how
to get into it as we do with the imperative approach.
The declarative and imperative approaches can still work together.
In some cases, creating a new service is not enough to use it, and
post-provisioning configuration is required. This is how Terraform
and Ansible can complement each other. For instance, Terraform
creates a virtual server, and Ansible connects, once ready, to complete
its configuration and move the server to the desired state.
Recently, an official Terraform integration for Ansible has been
announced, so now you can provision your IaC via Terraform,
and the resulting objects are added to the Ansible inventory to
automate the configuration or additional post-provisioning tasks.
To provide easier use of these APIs, some cloud providers came out with their own
tools to implement this IaC, but as you may guess, with limited coverage for other
infrastructure providers. For instance, AWS, the dominant public cloud provider at
the time of this writing, created AWS CloudFormation, which interprets YAML or
JSON to interact with the proper AWS APIs.
In this context, Terraform was created in 2014 by HashiCorp with the aim to manage
any dynamic infrastructure behind an API. This scope includes any cloud or
on-premises resources that can be managed via APIs. It started with support for
632 | Chapter 12: Automation Tools
some of the most common providers, but its extensibility and easy usage has spread
its adoption as the single tool for managing IaC. Terraform supports more cloud
providers than any other IaC tool and has community-driven extensions for more
than 1,700 providers!
This section covers Terraform key concepts and how they apply in various cases.
We’ll walk through networking-related examples divided into these five areas:
• Understanding Terraform architecture
• Provisioning your first resource with Terraform
• Extending Terraform execution
• Managing Terraform at scale
• Using Terraform out of its comfort zone
We’ll start with an overview of Terraform’s configuration language and then present
the Terraform components and workflow to illustrate the Terraform fundamentals.
Understanding Terraform Architecture
Terraform, like other tooling, introduces new terminology and concepts, and even a
new configuration language, which is our first stop in this journey.
Terraform configuration language
Terraform uses a DSL, the HashiCorp Configuration Language (HCL), like the other
HashiCorp products. It was created as a trade-off between other serialization formats
used to define configurations, such as JSON and YAML, and traditional programming
languages. This combination helps create more sophisticated configurations,
leveraging the declarative pattern.
Even though the HCL DSL is the most popular way to use Terraform,
if you prefer to use a regular programming language, such as
Go or Python, you can use Cloud Development Kit for Terraform,
or CDKTF. The use of programming languages, instead of learning
specific DSLs, is preferred for developers who are familiar with
some of these programming languages. This also allows reusing
all the same toolchains and features they are used to playing with.
Other alternative IaC solutions use this approach, such as AWS
CDK and Pulumi.
From all the HCL features, we will focus solely on the most relevant for its use
in Terraform. HCL has a native syntax, intended to be pleasant to read and write
Managing Dynamic Infrastructure with Terraform | 633
for humans, and a JSON-based variant, easier for machines to generate and parse.
Because we’re humans, our examples use the native syntax.
The two basic syntax constructs are arguments and blocks.
An argument assigns a value to a particular name or variable, and depending on
the context where it is defined, will determine which value types are valid. For
instance, when you learn later about resources, you will find out that each resource
has a schema for its arguments, and it is enforced when assigning the values. In this
example, we are using a string value "192.0.2.0/24" to an argument with the name
cidr_block:
cidr_block = "192.0.2.0/24"
The Terraform documentation uses the term argument, whereas
the HCL documentation uses attribute. In this section, we use
argument for the inputs.
A block is a container for other content, and its extensibility converts Terraform into
a powerful tool to declare complex dynamic infrastructure. HCL supports several
block types. In the following example, the type is resource. The next label, aws_vpc,
specifies the exact resource component, from all the available ones in this context.
This combination, resource and aws_vpc, is what defines the arguments, or other
nested blocks, mandatory or optional. Each has its own definition:
resource "aws_vpc" "my_vpc" {
cidr_block = "192.0.2.0/24"
}
Besides arguments and blocks, HCL also has identifiers, used to identify the arguments,
blocks, and other Terraform constructs that you will discover in this section.
Identifiers are the argument names (cidr_block), block type names (aws_vpc), and
block names (my_vpc). They allow the configuration files to reuse all these components
in multiple places. For instance, you could use the my_vpc identifier to connect
other resources to it.
Finally, as most languages do, HCL provides support for comments. It has three
syntaxes: # and // for single-line comments, and /* ... */ for multiline ones:
# This argument defines the CIDR for our Amazon VPC
// And the next one is for multiple lines
/*
This is a multiline comment
*/
cidr_block = "192.0.2.0/24"
634 | Chapter 12: Automation Tools
After this brief introduction to the basic concepts of HCL, let’s dive into Terraform’s
own terminology of key concepts.
Terraform in a nutshell
The Terraform process is built on top of basic components that you will discover,
progressively, throughout this section. In Figure 12-3, we give you a 1,000-foot
overview to help you visualize them, and, afterward, a short description.
Figure 12-3. Terraform components
Let’s walk through each Terraform component used in the Terraform configuration
file to define the expected status of the IaC:
Providers
Plug-ins created to interact with the APIs from dynamic infrastructure providers.
They can be in read mode (data sources) or write mode (resources).
Variables
Parameters with values for customizing the behavior of Terraform configurations.
Terraform
Software providing the commands to implement the Terraform workflow that
manages the dynamic infrastructure.
Outputs
Explicit information exposed after Terraform execution. It can be used as input
variables for other Terraform executions.
State
Binds the Terraform definition to the infrastructure. The state includes reading
from the actual infrastructure plus tracking the new services added in order to
maintain a mapping between the plan and the reality. Then, when Terraform
runs again, it doesn’t start from scratch and can be aware of already existing
services that may need to be updated (instead of created from scratch).
Managing Dynamic Infrastructure with Terraform | 635
Infrastructure changes
The infrastructure services created in the target dynamic infrastructure provider.
Next, you need to understand the Terraform workflow to manage the whole dynamic
infrastructure lifecycle.
Terraform workflow
Terraform has a simple and well-defined workflow, from writing the configuration
to deploying the dynamic infrastructure. In the official documentation, the core Terraform
workflow is composed of three steps (write, plan, and apply), but we extend it
to five here to better explain the whole cycle (Figure 12-4).
Figure 12-4. Terraform workflow
The five workflow steps are as follows:
Write
Define the desired infrastructure state by using the Terraform configuration language.
This stage also contains the information required to initialize Terraform.
Init
Initialize the environment, installing the necessary plug-ins, modules, and backends,
according to the configuration defined in the write step.
Plan
Create an execution plan, in dry-run mode, describing all the changes that your
configuration will translate into the target infrastructure.
Apply
Enforce the desired state in the real infrastructure. This step is the same as plan,
but not in dry-run mode.
Destroy
Deprovision the managed infrastructure.
Except for write, the rest of the workflow steps map to Terraform main commands.
Actually, we could map the write step to the validate command, used to review the
written configuration.
636 | Chapter 12: Automation Tools
Make sure you have Terraform installed to continue progressing in
this section. Instructions can be found at https://oreil.ly/pMgds. All
these examples have been run using Terraform v1.2.0.
You can check these main commands with terraform -help:
$ terraform -help
Usage: terraform [global options] <subcommand> [args]
The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.
Main commands:
init Prepare your working directory for other commands
validate Check whether the configuration is valid
plan Show changes required by the current configuration
apply Create or update infrastructure
destroy Destroy previously-created infrastructure
With this overall understanding in place, it is time for the hands-on part of the
section, where you will learn all the key Terraform concepts through a concrete
networking example.
Provisioning Your First Resource with Terraform
There is no better way to understand how Terraform works than actually using it.
Following the leitmotif of the book, we will use a cloud networking–related example
(Chapter 4 provides more details) to illustrate the use of Terraform. From the multiple
available options, we choose AWS as our cloud provider because it is the most
popular public cloud (generally available) and offers great documentation for both
API and Terraform. However, the same concepts and approach could be used in any
other provider supported in Terraform—for instance, other public clouds, such as
Microsoft Azure or GCP, or private ones, such as VMware or OpenStack.
To get started, you will create a basic networking setup: a virtual network and two
subnets, as depicted in Figure 12-5. In the AWS platform, a virtual network is named
Amazon Virtual Private Cloud (VPC).
Managing Dynamic Infrastructure with Terraform | 637
Figure 12-5. AWS network scenario
Setting up an AWS free account
You can use any AWS account, but if you don’t have one, you can create a free
account at AWS Free Tier.
To interact with the AWS platform and to check the resulting infrastructure managed
by Terraform, we will use the AWS CLI. However, the very same outcomes could be
seen in the GUI, if you choose to use it.
First, in Example 12-51, you install the AWS CLI for your particular OS, and configure
it by running aws configure.
Example 12-51. Configuring the AWS CLI
$ aws configure
AWS Access Key ID [None]: Your Access Key ID
AWS Secret Access Key [None]: Your Secret Access Key
Default region name [None]: us-west-1
Default output format [None]:
The requested access key ID and secret access key are the security credentials to
identify your account and get programmatic access. Keep in mind that these credentials
have to be managed properly, following security measures (e.g., rotating and
encrypting). You can use any credentials you already created or create new ones in
the AWS GUI:
"Identity and Access Management (IAM)" -> "Dashboard" -> "Manage access keys"
From now on, you can review the status of our AWS infrastructure via the AWS
CLI. To double-check that the setup is right, you can run the aws sts get-calleridentity
command, and it will return your account information:
$ aws sts get-caller-identity
{
"UserId": "123456789012",
"Account": "123456789012",
"Arn": "arn:aws:iam::123456789012:root"
}
638 | Chapter 12: Automation Tools
For this example, we used a root account for a personal account
for simplicity. This is strongly discouraged in a proper AWS environment;
following the principle of least privilege, a user with the
minimum required access should be used.
Now that your AWS CLI is ready to go, you can start writing your first Terraform
configuration snippet.
Using Terraform providers
Following the steps in “Terraform workflow” on page 636, the initial stage is to
write the configuration, declaring the infrastructure you want to provision. In our
example, you will start first with the Amazon VPC because it’s the logical step for
later including subnets.
To write the configuration, you need one or more files. In Terraform, the directory
from where we are running determines the context, and all the files with the extension
*.tf, in the top-level directory, will be seen as part of the Terraform configuration.
The name of these files is not relevant, so you can name them as desired. This folder
is also used to store other relevant files related to Terraform execution, as you will
discover later.
Terraform configuration can be written in native syntax, for
humans, or also in a JSON variant. In JSON, the extension of the
configuration files is *.tf.json.
Then, you create a new directory and a new Terraform file (for instance, 01-createvpc/
create_vpc.tf), where you will start defining the Terraform configuration:
$ tree
.
└── 1-create-vpc
└── create_vpc.tf
For simplicity, we keep all the Terraform configurations in one file.
But, in real scenarios, it’s common to have different files, serving
different purposes.
The first configuration you need in Terraform is for the provider. Terraform providers
implement all the logic to translate from HCL to each infrastructure platform
API. Selecting one provider or another in the configuration will allow you to use
its resources and data sources in the configuration. Because we want to provision
Managing Dynamic Infrastructure with Terraform | 639
an Amazon VPC, we have to use the aws Terraform provider. The same approach
applies to other providers: you define the Terraform providers in the configuration,
depending on the platforms you have to manage.
Luckily, most dynamic infrastructure providers have officially supported Terraform
providers, published in the Terraform Registry. There, you can also find documentation
about how to use its configuration blocks and arguments.
The Terraform provider configuration is composed of two parts.
First, under the global terraform block (used to configure Terraform’s own behavior),
a nested block, required_providers, defines a mapping between the local name
of the provider (in this case, aws) and the location where it can be found, with the
source argument (in this case, the Terraform Registry hashicorp/aws). Finally, to pin
a specific version, you set the version argument with the proper version number.
Then, in a second block, provider, you configure the provider defined in the first
block. Here, you have access to the arguments described in this specific provider. For
instance, for hashicorp/aws, it is necessary to define only one argument, the region.
Example 12-52 shows both blocks combined.
Example 12-52. Defining and configuring the AWS Terraform provider
# Configure Terraform to find the right Provider
terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.0"
}
}
}
# Configure the aws Provider
provider "aws" {
region = "eu-west-3"
}
You can compare Terraform providers with Ansible modules or Nornir plug-ins.
They extend Terraform’s functionality to be able to work with a particular dynamic
infrastructure provider.
In Terraform, providers are written in Go. Defining custom providers, or extending
them, is doable but likely not something you will need to do. Typically, cloud providers
create and evolve these plug-ins to make them available to everyone, to ease the
consumption of their services.
The providers block in the configuration has a big impact on the rest of the configuration.
When you reference a provider in the Terraform file, you get access to
640 | Chapter 12: Automation Tools
the related resources. Also, note that you can have multiple providers in the same
Terraform configuration. This will be the case when multiple cloud environments are
provisioned from the same configuration file.
With this initial setup, you have written the foundations of your configuration.
However, during the initial write stage, there is always the chance for a syntax error.
Even though the configuration is correct, you will learn next how to discover errors
during this early stage.
Validating the Terraform syntax
To check the correctness of the Terraform configuration syntax, Terraform offers the
validate command, which explores your configuration files, checking for inconsistent
definitions. For instance, if in Example 12-52 you remove the ending curly brace
in the last line and execute the terraform validation command, you will see an
error and the reason for it:
$ terraform validate
│
│ Error: Unclosed configuration block
│
│ on create_vpc.tf line 11, in provider "aws":
│ 11: provider "aws" {
│
│ There is no closing brace for this block before the end of the file. This
| may be caused by incorrect brace nesting elsewhere in this file.
Now, if you put the curly brace back in, your code will have the correct syntax.
However, if you execute terraform validate again, you will find an unexpected
error. The configuration requires a Terraform provider that it is not yet available:
$ terraform validate
│
│ Error: Missing required provider
│
│ This configuration requires provider registry.terraform.io/hashicorp/aws,
| but that provider isn't available. You may be able to install it
| automatically by running:
│ terraform init
│
You receive this error because, in the configuration, you pointed to a provider from
the registry—but not one locally available. Solving this validation error is the point of
the next stage in the Terraform workflow, the init.
Initializing the Terraform environment
In the configuration, you have defined the Terraform provider to use, but this just
provides the intent; you have not yet made it available locally. You can compare this
Managing Dynamic Infrastructure with Terraform | 641
to using a Python library: to run the code, it’s not enough to import the library. You
need to install the library locally to make it available to the interpreter.
Example 12-53 installs Terraform providers by running the terraform init command,
which reads the configuration defined under the required_providers nested
block and downloads all the necessary dependencies.
Example 12-53. Initializing the Terraform configuration
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Installing hashicorp/aws v3.75.2...
- Installed hashicorp/aws v3.75.2 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.
Terraform has been successfully initialized!
# some output trimmed
The backend has been initialized. The backend, in Terraform, is the place to
store the Terraform State, which you will learn more about later. By default, if
not defined differently, it is the local directory from where you run Terraform
commands.
The Terraform provider plug-in, hashicorp/aws, has been found and installed
using the version specified.
A lock file, .terraform.lock.hcl, has been created to lock the pinned version of the
plug-in.
Pinning Terraform provider versions ensures the behavior of subsequent
Terraform runs. Without pinning, the provider version
could change when a newer one is available and still compatible
with the definition (in the example, we get version 3.75.2, compatible
with 3.*), and with it the actual outcome of our Terraform
configuration.
You can check all the changes mentioned in the output, listing the files and folders in
the local directory, including the hidden ones:
642 | Chapter 12: Automation Tools
$ tree -la
.
├── .terraform
│ └── providers
│ └── registry.terraform.io
│ └── hashicorp
│ └── aws
│ └── 3.75.2
│ └── darwin_amd64
│ └── terraform-provider-aws_v3.75.2_x5
├── .terraform.lock.hcl
└── create_vpc.tf
You can see the initial Terraform configuration file, which we named create_vpc.tf,
and the versioning lock file .terraform.lock.hcl. Then, within the .terraform directory,
the provider that has been installed locally uses version 3.75.2.
After initializing the environment, according to the Terraform configuration, you are
in a good spot to get a successful validation, so let’s check it:
$ terraform validate
Success! The configuration is valid.
Nice! You have a valid Terraform configuration, properly initialized. So, you are ready
to jump into the next Terraform workflow stage, the plan.
Getting insights into Terraform changes
The terraform plan command checks whether the desired state of the infrastructure,
described in our Terraform configuration, matches the actual state.
Even though you have not already defined the configuration for the Amazon VPC,
you can try the command, to validate the proper access to the target infrastructure
provider API:
$ terraform plan
No changes. Your infrastructure matches the configuration.
Terraform has compared your real infrastructure against your configuration and
found no differences, so no changes are needed.
As expected, no changes are required. This is due to having a Terraform configuration
that defines only the Terraform provider to use but not any infrastructure
element to provision, and that has no reference state. You will learn about the
Terraform state later.
However, terraform plan is giving you an important implicit validation. Terraform
connects to the target infrastructure provider API, and this connection requires
proper authentication. So, running terraform plan successfully is, at least, validating
that you have access to the platform.
Managing Dynamic Infrastructure with Terraform | 643
In the example, we have not explicitly provided any authentication
credentials to the provider configuration block. This is because the
AWS Terraform provider implicitly uses the same authentication
used by the AWS CLI, which we initialized in Example 12-51.
At this point, you are ready to start defining the infrastructure. So, the next concept
to introduce is the Terraform resource. A resource defines an object that you are
declaring should exist in the target infrastructure. It is defined using the resource
Terraform block type and the syntax used in Example 12-54.
Example 12-54. Terraform resource definition
resource resource_name resource_identifier {
...
}
Name of the resource as defined in the Terraform provider, which should be
properly initialized. Its usage should be detailed in the provider documentation,
explaining all the available arguments.
Identifier of this resource in the Terraform configuration, so we can reference
this specific resource later.
To create the Amazon VPC, you write a new resource block of type aws_vpc and an
identifier—for instance, my_vpc. From the multiple arguments available, let’s define
the cidr_block, because it’s the only one mandatory. As noted previously, for simplicity,
you can use the same file where the provider is configured:
...
# Create a VPC
resource "aws_vpc" "my_vpc" {
cidr_block = "192.0.2.0/24"
}
Looks simple, no? To create an Amazon VPC, using the Terraform declarative
approach, you define its final state with only one parameter! This is possible because
of hiding the low-level details and exposing only the key attributes necessary to
define the final state of the infrastructure service.
Now, the Terraform configuration contains the intent to have an Amazon VPC. Thus,
it’s time to run terraform plan again in Example 12-55 and check the outcome of its
execution. In this output, you can observe the expected changes in the infrastructure
due to applying this configuration.
644 | Chapter 12: Automation Tools
Example 12-55. terraform plan with changes
$ terraform plan
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
+ create
Terraform will perform the following actions:
# aws_vpc.my_vpc will be created
+ resource "aws_vpc" "my_vpc" {
+ arn = (known after apply)
+ cidr_block = "192.0.2.0/24"
+ default_network_acl_id = (known after apply)
+ default_route_table_id = (known after apply)
+ default_security_group_id = (known after apply)
+ dhcp_options_id = (known after apply)
+ enable_classiclink = (known after apply)
+ enable_classiclink_dns_support = (known after apply)
+ enable_dns_hostnames = (known after apply)
+ enable_dns_support = true
+ id = (known after apply)
+ instance_tenancy = "default"
+ ipv6_association_id = (known after apply)
+ ipv6_cidr_block = (known after apply)
+ ipv6_cidr_block_network_border_group = (known after apply)
+ main_route_table_id = (known after apply)
+ owner_id = (known after apply)
+ tags_all = (known after apply)
}
Plan: 1 to add, 0 to change, 0 to destroy.
───────────────────────────────────────────────────────────────────────────────
Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
The list contains all the arguments supported by this resource in the Terraform
provider implementation.
Several attributes are set to known after apply. This is because these values
are not known until the resource is created. For instance, the value generated to
identify the object in AWS, named arn, is available only after it’s created; we’re
only planning at this point.
Remember that we provided only the cidr_block but, in this output, you can
see other attributes taking a default value, such as enable_dns_support with the
default value true.
Managing Dynamic Infrastructure with Terraform | 645
When we apply this Terraform configuration with the current target infrastructure
state, a new resource, defined as aws_vpc, will be added.
The plan step is really useful to understand what is going to change, before actually
changing the infrastructure state. This step can give you good insight into the impact
of the configuration so you can take the necessary actions to adapt it to your real
intent. However, as the last Note in the plan output suggests, it can’t guarantee that
the state of the target infrastructure will be exactly the same when you move to
the next step, apply. This is the reason that when you run terraform apply, you
are implicitly running a terraform plan before, and a manual confirmation is, by
default, requested.
However, you can skip the manual confirmation when applying if you use, as a
reference, the output of a plan generated using the option -out name_of_plan.
This output reference skips the prompt to confirm because it has a reference, to
understand whether the plan output is the expected one and proceed, or a different
one and abort. Example 12-56 shows how to use -out.
Example 12-56. terraform plan using -out
$ terraform plan -out my_plan
# output trimmed, same as above
Saved the plan to: my_plan
To perform exactly these actions, run the following command to apply:
terraform apply "my_plan"
The result of the -out option is a binary file created in the Terraform backend—
in our case, the local directory. It contains all the information needed to compare
against another plan output later.
Now, understanding the role of the plan in the Terraform workflow, you can move
to the next step, apply, which will, finally, provision the dynamic infrastructure in the
target platform.
Applying the Terraform configuration
Managing the dynamic infrastructure state is the main purpose of Terraform: moving
from a configuration written in a declarative approach to actual infrastructure services
provisioned in the cloud platform. The Terraform command for this purpose is
terraform apply. This command runs a plan before, showing what would change,
and then prompts for a manual confirmation, which you will decline for now by
answering “No” to the prompt:
646 | Chapter 12: Automation Tools
$ terraform apply
# output trimmed, similar to plan
Plan: 1 to add, 0 to change, 0 to destroy.
Do you want to perform these actions?
Terraform will perform the actions described above.
Only 'yes' will be accepted to approve.
As expected, the output of the plan is the same as that from terraform plan. Because
we have not provided a reference plan, we are prompted for manual approval.
This works fine for development, but when automating Terraform, you will want
to skip the user interaction—and that’s where the reference plan you created in
Example 12-56 comes in. Now, you can use the my_plan reference in the terraform
apply command to skip the output of the plan, and be able to compare the current
planned output with the previously generated output. If both plans match, the apply
action is executed (Example 12-57).
Example 12-57. terraform apply with a plan reference
$ terraform apply "my_plan"
aws_vpc.my_vpc: Creating...
aws_vpc.my_vpc: Creation complete after 3s [id=vpc-04f21f46af099b516]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
Voilà! You’ve created your first resource via Terraform, an Amazon VPC! At least,
this is what Terraform says in its output. You can see the AWS identifier for the new
resource, the id. Using this id, you can verify that the infrastructure service has been
created in the AWS cloud platform.
In Example 12-58, we use the aws ec2 describe-vpcs CLI command, specifying the
VPC id from the previous output and the region to look for. The region is the only
argument we specified in the aws provider configuration, and it’s a concept in AWS
used to create isolated infrastructure domains behind the same API interface.
Example 12-58. Verifying the creation of the Amazon VPC
$ aws ec2 describe-vpcs --region eu-west-3 --vpc-ids vpc-04f21f46af099b516
{
"Vpcs": [
{
"CidrBlock": "192.0.2.0/24",
"DhcpOptionsId": "dopt-4f17a126",
"State": "available",
"VpcId": "vpc-04f21f46af099b516",
"OwnerId": "123456789012",
"InstanceTenancy": "default",
"CidrBlockAssociationSet": [
Managing Dynamic Infrastructure with Terraform | 647
{
"AssociationId": "vpc-cidr-assoc-04285027d194e35c3",
"CidrBlock": "192.0.2.0/24",
"CidrBlockState": {
"State": "associated"
}
}
],
"IsDefault": false
}
]
}
From the AWS CLI command output information, you can see the proper IP prefix
in place, as well as other information not specified in the configuration. Especially
noticeable are the references to other objects, such as DhcpOptionsId and CidrBlock
AssociationSet. These are other infrastructure objects required by the VPC, but this
was abstracted by the AWS API and not explicitly defined.
You can also check that now, after the applying step, the Terraform configuration
is fully in sync with the target infrastructure. You can validate this by running
terraform plan again and discovering that No changes are pending:
$ terraform plan
aws_vpc.my_vpc: Refreshing state... [id=vpc-04f21f46af099b516]
No changes. Your infrastructure matches the configuration.
Terraform has compared your real infrastructure against your configuration and
found no differences, so no changes are needed.
You might notice something relevant in this output. The conclusion of no changes
comes after reviewing the state. An important component in Terraform architecture,
the Terraform state keeps track of the relationship between its configuration and the
actual infrastructure, and this is our next topic.
Understanding Terraform state
The Terraform state is a mapping between the Terraform configuration and the
real-world resources created from it. This information helps Terraform understand
the resources it is managing, without impacting other resources that may be running
in the remote infrastructure that could have been created via GUI, API, or from
another Terraform configuration.
The Terraform state is stored in the terraform.tfstate file using a custom JSON format.
This file contains metadata. The resources key, a list of all the resources managed
by Terraform, is especially relevant. This list includes not only created resources but
also others that may have been imported, as you will see later. The bindings between
the real objects and the resources defined in the configuration are done via both
identifiers, the Terraform and the remote infrastructure ones.
648 | Chapter 12: Automation Tools
In the resource configuration, you used two identifiers for the Amazon VPC, the
resource type and the name: resource "aws_vpc" "my_vpc". These identifiers are
two keys in the resource dictionary, and under the instances key, we find the
reference to the actual infrastructure object created in AWS, with its own id:
# some output trimmed
{
"resources": [
{
"mode": "managed",
"type": "aws_vpc",
"name": "my_vpc",
"provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
"instances": [
{
"attributes": {
"id": "vpc-04f21f46af099b516",
...
As you can imagine, this state is a onetime picture of the infrastructure. Terraform
can’t rely 100% on it, because since it was generated, the actual state could have
changed for many reasons. So, before every Terraform operation, plan or apply, a
refresh step is executed, updating the state before running. You can also validate the
state with the sole terraform refresh command, which will check for any difference
between the actual infrastructure and the backend state:
$ terraform refresh
aws_vpc.my_vpc: Refreshing state... [id=vpc-04f21f46af099b516]
Without a state reference, as happens when you do the first apply, Terraform doesn’t
have any reference mapping between its configuration and the infrastructure state,
so it will try to provision all the resources. You can test this behavior by running ter
raform apply twice, removing the state between the apply commands. You will end
up with two resources with a duplicated configuration. With this simple exercise, you
can understand how critical it is to ensure the Terraform state integrity, so the state
reflects the changes that the Terraform configuration has done in the infrastructure
provider.
But integrity is not enough. You also need to make the state available for all the
potential Terraform actors that could intervene in the workflow execution. In production
environments—for instance, during a pipeline execution that would spin up
a process in a virtual server or container—it’s common practice to run Terraform
from different places. These different actors need to share access to the same state, so
both know about the other changes.
However, providing availability and integrity at the same time is difficult. Let’s imagine
that two Terraform processes, sharing the same state, want to update it. This puts
the integrity of the state at risk. Luckily, Terraform offers a locking mechanism to
avoid potential race conditions. In the local environment, when you run a Terraform
Managing Dynamic Infrastructure with Terraform | 649
command, it locks the file, so other concurrent processes will complain about locking
if trying to update the state.
Finally, the other key aspect of the Terraform state is security. State files are stored in
plain text. But this file can include resources storing sensitive data—for instance, a
database user and password. We should consider protecting the state, via encryption,
in transit and in rest.
One common approach when starting with Terraform is to store the state in a version
control system (e.g., Git), together with the Terraform configuration. This provides
some level of availability. However, this is not a recommended option because it
doesn’t grant integrity and security.
To solve all these requirements together, Terraform introduces the concept of
backends to store its state. A Terraform backend can be implemented in multiple
ways, using distributed systems that offer availability with locking mechanisms, and
encryption in transit and at rest. The default backend is the local directory, and it’s
the one you have been using in this book. Many other options are available, but we
don’t cover them in detail here. Check the Terraform documentation for detailed
information.
Even still, despite taking all the precautions, you could lose the Terraform state of
your configuration. However, even in that case, not everything would be lost for our
infrastructure. Terraform offers a remediation option: the import command.
Remediating Terraform state
If you have lost your Terraform state or start managing an infrastructure that was
provisioned outside your Terraform configuration, you can re-create the state mapping
between the configuration and the real infrastructure.
The terraform import command serves to connect, via a mapping in the state, a real
infrastructure object and a Terraform resource. The logic necessary to establish this
mapping is also specific for each provider.
Following our example, you could have provisioned the Amazon VPC and then lost
or removed the state. To reimport the state, you need to know only both identifiers,
the infrastructure and Terraform. In the Amazon VPC example, on one side we
have the VPC id, and on the other the resource with the type and the configuration
identifier:
terraform import aws_vpc.my_vpc vpc-04f21f46af099b516
aws_vpc.my_vpc: Importing from ID "vpc-04f21f46af099b516"...
aws_vpc.my_vpc: Import prepared!
Prepared aws_vpc for import
aws_vpc.my_vpc: Refreshing state... [id=vpc-04f21f46af099b516]
Import successful!
650 | Chapter 12: Automation Tools
The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
After running terraform import, you can see how the state file has been created,
or updated, accordingly. Then you can continue managing this resource from Terraform,
as it was created by Terraform itself.
To complete the infrastructure management lifecycle, after provisioning, there will
be deprovisioning. The dynamic infrastructure has, because of its nature, a shorter
lifecycle than the traditional one, and the last Terraform workflow stage is for this.
Cleaning up infrastructure with Terraform
In the same way that you use Terraform to provision new infrastructure services,
you can also use it to deprovision them when they’re no longer relevant. This is a
common practice in dynamic infrastructure environments, where you pay as you use
the infrastructure. Terraform provides a destroy command to help you to clean up
your infrastructure.
To keep your costs down, always clean up your infrastructure when
not using it. You will always be able to re-create it, in the very
same state, later, when you need it. Obviously, if you need data
persistence, keep the data well-preserved in another place where
you can get it later.
The terraform destroy command is the antagonist to terraform apply. As in
the provisioning flow, you can also use the plan command before actually changing
things, with -destroy, as shown in Example 12-59.
Example 12-59. Terraform destroy plan
$ terraform plan -destroy -out destroy_my_plan
aws_vpc.my_vpc: Refreshing state... [id=vpc-04f21f46af099b516]
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
- destroy
Terraform will perform the following actions:
# aws_vpc.my_vpc will be destroyed
- resource "aws_vpc" "my_vpc" {
- arn =
"arn:aws:ec2:eu-west-3:1:vpc/vpc-04f21f46af099b516" -> null
- assign_generated_ipv6_cidr_block = false -> null
- cidr_block = "192.0.2.0/24" -> null
- default_network_acl_id = "acl-03c818f415777e9c3" -> null
- default_route_table_id = "rtb-06b8f1263d440dfaa" -> null
Managing Dynamic Infrastructure with Terraform | 651
- default_security_group_id = "sg-08378207f8f073a85" -> null
- dhcp_options_id = "dopt-4f17a126" -> null
- enable_classiclink = false -> null
- enable_classiclink_dns_support = false -> null
- enable_dns_hostnames = false -> null
- enable_dns_support = true -> null
- id = "vpc-04f21f46af099b516" -> null
- instance_tenancy = "default" -> null
- ipv6_netmask_length = 0 -> null
- main_route_table_id = "rtb-06b8f1263d440dfaa" -> null
- owner_id = "1" -> null
- tags = {} -> null
- tags_all = {} -> null
}
Plan: 0 to add, 0 to change, 1 to destroy.
───────────────────────────────────────────────────────────────────────────────
Saved the plan to: destroy_my_plan
To perform exactly these actions, run the following command to apply:
terraform apply "destroy_my_plan"
All the lines with the hyphen (-), at the resource and attribute level, mean that
they will be removed.
To execute the destroy action, you run terraform apply -destroy, which then
creates a plan to destroy and asks for manual approval. But, as you did before when
provisioning, you can use a plan reference taken from the -out option, and skip the
approval for the destroy command:
$ terraform apply "destroy_my_plan"
aws_vpc.my_vpc: Destroying... [id=vpc-04f21f46af099b516]
aws_vpc.my_vpc: Destruction complete after 0s
Apply complete! Resources: 0 added, 0 changed, 1 destroyed.
After this, even though you still have a terraform.tfstate file, it has no resources.
Terraform has removed the remote infrastructure, the state references to it, and the
Terraform configuration.
The command terraform destroy is a convenience alias for terra
form apply -destroy. However, you can’t use terraform destroy
together with the -out option, which we recommend, so we opt to
use apply in both cases.
To be sure that the infrastructure is deprovisioned, you can use aws ec2 describevpcs
as before, and check that the Amazon VPC is no longer present:
652 | Chapter 12: Automation Tools
$ aws ec2 describe-vpcs --region eu-west-3 --vpc-ids vpc-04f21f46af099b516
An error occurred (InvalidVpcID.NotFound) when calling the DescribeVpcs
operation: The vpc ID 'vpc-04f21f46af099b516' does not exist
Terraform doesn’t automatically destroy infrastructure. When
you’re done playing with this chapter, don’t forget to run the
destroy command at the end so you don’t get a surprise bill.
After working on the Amazon VPC example, you should understand the basics of
Terraform and its workflow. Now it’s time to go further with our scenario, adding the
subnets, while learning how to extend Terraform resource usage.
Extending Terraform Execution
This Terraform section continues our journey through the scenario introduced in
Figure 12-5, adding two Amazon subnets within the previously created VPC. In this
process, you will discover new functionalities of Terraform and learn how to use
them to support advanced infrastructure designs.
The first step is to connect infrastructure elements—for instance, the Amazon VPC
and a subnet.
Adding resource dependencies
To create a new Terraform resource, you simply add a new configuration snippet by
using a new AWS provider resource type, aws_subnet. Notice you will start creating
only one subnet (my_subnet_1), not the two you will get at the end of this subsection.
For the aws_subnet resource type, you provide two required arguments
cidr_block and vpc_id. The cidr_block argument is another IP prefix,
a subprefix (192.0.2.0/25) of the cidr_block used for the VPC before
(192.0.2.0/24). The other one, vpc_id, is a reference to another Terraform
resource. To create Terraform configuration references, you use the syntax
resource_type.resource_name.attribute. This syntax works for Terraform
resources, but also for any other Terraform object, such as variables, as you will
discover later.
To keep examples self-contained, you can copy the previous configuration
file to a new directory (for instance, 2-create-vpc-andsubnet)
and then add the new resource there.
Managing Dynamic Infrastructure with Terraform | 653
The new resource configuration snippet in Example 12-60 looks similar to the previous
one, with the special reference to the VPC resource.
Example 12-60. Creating an AWS subnet
...
# Create a Subnet
resource "aws_subnet" "my_subnet_1" {
vpc_id = aws_vpc.my_vpc.id
cidr_block = "192.0.2.0/25"
}
The id is a special attribute from the aws_vpc resource. Its value can’t be known
before its provisioning, as it is computed by AWS when the object is created.
However, in Terraform, we can reference attributes that will be eventually available
and establish a dependency between these two resources. With this configuration,
we implicitly say that the subnet needs the VPC before it can be created.
Sometimes, hidden dependencies exist that Terraform cannot automatically
infer—for instance, when a Terraform resource depends
on another but is not using any of its attributes. For this case,
Terraform offers a depends_on meta-argument to list the dependencies
that Terraform will take care of establishing in the proper
provisioning order.
Now, in this new folder, you initialize Terraform again with terraform init
(remember, the context depends on the folder where you run the Terraform commands),
and you will be ready to test the new configuration with terraform plan. In
Example 12-61, having no state yet in this directory, you will see the same output as
in Example 12-55, plus the subnet part.
Example 12-61. Planning the VPC and subnet provisioning
$ terraform plan -out vpc_and_subnet
# aws_subnet.my_subnet_1 will be created
+ resource "aws_subnet" "my_subnet_1" {
+ arn = (known after apply)
+ assign_ipv6_address_on_creation = false
+ availability_zone = (known after apply)
+ availability_zone_id = (known after apply)
+ cidr_block = "192.0.1.0/25"
+ enable_dns64 = false
+ enable_resource_name_dns_a_record_on_launch = false
+ enable_resource_name_dns_aaaa_record_on_launch = false
+ id = (known after apply)
+ ipv6_cidr_block_association_id = (known after apply)
+ ipv6_native = false
654 | Chapter 12: Automation Tools
+ map_public_ip_on_launch = false
+ owner_id = (known after apply)
+ private_dns_hostname_type_on_launch = (known after apply)
+ tags_all = (known after apply)
+ vpc_id = (known after apply)
}
# trimmed output for the aws_vpc.my_vpc part
The plan output looks as expected, as you can see two objects ready to be created: the
VPC and the subnet. As noted previously, the vpc_id attribute from the subnet, taken
from the VPC id, is not known during the plan but will be automatically populated
during the apply execution.
This configuration would provision the desired VPC and subnet in AWS. However,
instead of applying it straightaway, let’s hold on for a moment and focus on understanding
an important aspect of any programming language: how to handle wrong
data input.
Handling data validation
Even though the Terraform configuration syntax may look good, and terraform
validate might not complain, sometimes the value of the arguments you are using
may be not consistent with the real expectations of the infrastructure platform.
An example case is using a value that is not complying with the data validation
defined in the provider definition for a specific argument. For instance, when setting
the value of cidr_block, you can’t use a nonvalid IP prefix, such as abcd, because the
schema validation and the terraform plan execution would catch it. Notice that the
validation is not simply by the value type, string, but takes into account other extra
validation:
$ terraform plan
│
│ Error: "abcd" is not a valid CIDR block: invalid CIDR address: abcd
│
│ with aws_subnet.my_subnet_1,
│ on create_vpc_and_subnet.tf line 23, in resource "aws_subnet" "my_subnet_1":
│ 23: cidr_block = "abcd"
You will learn about defining your custom validation for Terraform
variables later in this section.
However, in some cases, even though the data passes the schema validation, it doesn’t
actually make sense for the target infrastructure implementation. Following the same
cidr_block example, if you set a proper IP prefix, but it does not belong to the parent
Managing Dynamic Infrastructure with Terraform | 655
VPC prefix, the Terraform validation (using the provider rules) will succeed but will
raise a validation issue when Terraform tries to apply the changes:
...
# Create a Subnet
resource "aws_subnet" "my_subnet_1" {
vpc_id = aws_vpc.my_vpc.id
cidr_block = "198.51.100.0/24"
}
You, as network engineer, can spot that this configuration is inconsistent, because
the reference VPC has the prefix 192.0.2.0/24, and you are using a CIDR value
that’s not part of this reference prefix. However, this “advanced” data validation is not
coded in the Terraform provider and is left to the cloud provider API backend. Thus,
Terraform won’t detect any issues when validating this plan.
If you run terraform plan again, the output will look exactly the same as in Example
12-61, except for the subnet cidr_block value. Terraform considers that this plan
makes sense and can’t spot the issue.
However, as expected, if you try terraform apply after the plan, the validation will
complain, as shown in Example 12-62.
Example 12-62. Using an inconsistent subnet prefix
$ terraform apply "vpc_and_subnet"
aws_vpc.my_vpc: Creating...
aws_vpc.my_vpc: Creation complete after 2s [id=vpc-0c6fa4fb8c521970c]
aws_subnet.my_subnet_1: Creating...
│
│ Error: error creating EC2 Subnet: InvalidSubnet.Range: The CIDR
│ '198.51.100.0/24' is invalid.
│ status code: 400, request id: 80d332ce-c5fa-4e17-bfa0-055a98dcdf8f
│
│ with aws_subnet.my_subnet_1,
│ on create_vpc_and_subnet.tf line 21, in resource "aws_subnet" "my_subnet_1":
│ 21: resource "aws_subnet" "my_subnet_1" {
The AWS API complains with the error InvalidSubnet.Range. It was not possible
to apply this configuration, even though it looked good in the eyes of
Terraform. This should make us aware that simply having a successful Terraform
plan is not a guarantee for successful provisioning.
Furthermore, this error in the Terraform execution reveals another important behavior
of Terraform execution. Even though an error is raised in the subnet creation
step, Terraform creates the VPC in the first step, and this is not undone. Terraform
execution is not atomic: it is a sequential execution of declarative tasks, and an issue
in one task stops the execution, but the actions executed are not rolled back. You
656 | Chapter 12: Automation Tools
can check that an Amazon VPC is created by following Example 12-58, matching the
VPC ID from the apply output, or checking the content of the terraform.tfstate file.
We strongly recommend using development environments to help
you to test the Terraform configuration in apply mode, before
actually running the code in the production environment.
To solve the data consistency issue and other data transformation problems, you will
learn about Terraform functions next.
Using Terraform functions
The Terraform language comes with built-in functions you can use in your configuration,
within expressions or to manipulate values. We do not cover all the Terraform
functions, but you will learn about one to understand how you can leverage them.
In our example, it would be convenient to calculate the subnet CIDR from the VPC
one. This would reduce the chances of using the wrong one and would reduce the
amount of user data required. Luckily, Terraform has the cidrsubnet() function
to calculate prefixes from a parent. The function’s syntax is cidrsubnet(prefix,
newbits, netnum), where prefix is the referenced prefix, newbits is the number of
mask bits taken for the subprefixes, and netnum is an index on the resulting prefixes
list.
To see how a function works, you will use an interesting Terraform tool: its interactive
console. You can access it with terraform console and experiment with
Terraform expressions before using it in the static Terraform configuration:
$ terraform console
>
Once in the console, you can play with the cidrsubnet() function. For instance, in
Example 12-60, we decided to use the prefix mask /25, so take 1 bit from the parent
prefix mask, /24. Translating this to the cidrsubnet() argument, we set the original
prefix as the prefix and 1 for the newbits. Finally, in Example 12-63, playing with
the netnum index, you will get the different prefixes.
Example 12-63. Getting subnet prefixes with cidrsubnet()
> cidrsubnet("192.0.2.0/24", 1, 0)
"192.0.2.0/25"
> cidrsubnet("192.0.2.0/24", 1, 1)
"192.0.2.128/25"
Managing Dynamic Infrastructure with Terraform | 657
The function raises an error when the usage is not appropriate. For example, using
only 1 bit for subnetting produces only two child prefixes, so you can’t access a third
item, index 2:
> cidrsubnet("192.0.2.0/24", 1, 2)
│
│ Error: Error in function call
│
│ on <console-input> line 1:
│ (source code not available)
│
│ Call to function "cidrsubnet" failed: prefix extension of 1 does not
│ accommodate a subnet numbered 2.
│
Terraform does not support user-defined functions (at the time of
writing), so only built-in functions are available. You can check the
function documentation to get a detailed list of all the available
ones and how to use them. Knowing some of the most common
Terraform functions will help you develop better and simpler
Terraform configurations.
Now, it is time to use the cidrsubnet() function in the Terraform configuration. You
call the function with the my_vpc resource and its cidr_block (this value matches
the prefix argument from the function signature). In this case, the value is manually
defined, but the same would apply to data available only during provisioning time:
...
# Create a Subnet
resource "aws_subnet" "my_subnet_1" {
vpc_id = aws_vpc.my_vpc.id
cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 1, 0)
}
Finally, in Example 12-64, you are ready to validate the function applying the Terraform
configuration to create one AWS subnet.
Example 12-64. Creating an AWS subnet
$ terraform apply
aws_vpc.my_vpc: Refreshing state... [id=vpc-0c6fa4fb8c521970c]
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
+ create
Terraform will perform the following actions:
# aws_subnet.my_subnet_1 will be created
+ resource "aws_subnet" "my_subnet_1" {
658 | Chapter 12: Automation Tools
+ arn = (known after apply)
+ assign_ipv6_address_on_creation = false
+ availability_zone = (known after apply)
+ availability_zone_id = (known after apply)
+ cidr_block = "192.0.2.0/25"
+ enable_dns64 = false
+ enable_resource_name_dns_a_record_on_launch = false
+ enable_resource_name_dns_aaaa_record_on_launch = false
+ id = (known after apply)
+ ipv6_cidr_block_association_id = (known after apply)
+ ipv6_native = false
+ map_public_ip_on_launch = false
+ owner_id = (known after apply)
+ private_dns_hostname_type_on_launch = (known after apply)
+ tags_all = (known after apply)
+ vpc_id = "vpc-0c6fa4fb8c521970c"
}
Plan: 1 to add, 0 to change, 0 to destroy.
# some output omitted
aws_subnet.my_subnet_1: Creating...
aws_subnet.my_subnet_1: Creation complete after 6s [id=subnet-0502b7df8a948edda]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
The cidrsubnet() function generates the expected prefix, as you can see in the
approved plan, and the subnet is finally created.
In this output, the vpc_id is already available. This is because of the partial
creation in Example 12-62.
As you did in Example 12-58 to check the Amazon VPC status, in Example 12-65 you
check the status of the subnet in the target infrastructure with aws ec2 describesubnets.
Example 12-65. Validating the AWS subnet status
$ aws ec2 describe-subnets --region eu-west-3 --subnet-ids subnet-0502b7df8a948edda
{
"Subnets": [
{
"AvailabilityZone": "eu-west-3b",
"AvailabilityZoneId": "euw3-az2",
"AvailableIpAddressCount": 123,
"CidrBlock": "192.0.2.0/25",
"State": "available",
"SubnetId": "subnet-0502b7df8a948edda",
"VpcId": "vpc-0c6fa4fb8c521970c",
# omitted output for brevity
}
Managing Dynamic Infrastructure with Terraform | 659
]
}
You have created one Amazon subnet but our example scenario has two subnets.
One simple way to create the second one is to add another resource block with the
new subnet definition and use another prefix. You simply use a different identifier,
my_subnet_2, and instead of using the index 0 for cidrsubnet(), you choose the 1:
resource "aws_subnet" "my_subnet_2" {
vpc_id = aws_vpc.my_vpc.id
cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 1, 1)
}
However, one of the key principles when writing code is DRY. And, if you compare
this configuration snippet with the one used before, you can see a lot of repeated
code. Programming languages offer various functionalities to help you with the DRY
principle. And Terraform is no exception. Let’s find out how Terraform helps you
create multiple resources in only one resource block.
Creating multiple resources in a loop
The most common approach for running code multiple times is looping. Terraform
offers several options to implement loops: count, for loop, and for_each. Each has
different use cases. In this case, where you don’t have any data to iterate over, the
simplest approach is to use count to iterate over a range:
resource "aws_subnet" "my_subnets" {
count = 2
vpc_id = aws_vpc.my_vpc.id
cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 1, count.index)
}
The count meta-argument takes an integer to define how many elements of a block
type will be created. Then it leverages count.index to select the proper prefix in
cidrsubnet(). Neat and simple. In Example 12-66, we apply this configuration to
create two subnets.
Example 12-66. Creating a VPC and two subnets with Terraform
$ terraform apply
# omitted validation output
aws_vpc.my_vpc: Creating...
aws_vpc.my_vpc: Creation complete after 3s [id=vpc-0b3c91f2bf747a857]
aws_subnet.my_subnets[0]: Creating...
aws_subnet.my_subnets[1]: Creating...
aws_subnet.my_subnets[1]: Creation complete after 1s [id=subnet-09616706925ea65e2]
aws_subnet.my_subnets[0]: Creation complete after 1s [id=subnet-016160ea148e1e0de]
660 | Chapter 12: Automation Tools
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
Three infrastructure objects are provisioned with their identifiers.
The my_subnets resource block is now a list, containing two infrastructure
elements.
The output of your execution and the examples provided could
differ because of the actual state in each case. You can always start
from a blank state by destroying the previous infrastructure.
You have reached the desired scenario output! The network design is now described
as IaC, using Terraform configuration. Now you can easily tear up and down this
infrastructure at any time, with terraform apply and destroy. Take a second to
think about how easy (and fast) it is for you to manage your dynamic infrastructure
while keeping a consistent approach.
However, your Terraform journey doesn’t end here. You have learned the basics, but
using Terraform in real environments still requires mastering a few more concepts.
Managing Terraform at Scale
When you use Terraform in real production environments, you will face challenges
that require advanced Terraform concepts. In this section, you will tackle some of
them, starting with a common problem: how to deal with dependencies on infrastructure
that you don’t directly manage.
Using data sources to get data from nonmanaged infrastructure
So far, you have managed a self-contained infrastructure. Your Terraform configuration
contains the definition of all the resources required. You don’t have any dependencies
on other objects that are not configured in the Terraform configuration.
However, this is not always the reality. For instance, some companies have teams
managing shared infrastructure services that others teams depend on.
Terraform data sources allow you to import information from the target infrastructure,
even those not managed by the present Terraform configuration. Maybe these
resources were provisioned by another Terraform plan or, directly, via API or GUI.
Data sources are defined in the providers, like the resources, and use a different block
type, data.
In our example, let’s imagine that Team A manages the VPCs and Team B the
subnets. If you put yourself in the shoes of Team B, you have the challenge to solve
Managing Dynamic Infrastructure with Terraform | 661
in the subnet configuration: how could you know about the vpc_id and cidr_block,
from the Amazon VPC?
Example 12-67 shows how to use the data block. You can reference an object in the
target infrastructure, and then use this reference in the rest of the configuration. The
information will be retrieved in the refresh step when running Terraform.
Example 12-67. Terraform data source for an Amazon VPC
# provider configuration omitted
data "aws_vpc" "my_vpc" {
id = "vpc-0da120f2568c06c33"
}
# Create two subnets
resource "aws_subnet" "my_subnets" {
count = 2
vpc_id = data.aws_vpc.my_vpc.id
cidr_block = cidrsubnet(data.aws_vpc.my_vpc.cidr_block, 1, count.index)
}
Note that in the data block you need arguments to identify the target VPC so Terraform
can import the related information. Our example uses the resource identifier
(id), but each provider implementation could use a different argument (or multiple).
For instance, a common practice when referencing objects, without knowing their
identifiers, is to use metadata, such as labels or tags.
In this example, you use the aws_vpc data resource to get data from a VPC previously
created. You could create a standalone VPC via Terraform, as you did in
Example 12-57. Then, in another directory (for instance, 3-use-data), you can add
this configuration snippet with the proper VPC id. Once you have defined the data
source, you can use its reference, prepending data (data.aws_vpc.my_vpc.id).
When using references in Terraform, you add a prefix with the type
of the object. This is true except for resources, which is implicit.
$ terraform apply
data.aws_vpc.my_vpc: Reading...
data.aws_vpc.my_vpc: Read complete after 1s [id=vpc-0da120f2568c06c33]
# omitted the rest of the plan
aws_subnet.my_subnets[0]: Creating...
aws_subnet.my_subnets[1]: Creating...
662 | Chapter 12: Automation Tools
aws_subnet.my_subnets[1]: Creation complete after 1s [id=subnet-02bc291334d87cd1c]
aws_subnet.my_subnets[0]: Creation complete after 1s [id=subnet-0f1b499937a2cbd98]
Curiously, this execution takes longer that the ones before. Why? The data gathering
process, which you can identify in the output as Reading..., imports all the data
from the target infrastructure, and this takes longer than using the Terraform state.
Note that this Terraform execution owns only the provisioning of the subnets. This
applies to both the apply and the destroy steps. So, if you use the same configuration
to destroy, only the subnets will be destroyed, not the data used as the reference.
One drawback in this example is its use of hardcoded data, the VPC id. The same
challenge applies to other input data that could customize the output of a Terraform
configuration. So, let’s discover how Terraform helps with input data management.
Using Terraform variables
Terraform variables, or input variables, are used to customize the outcome of a Terraform
configuration, without changing its source code. Variables are code references
to a value that will be provided in Terraform execution time. Then, in the configuration,
you can use this reference when configuring your data sources, resources, or
others.
In Example 12-67, we set the VPC ID directly in the code. If you decide to change
this ID, you should update the configuration file, but doing so is cumbersome when
the data changes often.
The alternative is to declare a Terraform variable, which you could call vpc_id.
When writing the configuration, this variable doesn’t contain a value yet, but you can
reference it in the code, prepending the var. prefix. In the example, you can assign
the reference to the variable vpc_id by setting the argument id in the data block to
var.vpc_id:
variable "vpc_id" {
type = string
}
data "aws_vpc" "my_vpc" {
id = var.vpc_id
}
Variables have meta-arguments to tune their behavior. The type meta-argument
defines the type of the variable—for example, string or integer. The type enforces
an implicit validation, but a validation block also can enforce a more sophisticated
validation on the variable’s content. In Example 12-68, you can see condition enforcing
the vpc_id variable to start with vpc- as well as the error message to be raised if
the validation fails.
Managing Dynamic Infrastructure with Terraform | 663
Example 12-68. Validating Terraform variables
variable "vpc_id" {
type = string
description = "The id of the vpc_id."
sensitive = true
validation {
condition = length(var.vpc_id) > 4 && substr(var.vpc_id, 0, 4) == "vpc-"
error_message = "The vpc_id must be a valid VPC id, starting with \"vpc-\"."
}
}
Other common meta-arguments for variables are description, to provide a helper
message before submitting the input value, and sensitive, to hide the variable’s value
from the output.
Also, the default option indicates a reference value for the variable. If there is no
default value, and Terraform can’t obtain the value via other means, as you will learn
soon, it will prompt you to enter the value of the variable. In this case, it will ask you
about the value of var.vpc_id, with the extra helper message from the description.
You can check that the validation rule is working properly by entering the wrong
VPC ID—for instance, abcd:
$ terraform plan
var.vpc_id
The id of the vpc_id.
Enter a value: abcd
│
│ Error: Invalid value for variable
│
│ on use-data.tf line 15:
│ 15: variable "vpc_id" {
│ ├────────────────
│ │ var.vpc_id is "abcd"
│
│ The vpc_id must be a valid VPC id, starting with "vpc-".
│
│ This was checked by the validation rule at use-data.tf:20,3-13.
As expected, Terraform execution complains about the variable value not complying
with the validation criteria. It’s always recommended, not only in Terraform, to
enforce user input validation. It will save time and prevent other issues when finally
executing the code or configuration.
Now, after you have seen the validation in action, you can run it again using a proper
variable input (the same you hardcoded in Example 12-67), and the Terraform plan
should succeed:
664 | Chapter 12: Automation Tools
$ terraform plan
var.vpc_id
Enter a value: vpc-0da120f2568c06c33
data.aws_vpc.my_vpc: Reading...
data.aws_vpc.my_vpc: Read complete after 0s [id=vpc-0da120f2568c06c33]
# omitted other plan output
Terraform variables help keep your code reusable via customization. However, this
clearly is not a good programmatic practice, because human interaction is required.
In most cases, Terraform execution is automated, so it requires a programmatic way
to get the variables’ input.
Defining variables programmatically
Terraform has various ways to gather input data via nonhuman interaction. One
common approach is to define the variables in files, along with the Terraform configuration
variables.
Terraform, by default, reads from the file terraform.tfvars when executing a terra
form plan or apply (there is an example on this book’s GitHub page). Thus, you need
only to assign the variables’ values in this file and they will be automatically available:
vpc_id = "vpc-0da120f2568c06c33"
You can also use custom filenames by adding the -var-file=filename option in the
Terraform command. Or, if you don’t want to write the value to a file, you can assign
a variable value in the command line with -var 'foo=bar'.
Now, if you run terraform plan again, with the variable vpc_id defined, you will see
how the plan is executed without prompting you for input. Nevertheless, the same
variable validation criteria still apply.
This simple approach of storing the variables in code files works well in some cases,
but not when the content is sensitive. You shouldn’t store sensitive values in clear text,
for security reasons.
One mitigation option is to use environmental variables that are stored only in
process memory, not persisted. Terraform implictly imports environmental variables
into its execution environment, following a specific naming convention. You can use
any environmental variable with the TF_VAR_ prefix plus the name of the variable,
and it will be automatically available for Terraform.
Following our example, if you export TF_VAR_vpc_id as an environment variable, the
variable vpc_id will take the value from it, and you will not get the input prompt:
$ export TF_VAR_vpc_id="vpc-0da120f2568c06c33"
Managing Dynamic Infrastructure with Terraform | 665
Finally, you can also get variables to Terraform via external sources—such a source
of truth that stores the data defining the intended state of your infrastructure (Chapter
14 provides more details)—and get content from them. This is similar to the
Ansible or Nornir dynamic inventory. Needless to say, you will need to install and use
the proper Terraform provider that exposes the data sources. For example, to get the
VPC CIDR prefix, you could retrieve it from an IPAM system, getting the proper one
according to the network plan.
If you have sensitive variables, also known as secrets, you can use
a secrets manager (which organizes your secrets via best security
practices) such as the HashiCorp Vault provider.
Now that you understand how to use variables in Terraform, let’s see how to manage
different environments from the same configuration.
Using workspaces
Terraform understands the context of the execution—configuration and state—from
the path where Terraform is executed. However, when you want to reuse the same
Terraform configuration to define multiple environments (for instance, development
and production), you need a mechanism to isolate the different states, similar to
namespaces. Terraform uses workspaces for this purpose.
By default, you are already using workspaces. Specifically, you are using the default
one, as you can see when listing the workspaces with terraform workspace list:
$ terraform workspace list
* default
Workspaces help you reuse the same Terraform configuration to manage multiple
environments. You can define the same infrastructure for multiple environments by
changing the credentials pointing to one or another account from the cloud provider.
Terraform workspaces are not supported by all Terraform state
backends. Check the documentation. The local backend supports
workspaces.
In this example, you will create two workspaces, A and B, and each will match one of
two different AWS profiles. An AWS profile is a combination of account credentials
and other user settings (for instance, different accounts in the same region or the
same account in different regions).
666 | Chapter 12: Automation Tools
In our example, we simply use two regions for the same AWS account, both having
the same network setup used in our example (a VPC and two subnets) but different
CIDR prefixes. However, the same principle applies to different accounts. This
approach is commonly used to isolate different environments, such as testing and
production.
An AWS profile can be added in the credentials file, which was
created in Example 12-51, by simply adding two new entries, A
and B in .aws/credentials and .aws/config (in your user home
directory). We suggest you keep the same credentials for all the
profiles and simply change the region. This way, you don’t need to
create more AWS accounts. Here’s the code:
.aws/credentials
[default]
aws_access_key_id = YOUR_AWS_KEY_ID
aws_secret_access_key = YOUR_AWS_SECRET_KEY
[A]
... similar as default ...
[B]
... similar as default ...
.aws/config
[default]
region = eu-west-3
output = json
[A]
... similar as default ...
[B]
... similar as default ...
The first step is to create a new workspace via terraform workspace new A. This
command initializes the workspace and activates it:
$ terraform workspace new A
Created and switched to workspace "A"!
You're now in a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
Now, if you list the workspaces, you’ll see a new one, with the asterisk (*) indicating it
is the active workspace:
$ terraform workspace list
default
* A
Managing Dynamic Infrastructure with Terraform | 667
In the configuration, you can use terraform.workspace, which contains the string
value of the workspace name. Using this reference will help you select the right data
for each execution. This could be done in different ways. One that works well when
there are relatively few variables is using map type variables and using the Terraform
workspace as the key (Example 12-69).
Example 12-69. Terraform configuration for workspaces
terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 3.0"
}
}
}
# Configure the AWS Provider
provider "aws" {
profile = terraform.workspace
}
variable "cidr" {
type = map(string)
default = {
A = "198.51.100.0/24"
B = "203.0.113.0/24"
}
}
# Create a VPC
resource "aws_vpc" "my_vpc" {
cidr_block = var.cidr[terraform.workspace]
}
# Create two subnets
resource "aws_subnet" "my_subnets" {
count = 2
vpc_id = aws_vpc.my_vpc.id
cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 1, count.index)
}
In the provider block, we set the profile argument with the workspace name,
instead of the region that we used before. As we’ve mentioned, in the example
this points to the same account in different regions, using AWS profiles.
We define a variable of type map(string) which, in the default, contains a map
for each workspace name. This map is similar to a dict in Python, but keys are
only of string type.
668 | Chapter 12: Automation Tools
We can access one CIDR value or another, using a different key, with
var.cidr[terraform.workspace]. So, when we run terraform plan, having the
workspace A activated, Terraform will use the 198.51.100.0/24 prefix.
To complete the example, you can create the other workspace B, with terraform
workspace new B. If you run terraform plan again, you will see the other prefix
being used.
Another difference when using workspaces is the way Terraform stores the state. In
the local backend, notice that there won’t be the file terraform.tfstate. Instead, now
you have a directory terraform.tfstate.d, which contains a folder for each workspace,
with the corresponding state:
$ tree terraform.tfstate.d
terraform.tfstate.d
├── A
├── terraform.tfstate
└── terraform.tfstate.backup
└── B
├── terraform.tfstate
└── terraform.tfstate.backup
Terraform workspaces help you reuse the same configuration to manage multiple
environments. But to improve reusability between configurations, you need to learn
about Terraform modules.
Using modules to improve reusability
Throughout this section, you may have inferred the potential of Terraform to manage
dynamic infrastructure via its declarative approach. However, you can also foresee
how complex this configuration could become in real environments. You need some
way to break this configuration into different reusable parts. Terraform modules are
the answer.
A module is a container of Terraform resources that are grouped together. You can
imagine it as a package in other programming languages, which you can import and
use from other code.
Going back again to the VPC and subnets example, you will now create two modules:
one for the VPC and another for the subnet. You start in a new directory
(for instance, 6-modules) with a Terraform configuration file (main.tf), which will
reference the modules. Notice that the filename is arbitrary; it could be anything with
the .tf extension. For the two modules, it’s necessary to create two nested folders, such
as subnet and vpc, which will contain the Terraform configuration needed for each
case. These folders don’t need to be nested; the location could be any other reachable
source.
You will end up with a folder structure like that in Example 12-70.
Managing Dynamic Infrastructure with Terraform | 669
Example 12-70. Terraform module structure
$ tree 6-modules
.
├── main.tf
├── subnet
│ └── subnet.tf
└── vpc
└── vpc.tf
Modules are usually composed of multiple files, to represent the
different objects: variables, resources, and outputs. In the example,
for simplicity, we used only one Terraform file.
In Example 12-71, using a top-down approach, first, you create the main.tf configuration,
containing the overall Terraform configuration plus the call to the two modules,
named my_vpc_module and my_subnet_module.
Example 12-71. Terraform module composition
# Omitted AWS Terraform provider reference
# Omitted AWS Provider config
variable "base_cidr" {
default = "192.0.2.0/24"
}
module "my_vpc_module" {
source = "./vpc"
cidr_for_vpc = var.base_cidr
}
module "my_subnet_module" {
source = "./subnet"
count = 2
vpc_id = module.my_vpc_module.id
vpc_cidr_block = cidrsubnet(module.my_vpc_module.cidr_block, 1, count.index)
}
The main.tf configuration contains the provider definition plus the variable
base_cidr (with a default value) that we will use when calling the modules. You
should imagine this configuration file as the entry point of the Terraform plan,
so it’s the place where the global input variables will be defined. The modules will
have their own input variables, but these won’t be exposed to the caller.
To use a module, we simply define the block module and provide the arguments
that it requires. The source meta-argument is necessary because it points to the
670 | Chapter 12: Automation Tools
module’s location. In this case, we are using the nested local path, but it could be
an HTTP URL, a GitHub repository, or a reference to Terraform Registry, and
many more. The modules, like the providers, are initialized during terraform
init, so the modules, if not local, are retrieved and installed in the .terraform
folder.
The other arguments used to call the module from main.tf are input variables
defined by the module. For instance, when using the module ./vpc, we set the
argument cidr_for_vpc. This means that in the vpc module, there is an input
variable with this name. The same applies to the ./subnet module, with the
vpc_id and vpc_cidr_block arguments.
The count meta-argument for my_subnet_module creates two objects from
the same module, similar to what we did with the subnet resources in Example
12-71.
Another difference is the use of the module prefix in the references to
these configuration blocks: module.my_vpc_module.id and module.my_vpc_mod
ule.cidr_block. You have already seen this syntax (for instance, in Example
12-60) with the type of the resource, the identifier, and the argument. To
be more precise, this argument we reference is actually a Terraform output,
which indicates the values Terraform exposes at the end of the execution, via the
command-line output, or programmatically to other Terraform code.
Let’s review each module definition, starting with the VPC in Example 12-72.
Example 12-72. Terraform VPC module
variable "my_cidr" {}
resource "aws_vpc" "my_vpc" {
cidr_block = var.my_cidr
}
output "cidr_block" {
value = aws_vpc.my_vpc.cidr_block
}
output "id" {
value = aws_vpc.my_vpc.id
}
As we mentioned, we defined the input variable my_cidr, which becomes a mandatory
input because it has no default argument (which would define the value of
my_cidr in its absence). Then, internally in this module, the variable is used in the
aws_vpc resource, as in previous examples.
Managing Dynamic Infrastructure with Terraform | 671
The newcomers in this configuration are the outputs, cidr_block and id. The most
important argument is value, which in this case references outputs from resource.
Other options to tune its behavior exist, such as sensitive to suppress the values in
the CLI output, and depends_on to define dependencies that are not explicit. Notice
that the output identifiers are exactly the ones we referenced in main.tf.
You can notice a similarity between a Terraform module and a programming language
function. Here, we have input variables instead of function arguments, followed
by some code, and finally, some outputs returned instead of return values.
You could use Terraform outputs not only to pass data between
modules but to simply expose special values on the Terraform CLI.
The subnet module configuration is even simpler than in previous examples because
the multiple object creation logic is left to main.tf, using the count meta-argument.
In this case, this module is focused on creating only one subnet and setting the two
arguments it needs:
variable "vpc_id" {}
variable "vpc_cidr_block" {}
resource "aws_subnet" "my_subnet" {
vpc_id = var.vpc_id
vpc_cidr_block = var.cidr_block
}
Notice that this code includes only an input variable definition, matching the arguments
calling the module from main.tf. The code includes no outputs because we
don’t need to use outputs from this module as inputs for other modules nor to render
in the CLI.
Applying this Terraform configuration produces exactly the same infrastructure as
the previous examples: one Amazon VPC and two subnets. However, with this setup,
the two modules created could be reused for other Terraform configurations. It’s a
common practice to define infrastructure stacks—for instance, all the base networking
components in one module (which could be itself composing other modules)—
and then reuse this module from multiple application deployments. So, the DevOps
teams don’t need to reinvent the wheel for every infrastructure deployment, but can
simply reuse what’s understood as the best practice.
You have now completed your introductory journey through Terraform! You learned
how to manage dynamic infrastructure, focusing on network services and using a
declarative approach. However, Terraform could be used in other ways, with limitations,
as you will see next.
672 | Chapter 12: Automation Tools
Terraform Out of Its Comfort Zone
Throughout this section, you have seen how to use Terraform canonically, using a
declarative approach and managing dynamic infrastructure services. However, as it
happens when a tool becomes mainstream, other options have been added to extend
its usage.
Even though the declarative approach is where Terraform shines, it also supports
an imperative approach via Terraform provisioners. Next, you’ll see how Terraform
provisioners can cover certain use cases that can’t be represented in the native Terraform’s
declarative model.
Using Terraform provisioners
You may be wondering, “Why do we need to tweak Terraform to support the imperative
approach if other tools exist for this purpose?” The reason is to keep all the
infrastructure management within one tool, for operational simplicity.
This approach addresses some use cases, such as provisioning compute resources,
that require configuration changes to do their job. Not all Terraform providers support
this functionality, but the most popular ones do. For instance, Amazon EC2
instances support the user_data argument to provide custom data to the instance,
to be run at launch time (for instance, passing commands to customize the instance
status).
However, if the Terraform resource does not provide a specific option to customize
the bootstrap of the infrastructure, you still have the option to provision a resource
after a state change: the Terraform provisioner. The provisioner block, within the
resource block, supports three provisioner types:
local-exec
An executable is invoked locally, after the resource is created.
remote-exec
An executable is invoked remotely in the remote resource after the resource is
created. This option requires a remote connection to the resource.
file
It copies files or directories to the new resource, via a remote connection.
Managing Dynamic Infrastructure with Terraform | 673
local-exec and remote-exec have security concerns that should
be taken into account: excessive privileges and execution in clear
text. To mitigate these concerns, we recommend minimizing their
use, and using them only following best practices for securing credentials
and managing SSH access. Alternatively, using Ansible as a
provisioner is a more robust option; using Terraform and Ansible
where each tool shines is a good idea and is especially easier now
with the new Terraform Provider for Ansible.
Example 12-73 uses a local-exec provisioner that simply takes a command. This command
will be executed in the local computer running Terraform when the resource,
the AWS instance, is created.
Example 12-73. Terraform provisioner
resource "aws_instance" "server" {
# some config omitted
provisioner "local-exec" {
command = "echo The server IP is ${self.private_ip}"
}
}
Terraform provisioners can help you simplify infrastructure management in one tool.
However, this approach adds complexity and uncertainty, and should be used only as
a last resort.
For example, thoughout this Terraform section, we have shown how useful it is to
rely on terraform plan execution to foresee the final status of the infrastructure. The
actions from provisioners can’t be modeled, so their potential effects are not taken
into account in the feedback from the dry-run execution.
Keep this in mind: just because you can, doesn’t mean you should. You can use
other tools, such as Ansible or Nornir, to manage configurations, as you learned in
this chapter. Or, using the immutable approach, you could use other tooling, like
HashiCorp Packer, to create server images with all the proper configurations in place
before provisioning them.
Lastly, pushing Terraform out of its common uses, let’s discuss its potential for
managing network devices.
Using Terraform to manage network devices
Terraform has progressively been adopted by network operations teams to manage
cloud network services in general-purpose clouds, network-centric clouds (such
as OpenStack, Arista CloudVision, Cisco ACI or Multi-Site Orchestrator (MSO),
VMware NSX), and multicloud solutions (such as Alkira and Aviatrix).
674 | Chapter 12: Automation Tools
In parallel to these natural use cases, in early 2022, experimental initiatives started to
manage network devices using Terraform providers. The new network management
interfaces, using REST APIs and structured data (Chapter 10 provides more info),
make it easier to build Terraform providers. The same rationale used for provisioners
applies here, using the same tool to manage the whole infrastructure.
However, managing network devices is different from provisioning network services
behind a controller. The network APIs are used to change the state of the configuration
as a whole and per feature. This doesn’t completely match the declarative
approach Terraform is used to.
At the time of writing, this trend has two experimental examples: the Junos Terraform
Automation Network, or JTAF, and the IOS XE provider. These two options offer
generic arguments to wrap the inner behavior of their network management interfaces.
For instance, as you will see in Example 12-75, with the IOS XE provider, the
resource arguments are simply the URL path and the data payload.
Even though it’s not clear whether this approach will gain traction over time, it’s
interesting to observe the differences between our previous main example and this
use case, using the IOS XE Terraform provider leveraging the RESTCONF API
interface.
First, as in every Terraform configuration, you define the required_provider, referencing
the provider in the Terraform Registry, and then the specific provider block
configuration (see Example 12-74). You could use any IOS XE device available, taking
into account the required OS version. But, as an easy alternative, you can use an
always-on IOS XE instance from Cisco DevNet. The host and credentials used in the
example are pointing to this sandbox.
Example 12-74. IOS XE Terraform provider configuration
terraform {
required_providers {
iosxe = {
source = "CiscoDevNet/iosxe"
version = "0.1.1"
}
}
}
provider "iosxe" {
host = "https://sandbox-iosxe-latest-1.cisco.com"
device_username = "developer"
device_password = "C1sco12345"
}
Managing Dynamic Infrastructure with Terraform | 675
If the host or credentials provided don’t work, check the parameters
on the official DevNet page.
This provider consists of one resource and one data source, both named iosxe_rest.
Both are simple wrappers of the REST API. First, in Example 12-75, you will use
the data source, referencing the full device configuration with the path, and finally
outputting it in the CLI output.
Example 12-75. IOS XE Terraform provider data source
# omitted provider configuration
data "iosxe_rest" "full_config" {
path = "/data/Cisco-IOS-XE-native:native"
}
output "response" {
value = data.iosxe_rest.full_config
}
Executing terraform apply, you will output the full configuration and store it in
the Terraform state. This is the configuration, in YANG format, from the IOS XE
instance:
$ terraform apply
data.iosxe_rest.full_config: Reading...
data.iosxe_rest.full_config: Read complete after 2s [id=1844435120]
Changes to Outputs:
+ response = {
+ id = "1844435120"
+ path = "/data/Cisco-IOS-XE-native:native"
+ response = jsonencode(
{
+ "Cisco-IOS-XE-native:native" = {
+ "Cisco-IOS-XE-diagnostics:diagnostic" = {
+ bootup = {
+ level = "minimal"
}
}
+ banner = {
+ motd = {
+ banner = <<-EOT
Welcome to the DevNet Sandbox for CSR1000v and IOS XE
# output trimmed for brevity
676 | Chapter 12: Automation Tools
You can see how this Terraform provider is just an adapter to the RESTCONF API.
The data source performs a GET to the path, and the returned data is structured in
YANG.
The next step is to modify some parts of the configuration and understand how the
provider works with resources. You are, again, using the resource iosxe_rest. Here,
you can notice the different types of usage, as compared to previous AWS resources,
where the low-level details are hidden and only the key arguments are requested. In
this case, you need to know and specify the full YANG path as the path argument
value, instead of having a different resource for each network feature:
# omitted provider configuration
resource "iosxe_rest" "snmp_example_chassis_id" {
method = "PUT"
path = "/data/Cisco-IOS-XE-native:native/snmp-server/chassis-id"
payload = jsonencode(
{
"Cisco-IOS-XE-snmp:chassis-id" : "a_new_chassis_id"
}
)
}
When you apply the Terraform configuration, as shown in Example 12-76, the new
configuration will be applied in the YANG path specified.
Example 12-76. Creating an IOS XE configuration with Terraform
$ terraform apply -auto-approve
data.iosxe_rest.full_config: Reading...
data.iosxe_rest.full_config: Read complete after 1s [id=1844435120]
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
+ create
Terraform will perform the following actions:
# iosxe_rest.snmp_example_chassis_id will be created
+ resource "iosxe_rest" "snmp_example_chassis_id" {
+ id = (known after apply)
+ method = "PUT"
+ path = "/data/Cisco-IOS-XE-native:native/snmp-server/chassis-id"
+ payload = jsonencode(
{
+ "Cisco-IOS-XE-snmp:chassis-id" = "a_new_chassis_id"
}
)
+ response = (known after apply)
}
Plan: 1 to add, 0 to change, 0 to destroy.
Managing Dynamic Infrastructure with Terraform | 677
iosxe_rest.snmp_example_chassis_id: Creating...
iosxe_rest.snmp_example_chassis_id: Creation complete after 1s [id=772450073]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
# Omitted output
In this case, the new configuration is added with the + symbol because no previous
configuration was present before.
If you use -auto-approve, you don’t get the user-prompt confirmation,
even without a plan reference.
Finally, you can connect to the IOS XE device and validate that the configuration has
been applied:
csr1000v-1#sh running-config | include snmp
snmp-server chassis-id a_new_chassis_id
Now, you can change the chassis-id to another one and validate how the plan
would look when a previous chassis-id is defined:
$ terraform plan
iosxe_rest.snmp_example_chassis_id: Refreshing state... [id=772450073]
data.iosxe_rest.full_config: Reading...
data.iosxe_rest.full_config: Read complete after 1s [id=1844435120]
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
~ update in-place
Terraform will perform the following actions:
# iosxe_rest.snmp_example_chassis_id will be updated in-place
~ resource "iosxe_rest" "snmp_example_chassis_id" {
id = "772450073"
~ payload = jsonencode(
~ {
~ "Cisco-IOS-XE-snmp:chassis-id" = "a_new_chassis_id"
-> "another_chassis_id"
}
)
# (2 unchanged attributes hidden)
}
Plan: 0 to add, 1 to change, 0 to destroy.
In this case, you can see the ~ symbol, pointing out that it’s not adding, but changing,
the content of this configuration leaf. This is an improvement over the provisioner
678 | Chapter 12: Automation Tools
approach because you can determine the difference in the plan before actually performing
the changes in the configuration.
As you can see, today there is a big difference between using Terraform to manage
network devices versus using cloud or controller-based network services, but only
time will tell if this new approach will become adopted to consolidate operations.
Terraform Summary
In this section, you’ve seen the different approach that Terraform brings to infrastructure
management—the declarative approach—which makes it a good choice to provision
dynamic infrastructure, especially exposed as a service. Terraform’s flexibility to
adapt to multiple APIs has raised its popularity and positioned it as the default choice
as the IaC tools when working with various cloud platforms.
Also keep in mind that Terraform is not incompatible with other configuration
management tools, like the ones presented in this chapter. For instance, when working
with raw infrastructure as a service, you could use Terraform to provision the
dynamic infrastructure (for instance, a VM), and then run a provisioner that will call
an Ansible playbook to configure it. You should choose the solutions that suit better
in each case.
You can refer to the Terraform documentation to find more details about Terraform
usage and more advanced use cases.
Summary
In this chapter, we discussed how some automation tools—like Ansible, Nornir, and
Terraform—can be put to work in network automation. We provided example use
cases and discussed the advantages and disadvantages of each product along the way.
In Table 12-2, we provide a high-level comparison of each tool for your reference.
Table 12-2. Automation tools summary
Tool Approach Language Logic customization State tracking
Ansible Imperative YAML Moderate No
Nornir Imperative Python High No
Terraform Declarative HCLa Moderate Yes
a CDKTF allows multiple programming languages.
With all these tools and other technologies from previous chapters, the next chapter
will show you how to apply the software development best practices of continuous
integration to the network automation domain.