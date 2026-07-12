---
title: 'System Design: Data Replication'
tags: [System Design, Distributed Systems, Databases, Replication, Consistency]
style: fill
color: primary
description: 'Keeping multiple copies of data in sync across nodes — the Primary-Replica and Multi-Master models, the synchronous / asynchronous / semi-synchronous / log-based strategies, and the architectural patterns behind them: Event-Carried State Transfer, Change Data Capture, and CRDTs.'
---

Think about your house keys. Relying on a single copy that travels with you all day is risky — lose it once and you're locked out. So you leave spares with people you trust, or in a strategic hiding spot. **Data replication** is that same instinct applied to systems: keep more than one copy of the same information in more than one place, so the loss of a single point never takes everything down.

This post walks through replication end to end: the two foundational **models** (Primary-Replica and Multi-Master), the **strategies** that trade consistency against performance (synchronous, asynchronous, semi-synchronous, log-based), and the **architectural patterns** that apply replication far beyond a database's built-in features — Event-Carried State Transfer, Change Data Capture, and CRDTs.

---

## Defining replication

Replicating data means, in practice, keeping **more than one copy of the same information in different places**. In software, those copies can live on distinct nodes, in geographically separate datacenters, or even across different regions of a public cloud. The purpose is to ensure data stays accessible despite hardware failures or network problems, sustaining the requirements of **consistency, availability, and fault tolerance**.

In essence, replication guarantees the same information exists in several locations, letting the system keep operating even when one of its parts stops responding. Full consistency may take some time to be re-established, depending on the effort needed to promote a replica to the primary source.

---

## Replication models

Regardless of *how* the copies are maintained, the nodes tend to be organised in one of two arrangements: **Primary-Replica** or **Primary-Primary** (also called **Multi-Master**). Understanding both conceptually is the foundation for the practical strategies that follow.

### Primary-Replica

In this model, a **primary node concentrates all write operations** and propagates changes to one or more secondary nodes — the replicas. Those replicas usually serve reads only, which spreads query load across many nodes while writes stay simple and centralised. It fits read-heavy workloads well, and pairs especially nicely with **CQRS**, where the replicas back optimised read models.

The downside is that the primary becomes a **single point of failure**. If it goes down, one of the replicas must be promoted to new primary — a process whose duration varies by technology and often requires manual intervention, producing temporary unavailability and errors in the meantime.

### Primary-Primary (Multi-Master)

Here, **multiple nodes act as primaries simultaneously**, accepting both reads and writes. Any node can process updates, which are then replicated to the others — favouring high availability and scalability on the *write* path too.

The advantage is eliminating the Primary-Replica single point of failure and gaining flexibility in load distribution. In exchange comes significant extra complexity: **resolving write conflicts**. When two nodes accept concurrent writes to the same datum, the system needs a tie-breaking strategy — ordering operations by timestamp, or applying specific resolution policies — especially during the temporary partitioning caused by network failures.

{% include elements/figure.html image="/assets/img/blog/replication-multi-master.svg" caption="Multi-Master (Primary-Primary): every node accepts reads and writes, replicating changes to the others." %}

---

## Replication strategies

Replication shows up combined with many other engineering techniques — most commonly for data (its most important and complex use), but also for less obvious cases like replicating whole workloads or cached domains. These are the most-used strategies, with the trade-offs that tell you when each makes sense.

### Full vs partial replication

In **full replication**, all data is copied to every node, so each node holds a complete copy. This maximises availability — any node can serve any request — but raises storage cost and write latency, since every write must be confirmed on all nodes in the cluster. Academically it's also called *full-table replication*.

In **partial replication**, each node keeps only a fraction of the data. The result is better storage efficiency and lower write latency, at the cost of more complex reads: the datum you want may not be local, requiring inter-node communication or a query layer that abstracts the dispersion. To locate the data, systems typically lean on sharding algorithms such as **consistent hashing**.

### Synchronous replication

In synchronous replication, a write is only considered complete **after every node has confirmed applying it**. That delivers **strong consistency**: any node queried, at any moment, returns the same value, because no read ever sees the datum before the cluster-wide confirmation.

