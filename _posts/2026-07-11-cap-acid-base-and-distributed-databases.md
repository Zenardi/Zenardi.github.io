---
title: 'System Design: The CAP Theorem, ACID, BASE & Distributed Databases'
tags: [System Design, Distributed Systems, Databases, CAP, PACELC]
style: fill
color: primary
description: A practical tour of the trade-offs behind distributed databases — the CAP theorem, ACID vs BASE, the "pick two" combinations, and how PACELC extends the picture beyond network partitions.
---

> This article is an English adaptation of my study notes on distributed-database trade-offs, based on Matheus Fidelis's original (Portuguese) piece, *"System Design — Teorema CAP, ACID, BASE e Bancos de Dados Distribuídos"* ([fidelissauro.dev/teorema-cap](https://fidelissauro.dev/teorema-cap/)). Full credit for the original framing and illustrations goes to the author — I recommend reading the source. Any errors introduced in translation and rework are my own.

Choosing a database for a distributed system is rarely about picking the "fastest" or the "most popular" option. It's about understanding what you are willing to give up. Every distributed data store makes a deliberate trade-off between **consistency**, **availability**, and its behaviour when the network misbehaves — and the theory that frames those trade-offs is the **CAP theorem**.

This post walks through CAP from the ground up: first the transactional guarantees (**ACID** and **BASE**) that give CAP its vocabulary, then the theorem itself and its "pick two" combinations, and finally **PACELC** — the extension that asks the question CAP leaves unanswered: *what do you optimise for when the network is healthy?*

---

## The CAP Theorem

The **CAP theorem** summarises three properties of a distributed database:

- **Consistency (C)** — every read reflects the most recent write.
- **Availability (A)** — every request receives a (non-error) response.
- **Partition Tolerance (P)** — the system keeps working even when the network splits.

It was formulated by **Eric Brewer** (UC Berkeley) at a conference in the year 2000 and shaped how architects reasoned about distributed systems for the next two decades.

The central idea: a distributed system can only guarantee **two of the three** properties at any given moment. The classic analogy is *"Good, Fast, Cheap — pick two"*: each combination forces you to give up the third property.

To really understand each letter of CAP, though, you first need the vocabulary of **ACID** and **BASE** — the two philosophies that describe how transactions and operations behave inside a database.

---

## ACID and BASE — the trade-off between SQL and NoSQL

There are two families of guarantees that drive transaction and query design: **ACID** and **BASE**. Each represents a distinct philosophy about the balance between reliability and availability. Understanding the difference is essential for anyone who designs or operates distributed databases, because it *precedes* and *justifies* the choice of a specific technology.

### The ACID model — Atomicity, Consistency, Isolation, Durability

**ACID** databases execute transactional operations atomically and reliably, usually favouring write integrity over raw performance and availability. This is the typical behaviour of **traditional SQL databases**.

**Atomicity** guarantees that a transaction is treated as an *indivisible unit*: either every operation completes successfully, or none is applied. Think of an e-commerce sale that combines two dependent operations — decrementing stock and recording the sale. If only one were applied, you'd get accounting and logistics inconsistencies. In practice this looks like a Go transaction using `database/sql`:

```go
tx, err := db.Begin()
if err != nil {
    return err
}

if _, err := tx.Exec("UPDATE products SET stock = stock - 1 WHERE id = ?", productID); err != nil {
    tx.Rollback() // any failure reverts the whole unit
    return err
}

if _, err := tx.Exec("INSERT INTO sales (product_id, amount) VALUES (?, ?)", productID, amount); err != nil {
    tx.Rollback()
    return err
}

return tx.Commit() // only commit when BOTH statements succeed
```

**Consistency** guarantees that every transaction moves the database from one *valid* state to another valid state, preserving integrity and rejecting corrupt or invalid records. In practice this means honouring the rules defined in the schema: foreign keys, nullability constraints, triggers, and data types. Trying to insert a string into a decimal column, or writing a value outside the allowed range, fails validation.

**Isolation** guarantees that concurrent transactions operate *without interfering* with one another, as if each ran on its own. Isolation levels exist to prevent anomalies such as **dirty reads** (reading uncommitted data), **non-repeatable reads** (the same query returns different values within one transaction), and **phantom reads** (new rows appear when a read is repeated). The architectural challenge is balancing isolation against throughput: high isolation reduces concurrency; low isolation increases it at the cost of possible inconsistencies.

**Durability** guarantees that once a transaction is committed, it *stays persisted* even in the face of failure — written to non-volatile storage (disk), not just memory. This matters most where data loss would have serious consequences.

### The BASE model — Basically Available, Soft State, Eventual Consistency

