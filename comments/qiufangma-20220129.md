Hi Qiufang,

Many thanks for your comments and YANG code! We will use your YANG code as
a base to complete our next revision. Thanks for your contribution.

Your comments on the scope of this document are also very valuable.

Thanks,
Jensen

On Sat, Jan 29, 2022 at 5:13 PM maqiufang (A) <maqiufang1@huawei.com> wrote:

> Hi, authors,
>
> Thanks for writing this draft.
> As Adrian mentioned, there is no YANG code in this document.
> I tried to work it out according to the given YANG tree diagram. Please
> refer to the attachment, which I hope can help to make this work more
> complete


> In general, I think the scope still needs to clean up, i.e., what is in
> the scope, what is not in the scope. The relation between objectives and
> requirements are not clear. I think requirements should completely align
> with section 16 of RFC7285.
> Requirements in Section 3.2 and Section 3.4 of RFC7971 should also be
> considered.


> Here are few detailed comments:
> 1.            Section 4
> The requirements are only selected from section 16.1, section 16.2.2,
> section 16.2.4, section 16.2.5, section 16.2.6, what about other sections?
>

This is a very good point. Other reviewers also mentioned this. We will
align with considerations proposed by RFC7285.


> Do we need to configure granularity of the topology map and cost map?
> e.g., configure default two PIDs, default cost between source PID and dst
> PID?
> How filter service is modelled? How do we set filter input as empty?
> How do we model network information from other entities such as
> geo-location, or round trip time measurement?


> How do we model using other protocol such as IGP BGP to collect
> information and fed into ALTO server


> How do we provide monitoring information to service provider? E.g.,
> monitoring correctness, responsive of ALTO server
> How do we allow disable ALTO guidance for a portion of ALTO client by
> time, geographical region or other criteria?
>

Many thanks. Those are very good questions to help us complete the missing
parts of this document.


> 2.            Section 4
> How logging and fault management is modelled in this draft?
> Should we configure ALTO server to provide logging service? E.g., using
> syslog
> Do we need to define control module to provide logging or fault management?
> You might reference rfc8194 for example
>

Yes, as Sec 16.1 and Sec 16.3 of RFC7285 suggest, logging and fault
management should be considered.
Thanks for the reference.


> 3.            Section 4.1 said:
> "
> Data model for performance monitoring for operation purpose
> "
> OAM or FCAPS should comprise of not only performance monitoring, but also
> fault management, security management, configuration management?
> Do we leave fault management beyond scope of this document?
>

It should be on the scope. But we need more discussion about how to model
this part.


> 4.            Section 4.1 said:
> "
>    *  Data structures for how to store/deliver ALTO information
>       resources (e.g., network map, cost map, property map).
>    *  Specific algorithms for ALTO information resource generation.
>    *  Data structures for how to store information collected from data
> sources.


> "
> What is the relationship between bullet 1 and Bullet 3?
>

Bullet 1 is about the data structure for ALTO maps generated by the ALTO
server.
Bullet 2 is about the raw data from different data sources, e.g., i2rs
topology, routing tables, lsdb.


> 5.            Section 4.2 title
> What is the relation between requirements and Objectives?
>

We will merge the two parts into a single section.


> 6.            Section 5.1
> s/ adminstrated/administrated
> 7.            Section 5.3
> s/resoruce/resource
> s/ altorithms/algorithm


>
> Best Regards,
> Qiufang Ma