In practice, the client sends the datum to the cluster's primary endpoint, which distributes it to all nodes; the operation only returns success when they all answer "ok." A classic technique to implement this is **two-phase commit**. The payoff is obvious in domains where divergence is unacceptable, such as payments and financial systems. The cost is **higher latency**, made worse when nodes are numerous or geographically distant.

{% include elements/figure.html image="/assets/img/blog/replication-synchronous.svg" caption="Synchronous replication: the write is confirmed only after every node acknowledges it — strong consistency, higher latency." %}

### Asynchronous replication

Here a write is sent to one node and propagated to the others **eventually**, letting the operation be confirmed to the client before all replicas are updated. The effect is **much better write performance**, since there's no wait for collective confirmations.

The price is **eventual consistency**: queries issued right after a write may return different versions of the datum until replication completes. That's why the model is widely adopted where availability and performance matter more than immediate consistency — social networks, CDN assets, cache clusters, and less-critical data used to offload the origin.

{% include elements/figure.html image="/assets/img/blog/replication-asynchronous.svg" caption="Asynchronous replication: the write is acknowledged immediately and propagated to replicas eventually — fast writes, eventual consistency." %}

### Semi-synchronous replication

This model is a middle ground: it requires **at least one replica (or a small subset) to confirm the write** before the operation is deemed successful, letting the remaining nodes update asynchronously afterward.

The result is a **balance between consistency and performance**, with an extra layer of resilience: you get synchronous durability on at least one node without paying the latency of confirming all of them. Databases like **MySQL** and **MariaDB** follow this logic, acknowledging the write as soon as a secondary has stored it, while other nodes catch up later.

{% include elements/figure.html image="/assets/img/blog/replication-semi-synchronous.svg" caption="Semi-synchronous replication: at least one replica confirms before success; the remaining nodes catch up asynchronously." %}

### Log-based replication

In this approach, **every operation is recorded sequentially in a log**, and that log is replicated to the other nodes, which re-execute the same operations locally. Instead of copying the full data state, only the *changes* travel between nodes, keeping replicas consistent by replaying those changes.

It's advantageous when there are more writes than reads, or when volume is very large, because only the modifications move between nodes, reducing traffic. Mature technologies like **Apache Kafka** use log-based replication: each partition of a topic has its changes recorded in transaction logs replicated across brokers, guaranteeing durability and resilience.

The same idea underpins foundational distributed-systems algorithms — **Paxos** (BigTable, Apache Mesos), **Raft** (etcd, ScyllaDB, Consul, CockroachDB), and **Viewstamped Replication** (TigerBeetle) — plus techniques like the **write-ahead log (WAL)**, which ensures durability during replication even in the face of node failures.

{% include elements/figure.html image="/assets/img/blog/replication-log-based.svg" caption="Log-based replication: operations are appended to a sequential log and replayed on every replica." %}

---

## Architectural patterns

Although replication is most associated with the built-in features of caches and databases, it can be applied **manually and far more broadly** to solve architectural challenges. Used strategically, it lets you scale distributed systems intelligently. Here are three patterns that combine replication with other techniques for large-scale performance and scalability.

### Event-Carried State Transfer

In large, complex enterprise systems, **Event-Carried State Transfer** is an effective way to handle high availability over big data volumes. The pattern transmits the **state of an object between services or domains via events**, combining cache, event-driven architecture, and replication — a costly but powerful strategy that reduces coupling.

The core idea: whenever an entity in a domain is updated, the change is published to an events topic. Dependent services consume those events and update their **own local stores**, keeping a cached copy of the state. Instead of querying a central source on every request, each service works with its own version of the data — especially useful where eventual consistency is tolerable.

A good example is a government system sharing citizen data across banking, tax, security, traffic, and social agencies. When marital status, income, address, or phone changes in a central registry, an event notifies each system, which then updates its own base.

{% include elements/figure.html image="/assets/img/blog/replication-ecst.svg" caption="Event-Carried State Transfer: domain changes are published as events, and each dependent service updates its own local copy." %}

### Change Data Capture (CDC)

**Change Data Capture (CDC)** detects and captures the changes made to a data source — relational or not — and streams them to other systems in real time. That keeps external services up to date **without querying the origin database directly**, which is valuable for synchronising data, feeding message queues, and keeping caches fresh.