Where ACID prioritises precision and reliability, **BASE** takes a more flexible stance aimed at modern distributed systems, where availability and fault tolerance weigh more heavily. Like CAP, BASE was also proposed by Brewer and collaborators.

**Basically Available** means the system is designed to *maximise availability* without promising it to be total and uninterrupted. It responds most of the time, but some data or functionality may be temporarily unavailable during a failure, maintenance window, or partition. To achieve this, data is **partitioned and replicated** across many servers, so the system stays operational despite partial failures. NoSQL stores such as Dynamo, Cassandra, and MongoDB rely on exactly these strategies.

**Soft State** accepts that the state of the system may *change over time* even without external input. Data can expire or be updated automatically, with no guarantee of permanent consistency unless it is periodically revalidated. This is common in distributed caches like **Memcached** and **Redis**, where records self-manage, expire, and get replaced to track the source of truth.

**Eventual Consistency** describes the *asynchronous* replication of writes between nodes: for some interval, different nodes may hold different versions of the same datum. The word "eventual" is the promise that, absent new changes, all nodes will converge to the same state at some point. This model suits high-latency networks or node-failure-prone environments, keeping the system operational despite temporary inconsistency — the foundation of stores like Cassandra and DynamoDB.

---

## The components of CAP, explained

With ACID and BASE understood, mapping each letter of CAP to a familiar guarantee becomes straightforward.

### Consistency (C)

CAP consistency guarantees that all nodes expose the **same version of the data at the same time** — no matter which node you query, the answer is always the most recent write. This usually requires a write to wait for replication confirmation across nodes before the data is readable. It is indispensable where atomicity and freshness are critical, such as financial systems and hospital records.

### Availability (A)

Availability guarantees that **every request receives a response**, even if the queried node doesn't hold the most recent version. When availability is prioritised, a read may return stale data, because writes and reads operate independently — a write can be acknowledged before replication finishes. This is valuable in high-throughput, ingestion-heavy scenarios such as streaming and analytics, and is typically achieved through **replication**.

### Partition Tolerance (P)

Partition tolerance is the system's ability to keep operating even when the network splits and two or more groups of nodes can no longer communicate. In distributed environments it's prudent to *assume* that network failures, hardware faults, and scheduled maintenance **will** happen. A partition-tolerant system offers continuity in the face of these partial failures — especially relevant for geographically distributed apps, social networks, log aggregators, event brokers, and queueing systems.

### What is a network partition?

In CAP terms, a **network partition** is a systemic communication failure between two or more nodes that prevents them from synchronising and produces temporary inconsistency — a situation that worsens when writes are distributed. In clusters optimised for partition tolerance, it's common to deliberately **isolate a node** for maintenance, troubleshooting, or upgrades, then reintegrate it later via synchronisation. When communication is restored, the database must be able to **replicate and resolve conflicts** across all nodes to resume consistent operation.

---

## The combinations: "pick two"

### CP — Consistency + Partition Tolerance

The system preserves consistency and partition tolerance, **sacrificing availability**. During a partition, inconsistent nodes can be taken offline — becoming unavailable — until consistency is restored. This is the right call when data accuracy is non-negotiable: financial systems, credit-scoring engines, inventory control.

*Examples:* MongoDB, Cassandra (under certain configurations), Couchbase, etcd, Consul.

### AP — Availability + Partition Tolerance

The system prioritises availability and partition tolerance, **giving up consistency**. During a partition, every node keeps answering requests, even if it may return stale data while re-synchronisation happens. This makes sense when continuity matters more than constant accuracy: e-commerce search, social networks, search engines.

*Examples:* CouchDB, DynamoDB, Cassandra (under certain configurations), SimpleDB.

### CA — Consistency + Availability

The system guarantees consistency and availability but is **sensitive to partitions** — a network failure can render it fully inoperable. That's why it's rare in genuinely distributed environments, which generally must tolerate partitions. It shows up in centralised stores like Redis Standalone and centralised SQL (MySQL, PostgreSQL), commonly adopted to guarantee ACID operations.

*Examples:* MySQL/MariaDB, PostgreSQL, Oracle, SQL Server, Redis Standalone, Memcached Standalone.

---

## CAP "flavors" reference table

A quick reference for where common databases sit in the CAP triangle:

