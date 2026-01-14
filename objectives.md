# Design Scope and Requirements {#sec-req}

## Scope of Data Model for ALTO O&M {#scope}

The following items are in the scope of the data models specified in this document:

- Deploying an ALTO server/client.
- Operating and managing an ALTO server/client.
- Functionality/capability configuration of ALTO services.
- Monitoring ALTO-related performance metrics.

This document does not define any data model related to specific
implementation, including:

- Data structures for how to store/deliver ALTO information resources (e.g.,
  database schema to store a network map).
- Data structures for how to store information collected from data sources.
  (e.g., database schema to store topology collected from an Interface to the
  Routing System (I2RS) client {{RFC7921}})

## Basic Requirements {#requirements}

Based on discussions and recommendations in {{RFC7285}} and {{RFC7971}}, the
data model provided by this document satisfies basic requirements listed in
[](#TableReq).

| Requirement                                                                                         | Reference                                                 |
| --------------------------------------------------------------------------                          | --------------------------------------------------------- |
| R1: The data model should support configuration for ALTO server setup.                              | Section 16.1 of {{RFC7285}}                               |
| R2: The data model should provide logging management.                                               | Section 16.2.1 of {{RFC7285}}                             |
| R3: The data model should provide ALTO-related management information.                              | Section 16.2.2 of {{RFC7285}}                             |
| R4: The data model should support configuration for security policy management.                     | Section 16.2.6 of {{RFC7285}}                             |
| R5-1: The data model should support configuration for different data sources.                       | Section 16.2.4 of {{RFC7285}}, Section 3.2 of {{RFC7971}} |
| R5-2: The data model should support configuration for information resource generation algorithms.   | Section 16.2.4 of {{RFC7285}}                             |
| R5-3: The data model should support configuration for access control at information resource level. | Section 16.2.4 of {{RFC7285}}                             |
| R6: The data model should provide metrics for server failures.                                      | Section 16.2.3 of {{RFC7285}}, Section 3.3 of {{RFC7971}} |
| R7: The data model should provide performance monitoring for ALTO-specific metrics.                 | Section 16.2.5 of {{RFC7285}}, Section 3.4 of {{RFC7971}} |
{: #TableReq title="Basic Requirements of Data Model for ALTO O&M."}

## Additional Requirements for Extensibility {#extra-req}

R8: As the ALTO protocol is extensible, the data model for ALTO O&M should
allow for augmentation to support potential future extensions.

## Overview of ALTO O&M Data Model for Reference ALTO Architecture

[](#alto-ref-arch) shows a reference architecture for the ALTO server
implementation and YANG modules that these server components need to implement.
The server manager, information resource manager and data source listeners need
to implement "ietf-alto.yang" (see [](#alto-model)). The performance monitor
and logging and fault manager need to implement "ietf-alto-stats.yang" (see
[](#alto-stats-model)).

The data broker and algorithm plugins are not in the scope of the data models
defined in this document. But user-specified YANG modules can be applied to
different algorithm plugins by augmenting the data model defined in this
document (see [](#alto-ext-model)).

~~~
  +----------------------+      +-----------------+
  | Performance Monitor: |<-----| Server Manager: |
  | ietf-alto-stats.yang |<-+ +-| ietf-alto.yang  |
  +----------------------+  | | +-----------------+
                          report
  +----------------------+  | | +-------------------+
  | Logging and Fault    |  +---| Information       |
  | Manager:             |<---+ | Resource Manager: |
  | ietf-alto-stats.yang |<-----| ietf-alto.yang    |
  +----------------------+      +-------------------+
                                         ^|
                                         || callback
                                         |v
     .............          ..............................
    /             \ ------> . Algorithm Plugin:          .
    . Data Broker .  read   . example-ietf-alto-alg.yang .
    ...............         ..............................
           ^
           | write
  +----------------+  Southbound  ++=============++
  | Data Source    |     API      ||             ||
  | Listener:      | <==========> || Data Source ||
  | ietf-alto.yang |              ||             ||
  +----------------+              ++=============++
~~~
{: #alto-ref-arch title="A Reference ALTO Server Architecture and YANG Modules"}

<!-- End of sections -->
