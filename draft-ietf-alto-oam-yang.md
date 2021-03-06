---
docname: draft-ietf-alto-oam-yang-latest
title: A Yang Data Model for OAM and Management of ALTO Protocol
abbrev: ALTO O&M YANG
category: std

ipr: trust200902
area: Networks
workgroup: ALTO WG
keyword: ALTO, Internet-Draft

stand_alone: yes
pi:
  strict: yes
  comments: yes
  inline: yes
  editing: no
  toc: yes
  tocompact: yes
  tocdepth: 3
  iprnotified: no
  sortrefs: yes
  symrefs: yes
  compact: yes
  subcompact: no

author:
 -
    ins: J. Zhang
    name: Jingxuan Jensen Zhang
    organization: Tongji University
    email: jingxuan.n.zhang@gmail.com
    street: 4800 Cao'An Hwy
    city: Shanghai
    code: 201804
    country: China
 -
    ins: D. Dhody
    name: Dhruv Dhody
    organization: Huawei Technologies
    email: dhruv.ietf@gmail.com
    street: Divyashree Techno Park, Whitefield
    city: Bangalore
    region: Karnataka
    code: 560066
    country: India
 -
    ins: K. Gao
    name: Kai Gao
    street: "No.24 South Section 1, Yihuan Road"
    city: Chengdu
    code: 610000
    country: China
    org: Sichuan University
    email: kaigao@scu.edu.cn
 -
    ins: R. Schott
    name: Roland Schott
    organization: Deutsche Telekom
    email: Roland.Schott@telekom.de
    street: Heinrich-Hertz-Strasse 3-7
    city: Darmstadt
    code: 64295
    country: Germany

normative:
  RFC2119:
  RFC3688:
  RFC6020:
  RFC6991:
  RFC7285:
  RFC7286:
  RFC8174:
  RFC8177:
  RFC8189:
  RFC8340:
  RFC8686:
  RFC8895:
  RFC8896:
informative:
  RFC7921:
  RFC7971:
  RFC8346:
  I-D.ietf-alto-path-vector:
  I-D.ietf-alto-unified-props-new:
  I-D.ietf-alto-performance-metrics:
  I-D.ietf-alto-cdni-request-routing-alto:

--- abstract

This document defines a YANG data model for Operations, Administration,
and Maintenance (OAM) & Management of Application-Layer Traffic Optimization
(ALTO) Protocol. The operator can use the data model to create and update ALTO
information resources, manage the access control, configure server-to-server
communication and server discovery, and collect statistical data.

--- middle

{::include introduction.md}

{::include term.md}

{::include objectives.md}

{::include design.md}

<!--
Note: current kramdown-rfc tool does not support recursive inclusion.
Simply put the YANG module section here and wait for a future update.
See details: https://github.com/cabo/kramdown-rfc/issues/106
-->

# ALTO OAM YANG Module

## The ietf-alto Module

~~~ yang
{::include yang/ietf-alto.yang}
~~~
{: sourcecode-markers="true" sourcecode-name="ietf-alto@2022-07-11.yang"}

## The ietf-alto-stats Module

~~~ yang
{::include yang/ietf-alto-stats.yang}
~~~
{: sourcecode-markers="true" sourcecode-name="ietf-alto-stats@2022-07-11.yang"}

{::include others.md}

--- back

{::include appendix.md}

{::include ack.md}