| Database | Consistency (C) | Availability (A) | Partition Tolerance (P) |
| :--- | :---: | :---: | :---: |
| Cassandra | — | ✓ | ✓ |
| MongoDB | ✓ | — | ✓ |
| Couchbase | ✓ | — | ✓ |
| DynamoDB | — | ✓ | ✓ |
| Redis | ✓ | ✓ | — |
| MySQL/MariaDB | ✓ | ✓ | — |
| PostgreSQL | ✓ | ✓ | — |
| Oracle | ✓ | ✓ | — |
| etcd | ✓ | — | ✓ |
| Consul | ✓ | — | ✓ |
| CockroachDB | ✓ | — | ✓ |
| Riak | — | ✓ | ✓ |
| HBase | ✓ | — | ✓ |
| Neo4j | ✓ | ✓ | — |
| FoundationDB | ✓ | — | ✓ |
| VoltDB | ✓ | ✓ | — |
| ArangoDB | ✓ | ✓ | — |
| FaunaDB | ✓ | ✓ | — |
| Aerospike | — | ✓ | ✓ |
| Amazon Aurora | ✓ | ✓ | — |
| CouchDB | — | ✓ | ✓ |
| SimpleDB | — | ✓ | ✓ |

> These classifications are simplifications — many of these systems can be *tuned* toward different corners of the triangle depending on their write/read concern and replication settings.

---

## What changed after CAP was conceived?

In 2012, Eric Brewer published **"CAP Twelve Years Later: How the 'Rules' Have Changed,"** revisiting his original proposal in light of the evolution of databases, cloud, and microservice architectures.

The main point is to **demystify the "2 of 3" rule**, which is misleading in practice. Treating consistency and availability as binary on/off states constrains architecture decisions, when in reality they behave as **spectra** with varying degrees of realisation — availability, for instance, can range from 0 to 100%, and there are many levels of consistency.

A second point: **network partitions are rare events** in many workloads. Since the system operates without partitions most of the time, you can optimise consistency *and* availability jointly during those periods, instead of assuming failures are constantly present as the original reading suggested.

In short, CAP remains useful for early design discussions, but it's a simplification: "2 of 3" isn't strictly exclusive, and there are intermediate levels of consistency and availability — as the BASE model itself demonstrates.

---

## The PACELC Theorem

**PACELC** fills the gap CAP leaves open — namely, what the system should do **outside** of partition events. It was proposed by **Daniel Abadi** (Yale) in 2010.

CAP says that *during a partition* you must choose between consistency and availability. Valuable — but it ignores an important question: what should the system prioritise when there is **no** network failure?

PACELC extends the reasoning with a formula:

> **If** there is a **P**artition, choose between **A**vailability and **C**onsistency; **E**lse (**E**), choose between **L**atency and **C**onsistency.

In other words, even without failures there's a trade-off: guarantee strong consistency at the cost of higher latency, or relax consistency to respond faster. This mirrors the reality of modern systems with geographically distributed networks, replication, and sharding. A global database that requires all replicas to sync before acknowledging a write pays the latency price; if it accepts eventual consistency, it responds faster — but a user in Brazil might see different data from a user in Spain for a while.

### PACELC vs CAP

CAP only covers the partition case (P): choose between Consistency (C) and Availability (A). It says nothing about behaviour under normal operation. PACELC is **complementary**: it analyses both the failure scenario *and* the healthy-operation behaviour, connecting the CP and AP patterns to the Latency-vs-Consistency choice outside partitions.

---

## Applying PACELC

PACELC became a practical way to **classify** distributed systems into combinations of **PA/EL, PC/EL, PA/EC, and PC/EC**, according to the trade-offs adopted inside and outside partitions.

**PA/EL** *(On Partition → Availability; Else → Latency)* — In normal operation the system prioritises **latency** over consistency, seeking fast responses even if consistency weakens. During a partition it prioritises **availability** — every node keeps responding, reinforcing eventual consistency even without fully-synced replicas. Built for high-performance, resilient writes, accepting that users may see slightly different versions until the partition resolves. *Examples: DynamoDB, Cassandra.*

**PC/EL** *(On Partition → Consistency; Else → Latency)* — In normal operation the system favours **latency and throughput**, lowering the consistency level to stay fast. During a partition it prioritises **consistency**, potentially becoming unavailable until the cluster recovers consensus. An intermediate choice, typical of systems without reliable high-volume conflict resolution. It relies on continuous **health checks** and **heartbeats** between nodes; otherwise it prefers to go fully unavailable rather than keep data that may never converge.

**PA/EC** *(On Partition → Availability; Else → Consistency)* — In normal operation the system prioritises **strong consistency**, keeping all replicas on the same version. Under a failure or partition it prioritises **availability**, accepting temporary divergence. These systems often lean on **CRDTs** (Conflict-Free Replicated Data Types) to reconcile concurrent updates. A less common, hybrid model where eventual consistency acts only as a *fallback* to strong consistency.