The mechanism monitors inserts, updates, and deletes, capturing them as they happen. The captured changes can then be sent to event topics or straight to dependent systems, avoiding overloading the main database with constant polling.

CDC serves as the foundation for other strategies, including Event-Carried State Transfer itself, which uses these events to replicate data proactively. It also enables streaming to data lakes, proactive caching, and CQRS — acting as a reactive bridge between the source and the other integration patterns.

{% include elements/figure.html image="/assets/img/blog/replication-cdc.svg" caption="Change Data Capture: inserts, updates, and deletes are captured at the source and streamed to dependent systems in real time." %}

### CRDTs — Conflict-Free Replicated Data Types

In distributed replication — especially the **primary-primary / multi-master** arrangements — **CRDTs** *(Conflict-Free Replicated Data Types)* solve the model's biggest challenge: **handling conflicts between concurrent updates to the same datum**. When different nodes receive distinct versions of the same record, something has to decide the final version — and CRDTs do it automatically, with no coordination or locking between nodes.

Picture a collaborative document editor: if two people, on different nodes, change the same line at the same time, a CRDT-based system merges the changes automatically, producing a final version with no manual intervention and no conflict.

The guarantee comes from mathematical properties that make the operations **associative, commutative, and idempotent**: the order in which updates arrive doesn't change the final result. Even with nodes updating the datum independently, synchronisation leads to a consistent final state. Because they dispense with locks and coordination, each node operates autonomously — raising availability and ensuring **eventual consistency**, with all nodes converging on the same copy. That makes CRDTs especially well-suited to primary-primary environments, where every node accepts writes simultaneously.

---

## Key takeaways

- **Replication is about surviving the loss of a node.** Multiple copies in multiple places mean a single hardware or network failure degrades the system instead of stopping it.
- **The model decides where writes go.** Primary-Replica centralises writes (simple, but a single point of failure); Multi-Master accepts writes everywhere (highly available, but you must resolve conflicts).
- **The strategy is a consistency-vs-latency dial.** Synchronous buys strong consistency at the cost of latency; asynchronous buys speed at the cost of eventual consistency; semi-synchronous splits the difference.
- **Log-based replication ships changes, not state.** Replaying an ordered log is how Kafka, Raft, Paxos, and write-ahead logs keep replicas consistent while minimising traffic.
- **Replication is an architectural tool, not just a database feature.** Event-Carried State Transfer, CDC, and CRDTs push copies to where they're needed — reducing coupling and offloading the origin.
- **CRDTs make multi-master conflicts disappear.** Associative, commutative, idempotent operations converge to the same state regardless of arrival order — no locks, no coordination.

---

## References

- [What Is Data Replication? — ManageEngine](https://www.manageengine.com/device-control/data-replication.html)
- [7 Data Replication Strategies & Real-World Use Cases — Estuary](https://estuary.dev/data-replication-strategies/)
- [Replication and Partitioning in Cassandra — Baeldung](https://www.baeldung.com/cassandra-replication-partitioning)
- [Two-Phase Commit — Martin Fowler (Patterns of Distributed Systems)](https://martinfowler.com/articles/patterns-of-distributed-systems/two-phase-commit.html)
- [What Is Change Data Capture? — Qlik](https://www.qlik.com/us/change-data-capture/cdc-change-data-capture)
- [About Change Data Capture (SQL Server) — Microsoft](https://learn.microsoft.com/en-us/sql/relational-databases/track-changes/about-change-data-capture-sql-server)
- [Event-Carried State Transfer Pattern — Graham Brooks](https://www.grahambrooks.com/event-driven-architecture/patterns/stateful-event-pattern/)
- [Event-Carried State Transfer: A Pattern for Distributed Data Management — dev.to](https://dev.to/cadienvan/event-carried-state-transfer-a-pattern-for-distributed-data-management-in-event-driven-systems-165h)
- [A Gentle Introduction to CRDTs — vlcn.io](https://vlcn.io/blog/intro-to-crdts)
- [CRDTs: The Hard Parts — Martin Kleppmann](https://martin.kleppmann.com/2020/07/06/crdt-hard-parts-hydra.html)
