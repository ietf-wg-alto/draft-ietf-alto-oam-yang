# Design of ALTO O&M Data Model {#alto-model}

## Overview of ALTO O&M Data Model

The "ietf-alto" module defined in this document is designed to fit all the requirements listed in [](#sec-req).

As shown in {{tree-str}}, the top-level container "alto" in the "ietf-alto" module contains a single
"alto-server" and a list of "alto-client" that are uniquely identified.

The list "alto-client" defines a list of configurations for other applications
to bootstrap an ALTO client. These data nodes can also be used by data sources and information
resource creation algorithms that are configured by an ALTO server instance.

The container "alto-server" contains both configuration and operational
data of an administrated ALTO server instance.

~~~
module: ietf-alto
  +--rw alto!
     +--rw alto-client* [client-id]
     |  ...
     +--rw alto-server
        +...
        +--rw auth-client* [client-id]
        |  ...
        +--rw role* [role-name]
        |  +--rw role-name    role-name
        |  +--rw client*
        |          -> /alto/alto-server/auth-client/client-id
        +--rw data-source* [source-id]
        |  ...
        +--rw resource* [resource-id]
           ...
~~~
{: #tree-str title='IETF ALTO Tree Structure' artwork-align="center"}

## Data Model for ALTO Client Operation and Management

As shown in {{tree-alto-client}}, the "alto-client" list contains a list of client-side configurations.
"server-discovery-client" is used to configure how an ALTO client discovers
an ALTO server.

~~~
module: ietf-alto
  +--rw alto!
     +--rw alto-client* [client-id]
     |  +--rw client-id                  string
     |  +--rw server-discovery-client
     |     +---u alto-server-discovery-client-grouping
     ...
~~~
{: #tree-alto-client title='IETF ALTO Client Subtree Structure' artwork-align="center"}

## Data Model for Server-level Operation and Management

The ALTO server instance contains a set of data nodes server-level operation and management for ALTO that are shown in {{tree-alto-server-level}}. This structure  satisfies R1 - R4 in [](#requirements).

~~~
module: ietf-alto
  +--rw alto!
     ...
     +--rw alto-server
        +--rw listen
        |  +---u alto-server-listen-stack-grouping
        +--rw server-discovery
        |  +---u alto-server-discovery-grouping
        +--rw logging-system
        |  +---u alto-logging-system-grouping
        +--rw cost-type* [cost-type-name]
        |  +--rw cost-type-name    string
        |  +--rw cost-mode         identityref
        |  +--rw cost-metric       identityref
        |  +--rw description?      string
        |  +--rw cost-context {performance-metrics}?
        |     +--rw cost-source    identityref
        |     +--rw parameters
        |        +--rw (parameters)?
        +--rw meta* [meta-key]
        |  +--rw meta-key      string
        |  +--rw meta-value    string
        ...
~~~
{: #tree-alto-server-level title='IETF ALTO Server Level Subtree Structure' artwork-align="center"}

### Data Model for ALTO Server Setup

To satisfy R1 in [](#requirements), the ALTO server instance contains the
basic data nodes for the server setup that are detailed in the following subsections.

#### ALTO Server Listen Stack

The "listen" contains all the data nodes for the whole server listen stack
across HTTP, TLS, and TCP layers ({{tree-alto-gp}}).

~~~
  grouping alto-server-grouping:
    +-- base-uri?   inet:uri
  grouping alto-server-listen-stack-grouping:
    +-- (transport)
       +--:(http) {http-listen}?
       |  +-- http
       |     +-- tcp-server-parameters
       |     |  +---u tcp:tcp-server-grouping
       |     +-- http-server-parameters
       |     |  +---u http:http-server-grouping
       |     +-- alto-server-parameters
       |        +---u alto-server-grouping
       +--:(https)
          +-- https
             +-- tcp-server-parameters
             |  +---u tcp:tcp-server-grouping
             +-- tls-server-parameters
             |  +---u tls:tls-server-grouping
             +-- http-server-parameters
             |  +---u http:http-server-grouping
             +-- alto-server-parameters
                +---u alto-server-grouping
~~~
{: #tree-alto-gp title='IETF ALTO Server Groupings Structure' artwork-align="center"}

#### ALTO Server Discovery Setup

In practice, multiple ALTO servers can be deployed for scalability. That may
require communication among different ALTO servers.

The "ietf-alto" module does not contain any configuration for
the communication between peer ALTO servers. Instead, it provides the
configuration for how an ALTO server can be discovered by another ALTO server on
demand ({{tree-alto-disc-gp}}).

~~~
  grouping alto-server-discovery-grouping:
    +-- (server-discovery-manner)?
       +--:(reverse-dns)
          +-- rdns-naptr-records
             +-- static-prefix*           inet:ip-prefix
             +-- dynamic-prefix-source*
                     -> /alto-server/data-source/source-id
~~~
{: #tree-alto-disc-gp title='IETF ALTO Server Discovery Grouping Structure' artwork-align="center"}

The "server-discovery" node provides configuration for the discovery of ALTO servers
using a variety of mechanisms. The initial version of the "ietf-alto" module only defines the "reverse-dns"
case that is used to configure DNS NAPTR records for ALTO server discovery,
which is sugested by {{RFC7286}} and {{RFC8686}}. It configures a set of
endpoints that can be served by this ALTO server. The node
contains two leaf lists. The "static" list contains a list of manually configured
endpoints. The "dynamic" list points to a list of data sources to retrieve the
endpoints dynamically. As suggested by {{RFC7286}} and {{RFC8686}}, the IP
prefixes of the endpoints configured by both "static" and "dynamic" lists will
be translated into DNS NAPTR resource records for server discovery. The
"server-discovery-manner" choice can be augmented by the future modules to
support other mechanisms.

### Data Model for Logging Management

To satisfy R2 in [](#requirements), the ALTO server instance contains the 
the logging data nodes shonw in {{tree-alto-log-gp}}.

The "logging-system" data node provides configuration to select a logging system to
capture log messages generated by an ALTO server.

By default, "syslog" is the only supported logging system. When selecting
"syslog", the related configuration is delegated to the configuration file of
the syslog server.

~~~
  grouping alto-logging-system-grouping:
    +-- (logging-system)?
       +--:(syslog)
          +-- syslog-params
             +-- config-file?   inet:uri
~~~
{: #tree-alto-log-gp title='IETF ALTO Logging System Grouping Structure' artwork-align="center"}

A specific server implementation can extend the "logging-system" node to add
other logging systems.

### Data Model for ALTO-related Management

To satisfy R3 in [](#requirements), the data model contains the following
ALTO-related management information ({{tree-alto-server-level}}):

- The "cost-type" list is the registry for the cost types that can be used in the
ALTO server.

- The "meta" list contains the customized meta data of the ALTO server. It is
populated into the meta field of the default Information Resource Directory
(IRD).

### Data Model for Security Management

To satisfy R4 in [](#requirements), the data model leverages HTTP and TLS to
provide basic security management for an ALTO server. All the related
configurations are covered by the server listen stack.

## Data Model for ALTO Server Configuration Management

### Data Source Configuration Management {#data-source}

To satisfy R5-1 in [](#requirements), the ALTO server instance contains a list
of "data-source" entries to subscribe the data sources from which ALTO
information resources are derived (Section 16.2.4 of {{RFC7285}}).

~~~
module: ietf-alto
  +--rw alto!
     ...
     +--rw alto-server
        ...
        +--rw data-source* [source-id]
        |  +--rw source-id                    string
        |  +--rw source-type                  identityref
        |  +--rw (update-policy)
        |  |  +--:(reactive)
        |  |  |  +--rw (publish-mode)?
        |  |  |     +--:(on-change)
        |  |  |     |  +--rw on-change        empty
        |  |  |     +--:(periodic)
        |  |  |        +--rw feed-interval    uint32
        |  |  +--:(proactive)
        |  |     +--rw poll-interval          uint32
        |  +--rw (source-params)?
        ...
~~~
{: #tree-data-src title='IETF ALTO Server Data Source Subtree Structure' artwork-align="center"}

As shown in {{tree-data-src}}, a "data-source" list entry includes:

- A unique "source-id" for resource creation algorithms to reference.
- The "source-type" attribute to declare the type of the data source.
- The "update-policy" to specify how to get the data update from the data
  source.
- The "source-params" to specify where and how to query the data.

The update policy can be either reactive or proactive. For the reactive update,
the ALTO server reactively waits the data source for pushing updates. For the
proactive update, the ALTO server has to proactively fetch the data source
periodically.

To use the reactive update, two publish modes are supported:

- If the "on-change" attribute is present, the data source is expected to push
  the update as soon as the data source changes.
- Otherwise, if the "feed-interval" attribute is present, the data source is
  expected to push the updates periodically. The value of "feed-interval"
  specifies the interval of pushing the data change updates in milliseconds.
  If "feed-interval" is zero, the data source is expected to work in the
  "on-change" mode.

To use the proactive update, the "poll-interval" attribute MUST be present. The
value of "poll-interval" specifies the interval of fetching the data in
milliseconds. If "poll-interval" is zero, the ALTO server will not fetch the
data source.

The "data-source/source-params" node can be augmented for different types of
data sources.

This data model only includes common configuration parameters for an ALTO server
to correctly interact with a data source. The implementation-specific parameters
of any certain data source can be augmented in another module. An example is
included in [](#example-data-source).

### ALTO Information Resources Configuration Management

To satisfy R5-2 and R-3, the ALTO server instance contains a list of "resource"
entries ({{tree-alto-server-rsc}}). Each "resource" entry contains the configurations of an ALTO
information resource (See Section 8.1 of {{RFC7285}}). The operator of the ALTO
server can use this model to create, update, and remove the ALTO information
resources.

Each "resource" entry provides configurations defining how to create or update
an ALTO information resource. Adding a new "resource" entry notifies the ALTO
server to create a new ALTO information resource. Updating an existing
"resource" entry notifies the ALTO server to update the generation parameters
(e.g., capabilities and the creation algorithm) of an existing ALTO information
resource. Removing an existing "resource" entry will remove the corresponding
ALTO information resource.

~~~
module: ietf-alto
  +--rw alto!
     ...
     +--rw alto-server
        ...
        +--rw resource* [resource-id]
           +--rw resource-id                       resource-id
           +--rw resource-type                     identityref
           +--rw description?                      string
           +--rw accepted-role*
           |       -> /alto/alto-server/role/role-name
           +--rw dependency*
           |       -> /alto/alto-server/resource/resource-id
           +--rw (resource-params)?
              +--:(ird)
              |  +--rw alto-ird-params
              |     +--rw delegation    inet:uri
              +--:(networkmap)
              |  +--rw alto-networkmap-params
              |     +--rw is-default?   boolean
              |     +--rw filtered?     boolean
              |     +---u algorithm
              +--:(costmap)
              |  +--rw alto-costmap-params
              |     +--rw filtered?             boolean
              |     +---u filter-costmap-cap
              |     +---u algorithm
              +--:(endpointcost)
              |  +--rw alto-endpointcost-params
              |     +---u endpoint-cost-cap
              |     +---u algorithm
              +--:(endpointprop)
              |  +--rw alto-endpointprop-params
              |     +--rw prop-types*   string
              |     +---u algorithm
              +--:(propmap) {propmap}?
              |  +--rw alto-propmap-params
              |     +---u algorithm
              +--:(cdni) {cdni}?
              |  +--rw alto-cdni-params
              |     +---u algorithm
              +--:(update) {incr-update}?
                 +--rw alto-update-params
                    +---u algorithm

  grouping filter-costmap-cap:
    +-- cost-type-names*            string
    +-- cost-constraints?           boolean
    +-- max-cost-types?             uint32 {multi-cost}?
    +-- testable-cost-type-names*   string {multi-cost}?
    +-- calendar-attributes {cost-calendar}?
       +-- cost-type-names*       string
       +-- time-interval-size     decimal64
       +-- number-of-intervals    uint32
  grouping endpoint-cost-cap:
    +---u filter-costmap-cap
  grouping algorithm:
    +-- (algorithm)
~~~
{: #tree-alto-server-rsc title='IETF ALTO Resource Subtree Structure' artwork-align="center"}

A "resource" list entry MUST include a unique "resource-id" and a "resource-type".

It may also include an "accepted-role" node containing a list of "role-name"s
that is used by role-based access control for this ALTO information resource.
See [](#alto-rbac) for details of information resource access control.

For some "resource-type", the "resource" entry may also include a
"dependency" node containing the "resource-id" of the dependent ALTO information
resources (Section 9.1.5 of {{RFC7285}}).

For each type of ALTO information resource, the "resource" entry may also need
type-specific parameters. These type-specific parameters include two categories:

1. One category of the type-specific parameters is common for the same type
   of ALTO information resource. They declare the Capabilities of the ALTO
   information resource (Section 9.1.3 of {{RFC7285}}).
2. The other category of the type-specific parameters is algorithm-specific.
   The developer of the ALTO server can implement their own creation algorithms
   and augment the "algorithm" node to declare algorithm-specific input
   parameters.

Except for the "ird" resource, all the other types of "resource" entries have
an augmented "algorithm" node. The augmented "algorithm" node can reference data
sources subscribed by the "data-source" entries (See [](#data-source)). An
example of extending the "algorithm" node for a specific type of "resource" is
included in [](#example-alg).

The developer does not have to customize the creation algorithm of the "ird"
resource. The default "ird" resource will be created automatically based on all
the added "resource" entries. The delegated "ird" resource will be created as a
static ALTO information resource (Section 9.2.4 of {{RFC7285}}).


### ALTO Information Resource Access Control Management {#alto-rbac}

As per Section 15.5.2 of {{RFC7285}}, the "ietf-alto" module also defines
authentication and authorization related configuration to employ access control
at the information resource level. The ALTO server returns the IRD to the ALTO
client based on its authentication information.

The information resource access control is supported using the structure shown in {{tree-auth}}.

~~~
module: ietf-alto
  +--rw alto!
     ...
     +--rw alto-server
        ...
        +--rw auth-client* [client-id]
        |  +--rw client-id                  string
        |  +--rw (authentication)?
        |     +--:(http)
        |     |  +--rw http-auth-client
        |     |          {http-listen,http:client-auth-supported,
        |     |           http:local-users-supported}?
        |     |     +--rw user-id    leafref
        |     +--:(https)
        |        +--rw https-auth-client
        |                {http:client-auth-supported,
        |                 http:local-users-supported}?
        |           +--rw user-id    leafref
        +--rw role* [role-name]
        |  +--rw role-name    role-name
        |  +--rw client*
        |          -> /alto/alto-server/auth-client/client-id
        ...
~~~
{: #tree-auth title='IETF ALTO Client Authentication Subtree Structure' artwork-align="center"}

The above structure can be used to configure the role-based access control:

- "auth-client" declares a list of ALTO clients that can be authenticated by
  the internal or external authorization server. This basic model only includes
  authentication approach directly provided by the HTTP server, but the
  operators or future documents can augment the "authentication" choice for
  different authentication mechanisms.
- "role" defines a list of roles for access control. Each role contains a list
  of authenticated ALTO clients. Each client can be assigned to multiple roles.
  The "role-name" can be referenced by the "accepted-role" list of a
  "resource". For a given authenticated ALTO client, if one of the roles
  containing it is allowed to access a resource, this client is allowed to
  access the resource.

# Design of ALTO O&M Statistics Data Model {#alto-stats-model}

The "ietf-alto-stats" module augments the "ietf-alto" module to include
statistics at the ALTO server and information resource level ({{tree-stat}}).

~~~
module: ietf-alto-stats

  augment /alto:alto/alto:alto-server:
    +--ro num-total-req?         yang:counter64
    +--ro num-total-succ?        yang:counter64
    +--ro num-total-fail?        yang:counter64
    +--ro num-total-last-req?    yang:gauge64
    +--ro num-total-last-succ?   yang:gauge64
    +--ro num-total-last-fail?   yang:gauge64
  augment /alto:alto/alto:alto-server/alto:resource:
    +--ro num-res-upd?    yang:counter64
    +--ro res-mem-size?   yang:gauge64
    +--ro res-enc-size?   yang:gauge64
    +--ro num-res-req?    yang:counter64
    +--ro num-res-succ?   yang:counter64
    +--ro num-res-fail?   yang:counter64
  augment /alto:alto/alto:alto-server/alto:resource
            /alto:resource-params/alto:networkmap
            /alto:alto-networkmap-params:
    +--ro num-map-pid?   yang:gauge64
  augment /alto:alto/alto:alto-server/alto:resource
            /alto:resource-params/alto:propmap
            /alto:alto-propmap-params:
    +--ro num-map-entry?   yang:gauge64
  augment /alto:alto/alto:alto-server/alto:resource
            /alto:resource-params/alto:cdni/alto:alto-cdni-params:
    +--ro num-base-obj?   yang:gauge64
  augment /alto:alto/alto:alto-server/alto:resource
            /alto:resource-params/alto:update/alto:alto-update-params:
    +--ro num-upd-sess?      yang:gauge64
    +--ro num-event-total?   yang:gauge64
    +--ro num-event-max?     yang:gauge64
    +--ro num-event-min?     yang:gauge64
    +--ro num-event-avg?     yang:gauge64
~~~
{: #tree-stat title='IETF ALTO Statistics Structure' artwork-align="center"}


## Model for ALTO Server Failure Monitoring

To satisfy R6 in [](#requirements), the "ietf-alto-stats" module contains statistics that indicates server failures ({{tree-stat}}).

More specifically, "num-total-*" and "num-total-last-*" provides server-level
failure counters; "num-res-*" provides information resource-level failure
counters.

## Model for ALTO-specific Performance Monitoring

To satisfy R7 in [](#requirements),the "ietf-alto-stats" module also contains statistics for ALTO-specific performance metrics ({{tree-stat}}).

More specifically, this data model contains the following measurement
information of "system and service performance" suggested by {{RFC7285}} and
{{RFC7971}}:

- Requests and responses for each information resource
- CPU and memory utilization
- ALTO map updates
- Number of PIDs
- ALTO map sizes

Besides the above measurement information suggested by {{RFC7285}} and {{RFC7971}},
the "ietf-alto-stats" module also contains useful measurement information for other ALTO
extensions:

- "num-map-entry" and "num-base-obj" provides measurement for number of generic
  ALTO entities (for {{RFC9240}} and {{RFC9241}})
- "num-upd-sess" and "num-event-*" provides statistics for update sessions and
  events (for {{RFC8189}})

The "ietf-alto-stats" module only focuses on the performance metrics that can be directly
measured at the ALTO server. The following metrics for "measurement of the
impact" suggested by {{RFC7971}} are not contained in this data model:

- Total amount and distribution of traffic
- Application performance

<!-- End of sections -->