**PC/EC** *(On Partition → Consistency; Else → Consistency)* — The most conservative model: it prioritises **consistency both in normal operation and during partitions**, accepting higher latency in exchange for guaranteeing the latest version on every node. During a partition it assumes it's better to fail temporarily than to operate with *any* inconsistency. Typical of systems where accuracy is paramount — banks, cluster coordination, critical transactions. Found in traditional SQL databases, in **etcd**, and in geographically distributed transactional databases such as **Google Spanner**.

### PACELC comparison table

| System / Database | PAC (during partition) | ELC (no partition) | Classification | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Amazon DynamoDB** | A (availability) | L (low latency, eventual by default) | PA/EL | Eventual consistency as default, with optional "strong reads." |
| **Cassandra** | A (availability) | L (low latency, eventual by default) | PA/EL | Dynamo-inspired, tuned for global availability and low latency. |
| **MongoDB** | A (`w=1`) or C (majority write concern) | L (eventual on secondaries) | PA/EL or PC/EL | Flexible; the trade-off depends on write/read concern. |
| **Google Spanner** | C (strong global consistency) | C (prioritises consistency even without a partition) | PC/EC | Uses TrueTime for globally serialisable consistency, at a latency cost. |
| **Azure Cosmos DB** | A (availability) | L/C (configurable: eventual → strong) | PA/ELC | Offers five configurable consistency levels. |
| **Apache Kafka** | A (availability) | L (throughput and low latency) | PA/EL | Weak consistency guarantees; focus on availability and speed. |
| **etcd** | C (strong consistency) | C (strong consistency) | PC/EC | Strong consistency for critical coordination systems. |
| **ZooKeeper** | C (strong consistency) | C (strong consistency) | PC/EC | Strong consistency for critical coordination systems. |
| **CockroachDB** | C (consistency during partitions) | C (strong consistency via Raft consensus) | PC/EC | Spanner-inspired; global consistency in exchange for higher latency. |
| **Redis (Cluster mode)** | A (availability; may lose data on failure) | L (low latency, async replication) | PA/EL | Speed-focused; strong consistency not guaranteed on partition/failover. |
| **Amazon RDS (Multi-AZ)** | C (synchronous cross-AZ replication) | C (consistent across replicas before ack) | PC/EC | Designed for transactional workloads, guaranteeing consistency and durability. |

---

## Key takeaways

- **CAP is a starting point, not a verdict.** It's excellent for framing early design discussions, but the "pick two" rule is a simplification — consistency and availability are spectra, not switches.
- **ACID vs BASE precedes the database choice.** Decide how much you value write integrity (ACID) versus availability and horizontal scale (BASE) *before* you shortlist technologies.
- **Partition tolerance is not optional** in a genuinely distributed system — network failures *will* happen, so the real choice is usually **CP vs AP**.
- **PACELC completes the picture** by forcing the latency-vs-consistency decision for the (common) case when the network is healthy. That's often where your day-to-day performance actually comes from.
- **Most systems are tunable.** DynamoDB can do strong reads; MongoDB's guarantees shift with write concern. Treat these labels as defaults, then configure for your workload.

---

## References

- [Seth Gilbert and Nancy Lynch. 2002. Brewer's conjecture and the feasibility of consistent, available, partition-tolerant web services. SIGACT News 33, 2](https://dl.acm.org/doi/10.1145/564585.564601)
- [Theo Haerder and Andreas Reuter. 1983. Principles of transaction-oriented database recovery. ACM Comput. Surv. 15, 4](https://doi.org/10.1145/289.291)
- [Eric Brewer. 2012. CAP Twelve Years Later: How the "Rules" Have Changed](https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed/)
- [Daniel Abadi. Consistency Tradeoffs in Modern Distributed Database System Design (PACELC)](https://www.cs.umd.edu/~abadi/papers/abadi-pacelc.pdf)
- [Martin Kleppmann. 2015. A Critique of the CAP Theorem](https://arxiv.org/abs/1509.05393)
- [Martin Kleppmann. Please stop calling databases CP or AP](https://martin.kleppmann.com/2015/05/11/please-stop-calling-databases-cp-or-ap.html)
- [PACELC design principle — Wikipedia](https://en.wikipedia.org/wiki/PACELC_design_principle)
- [What is the CAP theorem? — IBM](https://www.ibm.com/topics/cap-theorem)
- [Understanding Eventual Consistency in DynamoDB — Alex DeBrie](https://www.alexdebrie.com/posts/dynamodb-eventual-consistency/)
- **Original article (Portuguese):** [Matheus Fidelis — System Design: Teorema CAP, ACID, BASE e Bancos de Dados Distribuídos](https://fidelissauro.dev/teorema-cap/)
