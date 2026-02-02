# Design of ALTO O&M Data Model {#alto-model}

## Overview of ALTO O&M Data Model

The "ietf-alto" module is designed to fit all the requirements listed in [](#sec-req).

As shown in {{tree-str}}, the top-level container "alto" in the "ietf-alto"
module contains a list "alto-client" and a single "alto-server" container.

The "alto-client" list defines a list of configurations for other applications
to bootstrap an ALTO client. These data nodes can also be used by data sources and information
resource creation algorithms that are configured by an ALTO server instance.

The container "alto-server" contains both configuration and operational
data of an administrated ALTO server instance.

~~~
module: ietf-alto
  +--rw alto!
     +--rw alto-client* [client-id] {alto-client}?
     |  ...
     +--rw alto-server {alto-server}?
        +...
        +--rw auth-client* [client-id]
        |  ...
        +--rw role* [role-name]
        |  +--rw role-name    role-name
        |  +--rw client*      client-ref
        +--rw data-source* [source-id]
        |  ...
        +--rw resource* [resource-id]
           ...
~~~
{: #tree-str title='IETF ALTO Tree Structure' artwork-align="center"}

## Data Model for ALTO Client Operation and Management

As shown in {{tree-alto-client}}, the "alto-client" contains a list of
client-side configurations. Each "alto-client" entry contains the following
data nodes:

"client-id":
  : A unique identifier that can be referenced by other applications.

"server-discovery-client":
  : A container that is used to configure how this ALTO client discovers an ALTO server.



~~~
module: ietf-alto
  +--rw alto!
     +--rw alto-client* [client-id] {alto-client}?
     |  +--rw client-id                  string
     |  +--rw server-discovery
     |     +---u alto-server-discovery-client
      ...
~~~
{: #tree-alto-client title='IETF ALTO Client Subtree Structure' artwork-align="center"}

## Data Model for Server-level Operation and Management

The ALTO server instance contains a set of data nodes for server-level operation and management for ALTO that are shown in {{tree-alto-server-level}}. This structure satisfies R1 - R4 in [](#requirements).

~~~
module: ietf-alto
  +--rw alto!
     ...
     +--rw alto-server {alto-server}?
        +--rw listen
        |  +---u alto-server-listen-stack
        +--rw server-discovery
        |  +---u alto-server-discovery
        +--rw logging-system
        |  +---u alto-logging-system
        +--rw cost-type* [cost-type-name]
        |  +--rw cost-type-name    cost-type-name
        |  +--rw cost-mode         identityref
        |  +--rw cost-metric       identityref
        |  +--rw description?      string
        |  +--rw cost-context {performance-metrics}?
        |     +--rw cost-source    identityref
        |     +--rw parameters
        |        +--rw (parameters)?
        +--rw meta* [meta-key]
        |  +--rw meta-key      meta-key
        |  +--rw meta-value    binary
        ...
~~~
{: #tree-alto-server-level title='IETF ALTO Server Level Subtree Structure' artwork-align="center"}

### Data Model for ALTO Server Setup

To satisfy R1 in [](#requirements), the ALTO server instance contains the
basic data nodes for the server setup that are detailed in the following subsections.

#### ALTO Server Listen Stack

The container "listen" contains all the data nodes for the whole server listen stack
across TCP, TLS, HTTP and application layers ({{tree-alto-gp}}).

~~~
  grouping alto-server:
    +-- base-uri?   inet:uri
  grouping alto-server-listen-stack:
    +-- (transport)
       +--:(http) {http-listen}?
       |  +-- http
       |     +-- tcp-server-parameters
       |     |  +---u tcp:tcp-server-grouping
       |     +-- http-server-parameters
       |     |  +---u http:http-server-grouping
       |     +-- alto-server-parameters
       |        +---u alto-server
       +--:(https)
          +-- https
             +-- tcp-server-parameters
             |  +---u tcp:tcp-server-grouping
             +-- tls-server-parameters
             |  +---u tls:tls-server-grouping
             +-- http-server-parameters
             |  +---u http:http-server-grouping
             +-- alto-server-parameters
                +---u alto-server
~~~
{: #tree-alto-gp title='IETF ALTO Server Groupings Structure' artwork-align="center"}

The "transport" choice node enables which protocol layers to be configured. By
default, two cases are defined for different deployment scenarios:

- The "http" case is provided to support scenarios where the TLS-termination is
  handled by other external components, e.g., reverse proxies or ingress
  controllers.
- The "https" case is provided to support scenarios where the whole HTTPS
  server listen stack including TLS is handled by the ALTO server itself.

#### ALTO Server Discovery Setup

In practice, for a large-scale network consisting of multiple administrative
domains, the information about the network may be partitioned and distributed
over multiple ALTO servers. That may require discovery and communication among
different ALTO servers.

The "ietf-alto" module provides the configuration for how an ALTO server can be
discovered by another ALTO server or client on demand ({{tree-alto-disc-gp}}).
However, it does not contain any configuration for the communication among ALTO
servers because the related solution has not become a standard. Future
documents may extend it to fully support multi-domain scenarios.

~~~
  grouping alto-server-discovery:
    +-- (method)?
       +--:(reverse-dns) {xdom-disc}?
          +-- rdns-naptr-records
             +-- static-prefix*           inet:ip-prefix
             +-- dynamic-prefix-source*   data-source-ref
~~~
{: #tree-alto-disc-gp title='IETF ALTO Server Discovery Grouping Structure' artwork-align="center"}

The "server-discovery" node provides configuration for the discovery of ALTO servers
using a variety of mechanisms. The initial version of the "ietf-alto" module only defines the "reverse-dns"
case that is used to configure DNS NAPTR records for ALTO server discovery
as suggested by {{RFC7286}} and {{RFC8686}}. It configures a set of
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
the logging data nodes shown in {{tree-alto-log-gp}}.

The "logging-system" data node provides configuration to select a logging system to
capture log messages generated by an ALTO server.

By default, "syslog" is the only supported logging system. When selecting
"syslog", the related configuration is delegated to the configuration file of
the syslog {{RFC5424}} server.

~~~
  grouping alto-logging-system:
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
     +--rw alto-server {alto-server}?
        ...
        +--rw data-source* [source-id]
        |  +--rw source-id                    source-id
        |  +--rw source-type                  identityref
        |  +--rw source-params
        ...
~~~
{: #tree-data-src title='IETF ALTO Server Data Source Subtree Structure' artwork-align="center"}

As shown in {{tree-data-src}}, a "data-source" list entry includes:

- A unique "source-id" for resource creation algorithms to reference.
- The "source-type" attribute to declare the type of the data source.
- The "source-params" to specify where and how to query the data.

The "data-source/source-params" node can be augmented for different types of
data sources. Note that the purpose of this node is not to fully set up the
communication mechanisms for specific data sources, but to maintain how data
sources are configured and expose them to the ALTO server.

This data model only includes a basic structure for an ALTO server
to correctly interact with a data source. The implementation-specific parameters
of any certain data source can be augmented in another module. An example is
included in [](#example-data-source).

### ALTO Information Resources Configuration Management

To satisfy R5-2 and R-3 in [](#requirements), the ALTO server instance contains a list of "resource"
entries ({{tree-alto-server-rsc}}). Each "resource" entry contains the data nodes of an ALTO
information resource (See Section 8.1 of {{RFC7285}}). The operator of the ALTO
server can use this model to create, update, and remove the ALTO information
resources.

Each "resource" entry provides data nodes defining how to create or update
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
     +--rw alto-server {alto-server}?
        ...
        +--rw resource* [resource-id]
           +--rw resource-id                 resource-id
           +--rw resource-type               identityref
           +--rw description?                string
           +--rw accepted-role*              role-ref
           +--rw dependency*                 resource-ref
           +--rw alto-ird-params
           |  +--rw delegation    inet:uri
           +--rw alto-networkmap-params
           |  +--rw is-default?   boolean
           |  +--rw filtered?     boolean
           |  +---u algorithm
           +--rw alto-costmap-params
           |  +--rw filtered?             boolean
           |  +---u filter-costmap-cap
           |  +---u algorithm
           +--rw alto-endpointcost-params
           |  +---u filter-costmap-cap
           |  +---u algorithm
           +--rw alto-endpointprop-params
           |  +--rw prop-type*   endpoint-property
           |  +---u algorithm
           +--rw alto-propmap-params {propmap}?
           |  +---u algorithm
           +--rw alto-cdni-params {cdni}?
           |  +---u algorithm
           +--rw alto-update-params {incr-update}?
           |  +---u algorithm
           +--rw resource-limits
              +--rw notify-res-mem-limit?      uint64
              +--rw notify-upd-stream-limit?   uint64
                      {incr-update}?

  notifications:
    +---n alto-resource-event {alto-server}?
       +--ro resource-id                    resource-ref
       +--ro notify-res-mem-threshold?      uint64
       +--ro notify-upd-stream-threshold?   uint64 {incr-update}?

  grouping filter-costmap-cap:
    +-- cost-type-name*            cost-type-ref
    +-- cost-constraints?          boolean
    +-- max-cost-types?            uint32 {multi-cost}?
    +-- testable-cost-type-name*   cost-type-ref {multi-cost}?
    +-- calendar-attributes {cost-calendar}?
       +-- cost-type-name*        cost-type-ref
       +-- time-interval-size     decimal64
       +-- number-of-intervals    uint32
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
type-specific parameters. These type-specific parameters can be split into two categories:

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

Each "resource" entry may also set thresholds of memory usage and active update
streams (if "incr-update" feature is enabled). [](#TableThreshold) describes
limits that, once exceeded, will trigger notifications to be generated:


| Notification Threshold  | Description                                                                                                                                                                                    |
| ----------------------  | -----------                                                                                                                                                                                    |
| notify-res-mem-limit    | Used to notify high memory utilization of the resource configured to an ALTO server instance. When exceeded, an alto-resource-event will be generated.                                |
| notify-upd-stream-limit | Used to notify a high number of active update streams that are serviced by an update resource configured to an ALTO server instance. When exceeded, an alto-resource-event will be generated. |
{: #TableThreshold title="Notification Thresholds."}


### ALTO Information Resource Access Control Management {#alto-rbac}

To satisfy R-3 in [](#requirements) and as per Section 15.5.2 of {{RFC7285}}, the "ietf-alto" module also defines
authentication and authorization related configuration to employ access control
at the information resource level. The ALTO server returns the IRD to the ALTO
client based on its authentication information.

The information resource access control is supported using the structure shown in {{tree-auth}}.

~~~
module: ietf-alto
  +--rw alto!
     ...
     +--rw alto-server {alto-server}?
        ...
        +--rw auth-client* [client-id]
        |  +--rw client-id                  string
        |  +--rw (authentication)?
        |     +--:(http)
        |     |  +--rw http-auth-client
        |     |          {http-listen,http:client-auth-supported,
        |     |           http:local-users-supported}?
        |     |     +--rw user-id    http-user-id-ref
        |     +--:(https)
        |        +--rw https-auth-client
        |        |       {http:client-auth-supported,
        |        |        http:local-users-supported}?
        |        |  +--rw user-id?   https-user-id-ref
        |        +--rw tls-auth-client
        |                {http:client-auth-supported}?
        |           +--rw ca-cert {tls:client-auth-x509-cert}?
        |           |  +---u inline-or-truststore-ca-cert-ref
        |           +--rw ee-cert {tls:client-auth-x509-cert}?
        |           |  +---u inline-or-truststore-ee-cert-ref
        |           +--rw raw-public-key
        |           |       {tls:client-auth-raw-public-key}?
        |           |  +---u inline-or-truststore-public-key-ref
        |           +--rw tls12-psks?       empty
        |           |       {tls:client-auth-tls12-psk}?
        |           +--rw tls13-epsks?      empty
        |                   {tls:client-auth-tls13-epsk}?
        +--rw role* [role-name]
        |  +--rw role-name    role-name
        |  +--rw client*      client-ref
        ...
~~~
{: #tree-auth title='IETF ALTO Client Authentication Subtree Structure' artwork-align="center"}

The structure shown in {{tree-auth}} can be used to configure the role-based access control:

- "auth-client" declares a list of ALTO clients that can be authenticated by
  the internal or external authorization server. This basic model only includes
  authentication approach directly provided by the HTTP or TLS server, but the
  operators or future documents can augment the "authentication" choice for
  different authentication mechanisms.
- "role" defines a list of roles for access control. Each role contains a list
  of authenticated ALTO clients. Each client can be assigned to multiple roles.
  The "role-name" can be referenced by the "accepted-role" list of a
  "resource". If an authenticated ALTO client is included in any roles with
  access permission to a resource, the client is granted access to that
  resource.

# Design of ALTO O&M Statistics Data Model {#alto-stats-model}

The "ietf-alto-stats" module augments the "ietf-alto" module to include
statistics at the ALTO server and information resource level ({{tree-stat}}).

~~~
module: ietf-alto-stats

  augment /alto:alto/alto:alto-server:
    +--rw server-level-monitor-config
    |  +--rw time-window-size?   uint32
    +--ro server-level-stats
       +---u server-level-stats
  augment /alto:alto/alto:alto-server/alto:resource:
    +--ro resource-level-stats
       +---u resource-level-stats

  grouping server-level-stats:
    +-- discontinuity-time?    yang:timestamp
    +-- last-report-time?      yang:timestamp
    +-- num-total-req?         yang:counter64
    +-- num-total-succ?        yang:counter64
    +-- num-total-fail?        yang:counter64
    +-- num-total-last-req?    yang:gauge64
    +-- num-total-last-succ?   yang:gauge64
    +-- num-total-last-fail?   yang:gauge64
  grouping network-map-stats:
    +-- num-map-pid?   yang:gauge64
  grouping prop-map-stats:
    +-- num-map-entry?   yang:gauge64
  grouping cdni-stats:
    +-- num-base-obj?   yang:gauge64
  grouping upd-stream-stats:
    +-- num-upd-stream?           yang:gauge64
    +-- num-upd-msg-total?        yang:gauge64
    +-- num-upd-msg-max?          yang:gauge64
    +-- num-upd-msg-min?          yang:gauge64
    +-- num-upd-msg-avg?          yang:gauge64
    +-- num-upd-msg-total-last?   yang:gauge64
    +-- num-upd-msg-max-last?     yang:gauge64
    +-- num-upd-msg-min-last?     yang:gauge64
    +-- num-upd-msg-avg-last?     yang:gauge64
  grouping resource-level-stats:
    +-- discontinuity-time?    yang:timestamp
    +-- last-report-time?      yang:timestamp
    +-- num-res-upd?           yang:counter64
    +-- res-mem-size?          uint64
    +-- res-enc-size?          uint64
    +-- num-res-req?           yang:counter64
    +-- num-res-succ?          yang:counter64
    +-- num-res-fail?          yang:counter64
    +-- num-res-last-req?      yang:gauge64
    +-- num-res-last-succ?     yang:gauge64
    +-- num-res-last-fail?     yang:gauge64
    +-- network-map-stats
    |  +---u network-map-stats
    +-- endpoint-prop-stats
    |  +---u prop-map-stats
    +-- property-map-stats
    |  +---u prop-map-stats
    +-- cdni-stats
    |  +---u cdni-stats
    +-- upd-stream-stats
~~~
{: #tree-stat title='IETF ALTO Statistics Structure' artwork-align="center"}


## Model for ALTO Server Failure Monitoring

To satisfy R6 in [](#requirements), the "ietf-alto-stats" module contains statistics that indicate server failures ({{tree-stat}}).

More specifically, "num-total-\*" and "num-total-last-\*" provide server-level
failure counters; "num-res-\*" and "num-res-last-\*" provide information
resource-level failure counters.

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

- "num-map-entry" and "num-base-obj" provide measurement for number of generic
  ALTO entities (for {{RFC9240}} and {{RFC9241}})
- "num-upd-stream" and "num-upd-msg-\*" provide statistics for update streams and
  messages (for {{RFC8189}})

The "ietf-alto-stats" module only focuses on the performance metrics that can be directly
measured at the ALTO server. The following metrics for "measurement of the
impact" suggested by {{RFC7971}} are not contained in this data model:

- Total amount and distribution of traffic
- Application performance

<!-- End of sections -->
