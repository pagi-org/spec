

Portable Analytics Graphical Interchange
========================================

#### J. Bunting, J. Swisher

#### 1 August 2013

##### Draft 1

Abstract
--------

The document describes a specification for the interchange of analytic
information on textual data, represented as a graph. It describes a model, a
schema format, several transfer formats, and a set of common APIs.

Table of Contents
-----------------

1. [Introduction](#introduction)
2. [Definitions](#definitions)
3. [Graph Representation](#graph-representation)
    1. [Document Structure](#doc-structure)
    2. [Node Structure](#node-structure)
    3. [Property Types](#property-types)
    4. [Features](#features)
    5. [ID Generation](#id-generation)
    6. [Traits](#traits)
4. [Schema Syntax](#schema-syntax)
    1. [Core Syntax](#core-schema)
    2. [Extending Schemas](#extending-schemas)
    3. [Diagrammatical Representations](#diagramming)
5. [Transfer Formats](#transfer-formats)
    1. [XML](#xml-format)
    2. [Binary](#binary-format)
    3. [JSON](#json-format)
6. [Common APIs](#commons-apis)
    1. [Graph Query](#graph-query)
    2. [Event-Based Streaming](#event-based-streaming)
    3. [Streaming Graphical Querying (Hybrid)](#streaming-graphical-querying)
7. [Corpus-Scoped Analytics](#corpus-scoped-analytics)
8. [Future Scope](#future-scope)


Introduction {#introduction}
----------------------------

The basic data model used to perform analytics on a document is a graph. Each
document is represented as a graph, with the nodes in that graph representing
analytic results, features, and properties. Additionally, these nodes may have
relationships to other nodes in the graph.

For example, a node may represent a single word of text (or "token"). That node
may then have a child relationship to a node representing the phrase of which
the word is a part (a "chunk"). The chunk node may have other children,
representing other words in the phrase. Each of these nodes may have additional
properties, describing the analytic component that generated the node, a
confidence associated with the node, and so on.

By defining this specification in a generic manner, we gain the ability to
develop programs that work with any pagi-compliant schema. This provides us
with three powerful tools for future growth: 

1. a common language to discuss adding new types of information to our schema
2. a common language to extend our schema for situation-specific installations
   or experiments
3. the ability to write programs and tooling that work with the model in a 
   generic way, allowing those programs and tools to continue to work with
   future iterations of the schema


Definitions {#definitions}
--------------------------

node
:   A single piece of analytic information. 

node-type
:   The type of a node -- defined in the schema. (Examples: token, chunk, temporal)

edge
:   A relationship between two nodes. 

property
:   A key-value pair attached to a node and specified in the schema. (Examples:
    "provenance"="NLPTokenizer", "confidence"=0.963, "startOffset"=15,
    "length"=3)

feature 
:   A key-value pair attached to a node. Features need not be specified within a
    schema. (Examples: "NW1"="dog")

id 
:   A string associated with a node that when combined with the node-type can
    uniquely identify the node within the current document. IDs need not be
    globally unique.

document-graph 
:   The graph consisting of all nodes and edges that reference a common source
    document.

pagi
:   Portable Analytic Graphical Interchange
:   This spec and everything that it encompasses.

pagis
:   Portable Analytic Graphical Interchange Schema
:   The schema and its language as described in this spec.

pagif
:   Portable Analytic Graphical Interchange Format
:   Any of the textual or binary formats used to represent a pagi graph. 
    Typically used with the format specified as a suffix, ie. pagif-xml, 
    pagif-json

pagim
:   Portable Analytic Graphical Interchange Model
:   The general model described by this spec.

spec
:   This document.

schema
:   A user-generated document that describes the node-types in use for a 
    particular application. 

source-document 
:   A single instance of text that is subject to analysis. Typically a single
    file within a filesystem.

Graph Representation {#graph-representation}
----------------------------------

### Document Structure {#doc-structure}

A document is represented as a graph. Each node in this graph represents a 
single piece of analytic information as described in the schema. The document 
also references an id and the document text.

### Node Structure {#node-structure}

The node is the pivotal structure in this model. 

* A node may represent any sort of information - a token, a sentence, a phrase,
  a category, a semantic role, a part of speech, etc. 
* A node has a node-type. All node-types are defined in the schema.
* A node has an ID. The ID is a string and is unique within the scope of a 
  node-type for a single document.
* A node has relationships to other nodes, the types of which are defined in the
  schema. 
* A node has properties which are additional key-value pairs of information. The
  names of the properties that a node has and the types of those properties are 
  defined by its type.
* A node has features which are additional arbitrary key-value pairs of 
  information. Features are typically used to carry transient information along
  with the model that will be thrown away later. Features are not specified in
  the schema. APIs may provide efficient ways to handle features such as 
  generating them on demand.

### Property Types {#property-types}

* Every property has a type. The allowable types are:
    * integer
    * float
    * boolean
    * string
* A property may be single or multiple valued. Minimum and Maximum arity
  may be specified as part of the schema.

### Features {#features}

* Every feature has a type. The allowable types are the same as those for a 
  property.
* Due to the lack of a schema definition, a feature may have zero or more 
  values.

### ID Generation {#id-generation}

* A node-type is repsonsible for defining how nodes of that type have their IDs
  generated.
* The generation strategy must produce unique IDs. If it does not, failures will
  occur at runtime.
* IDs are generated when a new node is created.

Available generation strategies:  

Randomly generated string
:    essentially uses an implementation-dependent random process to generated a 
     string. Length of the string may be specified in the schema.

Sequence
:    a sequence for the given type exists for the document. A new id is 
     generated by taking the current number of the sequence and incrementing 
     it. The order of ids is solely determined by the order in which nodes
     are generated. The sequence starts at 1.

Property
:    the value of one of the node's properties is used as the id. A delimiter 
     to combine mulitple values may be specified. By default the delimiter is
     a semi-colon (;).

Pattern
:    a format pattern will be used to generated the ID. This format pattern
     may contain raw strings and also may incorporate any of the other 
     generation strategies

### Traits {#traits}

A trait is a set of characteristics that may be assigned to a node-type.
It includes standard attributes and edges as well characteristics of that 
node-type that must be defined in the code. Traits are defined in the spec.

Currently defined traits:

Span
:    Describes a node-type that is associated with a contiguous sequence of
     characters within the source document.
:    Will have a nonnegative integer-valued property named "start" that refers
     to the character offset of the beginning of the referenced character
     sequence within the source document.
:    Will have a positive integer-valued property named "length" that refers to
     the number of consecutive characters in the referenced character sequence
     within the source document.
:    Distinct span nodes of the same span type must be non-overlapping.
     Specifically, for any two Span nodes A and B, of the same type and within
     the same document, then A.start != B.start. If, without loss of generality,
     we take A.start < B.start, then A.start + A.length <= B.start.
:    A span must reference text that exists within the source document.
     Specifically, if we take L to be the length of the source document in
     characters, then for any Span node A, A.start + A.length <= L.

Sequential
:    Describes a node-type that occurs in a sequence. 
:    The node-type must have an associated ordering that permits the formation
     of a strictly well-ordered set. (The natural ordering of a set of unique
     integers satisfies this condition.) [Wikipedia: Well-
     order](https://en.wikipedia.org/wiki/Well-order)
:    Following from the above, each node may have another instance of that same
     node-type before and after it.
:    May have a single edge named "previous" that refers to the preceding node of 
     the same type, if such a node exists.
:    May have a single edge named "next" that refers to the succeeding node of the
     same type, if such a node exists.
:    Previous and next edges, if present, must be bidirectional. If A.next = B,
     then B.previous = A, and conversely. (B.previous cannot be null and must be
     A given A.next = B, and A.next cannot be null and must be B given
     B.previous = A.)
:    The "previous" and "next" edges of a Sequential node, if present, must
     connect to the next node of the same type within the document, according to
     the associated ordering. That is, nodes connected under the Sequential
     trait must be consecutive.

Contains
:    Describes a node-type whose existence is defined as a container of another 
     node-type. 
:    Has the multi-valued edge named "contains" that refer to nodes of the 
     contained type.

Contains-Sequence
:    A special case of Contains where the contained node-type is Sequential. All
     contained nodes must be a single sequence.

Schema Syntax {#schema-syntax}
------------------------------

### Core Syntax {#core-schema}

A PAGI Schema is defined in an xml document.

Here is the general structure:

```xml
<pagis xmlns="http://pagi.digitalreasoning.com/pagis/" 
       pagis-uri="http://www.example.com/spec-example-1">
  <node-type named="" id-generator="">
    <trait name=""/>
    <property name="" type="" min="" max=""/>
    <edge name="" target-node-type="" min="" max=""/>
  </node-type>
</pagis>
```

### Extending Schemas {#extending-schemas}

Any schema can be extended.  This is done by specifying the `extends` attribute in 
the root `pagis` element. The new schema may specify new node-types or add edges
and properties to an existing node type.

Here is the general structure:
```xml
<pagis xmlns="http://pagi.digitalreasoning.com/pagis/"
       pagis-uri="http://www.example.com/spec-extension-example-1"
       extends="http://pagi.digitalreasoning.com/spec-example-1">
  <node-type named="" id-generator="">
    <trait name=""/>
    <property name="" type="" min="" max=""/>
    <edge name="" target-node-type="" min="" max=""/>
  </node-type>
  <node-type-extension name="">
    <property name="" type="" min="" max=""/>
    <edge name="" target-node-type="" min="" max=""/>
  </node-type-extension>
</pagis>
```

### Diagrammatical Representations {#diagramming}

In order to fully understand a schema, visualizations are often useful and 
necessary. To maximize the usefulness of visualizations, a standard for 
generating them is critical.

!!! todo
    Define visualization.


Transfer Formats {#transfer-formats}
------------------------------------

In order to store and transfer PAGIM models, we must define formats. 


### XML {#xml-format}

A PAGI document can be rendered as an xml document. This is intended as the 
primary storage and transfer format. It is simply structured and human-
readable. 

Its Internet Media Type is `application/vnd.drs-pagif+xml`.

Here is the general structure:

```xml 
<pagif xmlns="http://pagi.digitalreasoning.com/pagif/"
       id="">
  <node type="" id="">
    <property key="" integer=""/>
    <property key="">
      <value integer=""/>
    </property>
    <edge type="" target=""/>
    <feature key="">
      <value integer=""/>
    </feature>
  </node>
</pagif>
```

### Binary {#binary-format}

In order to facilitate efficient transfer and storage between components of
analytic applications, we define a binary format. Current thoughts are to
translate the xml or json formats to one of the following:

* msgpack (`application/vnd.drs-pagif+msgpack`)
* protobuf (`application/vnd.drs-pagif+protobuf`)

The decision of what binary serialization to use is still an open ended question.
We fully expect other options than these two to be proposed and considered.

### JSON {#json-format}

One common usage of PAGIF will be for inclusion in RESTful APIs and for 
in-browser editing. To facilitate this use case, a JSON format is specified.

Its Internet Media Type is `application/vnd.drs-pagif+json`.

Here is the general structure:

```json
{
  "id": "",
  "nodes": [
    {
      "type": "",
      "id": "",
      "properties":[
        {
          "key": "",
          "values": []
        }
      ],
      "edges":[
        {
          "type": "",
          "target": ""
        }
      ],
      "features":[
        {
          "key": "",
          "values": []
        }
      ]
    }
  ]
}
```
Common APIs {#commons-apis}
---------------------------

### Graph Query {#graph-query}
### Event-Based Streaming {#event-based-streaming}
### Streaming Graphical Querying (Hybrid) {#streaming-graphical-querying}

Corpus-Scoped Analytics {#corpus-scoped-analytics}
--------------------------------------------------

Future Scope {#future-scope}
----------------------------
