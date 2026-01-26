# Design Scope and Requirements {#sec-req}

## Scope of Data Models for ALTO O&M {#scope}

The following items are in the scope of the data models specified in this document:

- Deploying an ALTO server/client.
- Operating and managing an ALTO server/client.
- Configuring functionality/capability configuration of ALTO services.
- Monitoring ALTO-related performance metrics.

This document does not normatively define any data model related to a specific
implementation, including:

- Data structures for how to store/deliver ALTO information resources (e.g.,
  database schema to store a network map).
- Data structures for how to store information collected from data sources.
  (e.g., database schema to store topology collected from an Interface to the
  Routing System (I2RS) client {{RFC7921}})

Likewise, the specification does not cover considerations that are specific to the ALTO Transport Information Publication Service (TIPS) {{?RFC9569}}. Specifically, considerations related to HTTP/3 are out of scope.

For convenience, examples of how related extensions can be defined are provided in the Appendices.

## Basic Requirements {#requirements}

Based on recommendations in {{RFC7285}} and {{RFC7971}}, the
data models provided by this document satisfy basic requirements listed in
[](#TableReq).

| Requirement                                                                                         | Reference                                                 |
| --------------------------------------------------------------------------                          | --------------------------------------------------------- |
| R1: The data model should support configuration for ALTO server setup.                              | Section 16.1 of {{RFC7285}}                               |
| R2: The data model should provide logging management.                                               | Section 16.2.1 of {{RFC7285}}                             |
| R3: The data model should provide ALTO-related management information.                              | Section 16.2.2 of {{RFC7285}}                             |
| R4: The data model should support configuration for security policy management.                     | Section 16.2.6 of {{RFC7285}}                             |
| R5-1: The data model should support basic configuration to receive data from different data sources.| Section 16.2.4 of {{RFC7285}}, Section 3.2 of {{RFC7971}} |
| R5-2: The data model should support configuration for information resource generation algorithms.   | Section 16.2.4 of {{RFC7285}}                             |
| R5-3: The data model should support configuration for access control at information resource level. | Section 16.2.4 of {{RFC7285}}                             |
| R6: The data model should provide metrics for server failures.                                      | Section 16.2.3 of {{RFC7285}}, Section 3.3 of {{RFC7971}} |
| R7: The data model should provide performance monitoring for ALTO-specific metrics.                 | Section 16.2.5 of {{RFC7285}}, Section 3.4 of {{RFC7971}} |
{: #TableReq title="Basic Requirements of Data Model for ALTO O&M."}

## Additional Requirements for Extensibility {#extra-req}

R8: As the ALTO protocol is extensible, the data models for ALTO O&M should
allow for augmentation to support potential future extensions.

<!-- End of sections -->
