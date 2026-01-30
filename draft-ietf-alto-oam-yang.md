---
docname: draft-ietf-alto-oam-yang-latest
title: YANG Data Models for the Application-Layer Traffic Optimization (ALTO) Protocol
abbrev: ALTO O&M YANG
category: std

ipr: trust200902
area: Networks
workgroup: ALTO WG
keyword: Automation, Service Provisioning, Control, Operation

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
    region: Sichuan
    code: 610000
    country: China
    org: Sichuan University
    email: kaigao@scu.edu.cn
 -
    ins: R. Schott
    name: Roland Schott
    organization: Deutsche Telekom
    email: Roland.Schott@telekom.de
    street: Deutsche-Telekom-Allee 9
    city: Darmstadt
    code: 64295
    country: Germany
 -
    ins: Q. Ma
    name: Qiufang Ma
    street: "101 Software Avenue, Yuhua District"
    city: Nanjing
    region: Jiangsu
    code: 210012
    country: China
    org: Huawei
    email: maqiufang1@huawei.com

normative:
  RFC2119:
  RFC3688:
  RFC5424:
  RFC6020:
  RFC6241:
  RFC6991:
  RFC7285:
  RFC7286:
  RFC8040:
  RFC8342:
  RFC8174:
  RFC8189:
  RFC8341:
  RFC8686:
  RFC8895:
  RFC8896:
  RFC9240:
  RFC9241:
  RFC9274:
  RFC9275:
  RFC9439:
  RFC9641:
  RFC9643:
  RFC9645:
  I-D.ietf-netconf-http-client-server:
  I-D.ietf-netconf-netconf-client-server:
  I-D.ietf-netconf-restconf-client-server:
informative:
  RFC7921:
  RFC7971:
  RFC8346:
  RFC8641:


--- abstract

This document defines a YANG data model for Operations, Administration, and
Maintenance (OAM) & Management of the Application-Layer Traffic Optimization (ALTO)
Protocol. The operator of an ALTO server can use this data model to (1) set
up the ALTO server, (2) configure server discovery, (3) create, update and
remove ALTO information resources, (4) manage the access control of each ALTO
information resource, and (5) collect statistical data from the ALTO server. The
application provider can also use this data model to configure ALTO clients
to communicate with known ALTO servers.

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

# ALTO OAM YANG Modules

## The "ietf-alto" YANG Module

~~~ yang
{::include yang/ietf-alto.yang}
~~~
{: sourcecode-markers="true" sourcecode-name="ietf-alto@2026-01-26.yang"}

## The "ietf-alto-stats" YANG Module

~~~ yang
{::include yang/ietf-alto-stats.yang}
~~~
{: sourcecode-markers="true" sourcecode-name="ietf-alto-stats@2026-01-26.yang"}

{::include others.md}

--- back

{::include-nested appendix.md}

{::include ack.md}
