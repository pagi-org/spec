

Portable Analytics Graphical Interchange
========================================

#### J. Bunting, J. Swisher

#### 20 August 2013

##### Draft 2

Abstract {#abstract}
-------------------

The document describes a specification for the interchange of analytic
information on textual data, represented as a graph. It describes a model, a
schema format, several transfer formats, and a set of common APIs.

Table of Contents {#toc}
------------------------

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
    3. [Schema API](#schema-api)
5. [Common APIs](#commons-apis)
    1. [Event-Based Streaming](#event-based-streaming)
    2. [Graph Query](#graph-query)
    3. [Streaming Graphical Querying (Hybrid)](#streaming-graphical-querying)
6. [Transfer Formats](#transfer-formats)
    1. [XML](#xml-format)
    2. [Binary](#binary-format)
    3. [JSON](#json-format)
7. [Corpus-Scoped Analytics](#corpus-scoped-analytics)
8. [Future Scope](#future-scope)
9. [Appendices](#appendices)
    * [Appendix A: XML Format XSD](#xml-format-xsd)
    * [Appendix B: PAGI Schema XSD](#pagi-schema-xsd)


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
:   Pronounced with a hard 'G', rhymes with 'Maggie'
:   Derived acronyms typically have a suffix-consonant added, and are 
    pronounced the same except for the trailing 'i' transitioning from a long 
    "ee" sound to a short i

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

Nodes are the pivotal structures in this model. 

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
    * enumeration
* A property may be single or multiple valued. Minimum and Maximum arity
  may be specified as part of the schema.

* Some property types may allow the specification of constraints:

    * integer - minimum and maximum values may be specified, with `unbounded`
      being the default
    * float - minimum and maximum values may be specified, with `unbounded`
      being the default
    * enumeration - a list of possible values must be specified

### Features {#features}

* Every feature has a type. The allowable types are the same as those for a 
  property.
* Due to the lack of a schema definition, a feature may have zero or more 
  values.

### ID Generation {#id-generation}

* A node-type is repsonsible for defining how IDs are to be generated for nodes
  of that type.
* The generation strategy must produce IDs that are unique within a given
  document and node-type. If it does not, failures will occur at runtime.
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
Each trait will define properties that it imports to a node type, edge types
that it imports to a node type, and semantic restrictions on those. Traits may
also define parameters that must be supplied when they are defined on a node type.
Traits are only defined in the spec.

Currently defined traits:

#### Span
* Parameters
    * *none*
* Properties
    * **start** -- the offset from the beginning of the referenced character
                   sequence within the document
    * **length** -- the length of the referenced character sequence
* Edges
    * *none*
* Semantic Description
    * Describes a node-type that is associated with a contiguous sequence of
      characters within the source document.
    * Will have a nonnegative integer-valued property named "start" that refers
      to the character offset of the beginning of the referenced character
      sequence within the source document.
    * Will have a positive integer-valued property named "length" that refers to
      the number of consecutive characters in the referenced character sequence
      within the source document.
    * A span must reference text that exists within the source document.
      Specifically, if we take L to be the length of the source document in
      characters, then for any Span node A, A.start + A.length <= L.

#### Sequence
* Parameters
    * *none*
* Properties
    * *none*
* Edges
    * **next** -- refers to a node of the same type, has a maximum arity of 1. 
      If absent, indicates the final node of the sequence.

* Semantic Description
    * Describes a node-type that occurs in a sequence.
    * The node-type must have an associated ordering that permits the formation
      of a strictly well-ordered set. (The natural ordering of a set of unique
      integers satisfies this condition.) [Wikipedia: Well-
      order](https://en.wikipedia.org/wiki/Well-order)
    * Following from the above, each node may have another instance of that 
      same node-type before and after it.
    * May have a single edge named "previous" that refers to the preceding node
      of the same type, if such a node exists.
    * May have a single edge named "next" that refers to the succeeding node of
      the same type, if such a node exists.
    * Previous and next edges, if present, must be bidirectional. If A.next=B,
      then B.previous=A, and conversely. (B.previous cannot be null and must be
      A given A.next=B, and A.next cannot be null and must be B given
      B.previous=A.)
    * The "previous" and "next" edges of a Sequential node, if present, must
      connect to the next node of the same type within the document, according
      to the associated ordering. That is, nodes connected under the 
      Sequential trait must be consecutive.
    * A Sequence is defined as a connected set of nodes with the Sequential
      trait. A document may contain multiple Sequences of nodes of the same 
      type; this implies that there are no "previous" or "next" edges 
      connecting nodes of different Sequences.

#### Container
* Parameters
    * **edgeType** -- edgeType to consider as referring to "contained" nodes. 
      Exactly one edgeType must be specified. (A node-type may have multiple
      instances of the Container trait, together specifying multiple 
      edgeTypes).

* Properties
    * *none*
* Edges
    * *none*
* Semantic Description
    * Describes a node-type whose existence is defined as a container of 
      another node-type.
    * Parameter **edgeType** specifies names of edges which refer to 
      "contained" nodes.
    * May be specified more than once on a given node-type, each with a different
      **edgeType**.
    * Where multiple edgeTypes are specified for a node-type by multiple 
      instances of the Container trait, traversal APIs must enable referring to
      all "contained" edge types as a single construct. 

#### Span-Container
* Parameters
    * **spanType** -- the node type that is spanned/contained by this one - 
      must be a "Sequence" and one of either "Span" or "Span-Container"
* Properties
    * *none*
* Edges
    * **first** -- refers to the first node in the contained span
    * **last** -- refers to the last node in the contained span
* Semantic Description
    * Describes a node-type whose existence is defined as a span over other 
      nodes that define a span. These may be direct "Span" nodes, or other 
      "Span-Container" nodes. In both cases, the contained node type must also
      be "Sequential".
    * Traversal APIs must enable referring to the entire spanned text of a 
      "Span-Container".

Schema Syntax {#schema-syntax}
------------------------------

### Core Syntax {#core-schema}

A PAGI Schema is defined in an XML document. Note that this XML document, which
represents a PAGI-compliant schema, is distinct from the XML transfer format
used to represent a particular instance of a PAGI document graph.

Here is the general structure:

```xml
<pagis xmlns="http://pagi.digitalreasoning.com/pagis/" 
       pagis-uri="http://www.example.com/spec-example-1">
  <nodeType name="" idGenerator="">
    <span/>
    <sequence/>
    <container edge-type=""/>
    <spanContainer spanType=""/>
    <integerProperty name="" minRange="" maxRange="" minArity="" maxArity=""/>
    <floatProperty name="" minRange="" maxRange="" minArity="" maxArity=""/>
    <booleanProperty name="" minArity="" maxArity=""/>
    <stringProperty name="" minArity="" maxArity=""/>
    <enumProperty name="" minArity="" maxArity="">
      <item name=""/>
    </enum>
    <edgeType name="" targetNodeType="" minArity="" maxArity=""/>
  </nodeType>
</pagis>
```

The "min" and "max" XML attributes on property and edge XML elements refer to
the number of times a property or edge of the specified name may occur on a
single node of the specified node-type. For instance, an optional property may
be designated by the attributes min="0", max="1". A required edge that may occur
an arbitrary number of times (for instance, designating children of a node with
the Contains-Sequence trait) would be designated by the attributes min="1",
max="unbounded".

### Extending Schemas {#extending-schemas}

Any schema can be extended.  This is done by specifying the `extends` attribute in 
the root `pagis` element. The new schema may specify new node-types or add edges
and properties to an existing node type.

Here is the general structure:
```xml
<pagis xmlns="http://pagi.digitalreasoning.com/pagis/"
       pagis-uri="http://www.example.com/spec-extension-example-1"
       extends="http://pagi.digitalreasoning.com/spec-example-1">
  <nodeType name="" id-generator="">
    <span/>
    <sequence/>
    <container edgeType=""/>
    <spanContainer spanType=""/>
    <integerProperty name="" minRange="" maxRange="" minArity="" maxArity=""/>
    <floatProperty name="" minRange="" maxRange="" minArity="" maxArity=""/>
    <booleanProperty name="" minArity="" maxArity=""/>
    <stringProperty name="" minArity="" maxArity=""/>
    <enumProperty name="" minArity="" maxArity="">
      <item name=""/>
    </enumProperty>
    <edgeType name="" targetNodeType="" minArity="" maxArity=""/>
  </node-type>
  <nodeTypeExtension extends="">
    <integerProperty name="" minRange="" maxRange="" minArity="" maxArity=""/>
    <floatProperty name="" minRange="" maxRange="" minArity="" maxArity=""/>
    <booleanProperty name="" minArity="" maxArity=""/>
    <stringProperty name="" minArity="" maxArity=""/>
    <enumProperty name="" minArity="" maxArity="">
      <item name=""/>
    </enumProperty>
    <edgeType name="" targetNodeType="" min="" max=""/>
  </nodeTypeExtension>
</pagis>
```

### Schema API {#schema-api}

For the purposes of interacting with a graph within code, it is necessary to have
knowledge of the schema that applies to that graph. It is necessary that a schema
be available for introspection along with the [common apis](#common-apis) defined
in the following section.

A schema is represented as a collection of "nodeType" objects. Each NodeType object
provides all specified information for that node type, and seamlessly merges properties
and edges provided by traits as well as extensions.

Following is a general notion of the types and methods available in the Schema API:

#### Schema

* String getName()
* Map<String, NodeType> getNodeTypes()
* Schema getParentSchema()

#### NodeType

* String getName()
* boolean isSpan()
* boolean isSequence()
* boolean isContainer()
* String[] getContainerEdgeTypes()
* boolean isSpanContainer()
* String getSpanType()
* Map<String, PropertySpec> getPropertySpecs()
* Map<String, EdgeSpec> getEdgeSpecs()

#### PropertySpec

* ValueType getValueType()
* String getName()
* int getMinArity()
* int getMaxArity() // -1 represents unbounded unless a language has a better representation
* IntegerRestrictions getIntegerRestrictions()
* FloatRestrictions getFloatRestrictions()
* EnumRestrictions getEnumRestrictions()

#### IntegerRestrictions

* int getMinRange()
* int getMaxRange()

#### FloatRestrictions

* float getMinRange()
* float getMaxRange()

#### EnumRestrictions

* String[] getItems()

#### EdgeSpec

* String getName()
* String getTargetNodeType()
* int getMinArity()
* int getMaxArity()

Common APIs {#commons-apis}
---------------------------

The notion of defining Common APIs is to define a common way of working with
the data no matter the language, in much the same way that SAX and DOM do for
XML. One key difference between these APIs and the XML APIs is that writing
should be accounted for in all of these.

The final spec should describe these APIs in detail. For the current draft,
simplistic overviews are given.

### Event-Based Streaming {#event-based-streaming}

This API is intended as a computationally cheap way to walk through a document
and make decisions based on the content. The Stream is the lowest level API
for reading and writing pagi structures. This API can be thought of as a stream
of events. Each event type has a set of parameters. Some of these events define
a "context" -- and as such come in START/END pairs. Some of these events simply
provide values.

DOC_START
:    Indicates the start of a document.
:    Is only valid outside of any context.
:    Has the string-typed *id* parameter indicating the document id.
:    Indicates the beginning of a "DOC" context.

DOC_END
:    Indicates the end of a document.
:    Is only valid in the "DOC" context.
:    Indicates the ending of a "DOC" context.

NODE_START
:    Represents the beginning of information about a node.
:    Is only valid in the "DOC" context.
:    Has the string-typed *id* parameter indicating the node id.
:    Has the string-typed *nodeType* parameter indicating the node type.
:    Indicates the beginning of a "NODE" context.

NODE_END
:    Indicates that there is no more information about the current node.
:    Is only valid in the "NODE" context.
:    Indicates the ending of a "NODE" context.

EDGE
:    Indicates an edge on the current node.
:    Is only valid in the "NODE" context, prior to any FEATURE events.
:    Has the string-typed *edgeType* parameter indicating the type of the edge.
:    Has the string-typed *targetId* parameter indicating the id of the node that this edge
     points to.

PROPERTY_START
:    Indicates the beginning of information about a property.
:    Is only valid in the "NODE" context, prior to any EDGE events.
:    Has the string-typed *key* parameter indicating the property key.
:    Has the ValueType-typed *valueType* parameter indicating the type of the property values.
     Valid values are INTEGER, FLOAT, BOOLEAN, STRING, ENUM.
:    Indicates the beginning of a "PROPERTY" context.

PROPERTY_END
:    Indicates that there are no more values for the current property.
:    Is only valid in the "PROPERTY" context.
:    Indicates the ending of a "PROPERTY" context.

FEATURE_START
:    Indicates the beginning of information about a feature.
:    Is only valid in the "NODE" context.
:    Has the string-typed *key* parameter indicating the feature key.
:    Has the ValueType-typed *valueType* parameter indicating the type of the feature values.
     Valid values are INTEGER, FLOAT, BOOLEAN, STRING, ENUM.
:    Indicates the beginning of a "FEATURE" context.

FEATURE_END
:    Indicates that there are no more values for the current feature.
:    Is only valid in the "FEATURE" context.
:    Indicates the ending of a "FEATURE" context.

VALUE_INTEGER
:    Indicates an integer value on the current property or feature.
:    Is only valid in a "PROPERTY" or "FEATURE" context where *valueType* is "INTEGER".
:    Has the int-typed *value* parameter that has the value.

VALUE_FLOAT
:    Indicates a float value on the current property or feature.
:    Is only valid in a "PROPERTY" or "FEATURE" context where *valueType* is "FLOAT".
:    Has the float-typed *value* parameter that has the value.

VALUE_BOOLEAN
:    Indicates a boolean value on the current property or feature.
:    Is only valid in a "PROPERTY" or "FEATURE" context where *valueType* is "BOOLEAN".
:    Has the boolean-typed *value* parameter that has the value.

VALUE_STRING
:    Indicates a string value on the current property or feature.
:    Is only valid in a "PROPERTY" or "FEATURE" context where *valueType* is "STRING".
:    Has the string-typed *value* parameter that has the value.

VALUE_ENUM
:    Indicates a enum value on the current property or feature.
:    Is only valid in a "PROPERTY" or "FEATURE" context where *valueType* is "ENUM".
:    Has the string-typed *value* parameter that has the value.

There are two sides to interacting with a stream - a program may produce
events or consume events.

#### Event Generation

In order to generate events, a program will implement an EventGenerator. Typical
implementations are parsers or graph adapters. An EventGenerator is a stateful,
non-thread-safe construct that provides single method:

notify
:    Receives a listener, and notifies it of the next event in the stream.
:    Returns true if the stream contains more events, false if it is complete.

#### Event Listener -- Push Style

The first of two consumer styles, a program will implement the EventListener. This
basically serves as a stateful callback that is notified of every event coming
from the stream, in order. The EventListener has one callback method for each event
type. Each method is passed the parameters for that event. Dynamic languages may
allow any event callback to be optional, provided that the absence of those that
start contexts causes any events within that context to not be provided as well.

handleDocStart(id)

handleDocEnd()

handleNodeStart(nodeType, id)

handleNodeEnd()

handlePropertyStart(key, valueType)

handlePropertyEnd()

handleFeatureStart(key, valueType)

handleFeatureEnd()

handleEdge(edgeType, targetId)

handleValueInteger(value)

handleValueFloat(value)

handleValueBoolean(value)

handleValueString(value)

handleValueEnum(value)

#### Event Consumption -- Pull Style

The second of the two consumer styles, in this style the stream is represented
as an object and a program will consume the events by repeatedly asking the
stream for the next one.

nextEvent
:    Increments the counter in the stream to the next event.
:    Returns the event type of the next event.

getEventType
:    Returns the event type of the current event.

getId
:    Returns the ID of the document or node.
:    Valid in DOC_START and NODE_START.

getNodeType
:    Returns the type of the node.
:    Valid in NODE_START.

getKey
:    Returns the key of the property or feature.
:    Valid in PROPERTY_START or FEATURE_START.

getValueType
:    Returns the type of the property or feature.
:    Valid in PROPERTY_START or FEATURE_START.

getIntegerValue
:    Returns the integer value.
:    Valid in VALUE_INTEGER.

getFloatValue
:    Returns the float value.
:    Valid in VALUE_FLOAT.

getBooleanValue
:    Returns the boolean value.
:    Valid in VALUE_BOOLEAN.

getStringValue
:    Returns the string value.
:    Valid in VALUE_STRING.

getEnumValue
:    Returns the enum value.
:    Valid in VALUE_ENUM.

getEdgeType
:    Returns the type of the edge.
:    Valid in EDGE.

getEdgeTargetId
:    Returns the id of the target node of the edge.
:    Valid in EDGE.

### Graph Query {#graph-query}

This API is intended to provide an interface against which ad-hoc queries can be
made. The syntax should be similar to Gremlin's and no particular performance
guarantees are given.

### Streaming Graphical Querying (Hybrid) {#streaming-graphical-querying}

This API is actually expected to be the most useful in production analytics. The
notion here is to be able to provide a small set of concise queries (similar to
the ones in the Graph Query API) and allow the library to efficiently pull back
the requested information without incurring the overhead that would be required
to provide ad-hoc query capabilities. This would not be an optimal API for doing
"queries based on query results" in any depth, but the query language should be
expressive enough to allow the important information to be gleaned in a single
pass.

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

The actual xsd is referenced [in the appendix](#xml-format-xsd).

### Binary {#binary-format}

In order to facilitate efficient transfer and storage between components of
analytic applications, we define a binary format. Current thoughts are to
translate the xml format to one of the following:

* msgpack (`application/vnd.drs-pagif+msgpack`)
* protobuf (`application/vnd.drs-pagif+protobuf`)

The decision of what binary serialization to use is still an open ended question.
We fully expect other options than these two to be proposed and considered.

Corpus-Scoped Analytics {#corpus-scoped-analytics}
--------------------------------------------------

Future Scope {#future-scope}
----------------------------

 * Representing non-textual data (Audio or Visual)
 * Stackd.io integration
 * Visualization
 * Views in CSV and GraphML

Appendices {#appendices}
------------------------

###XML Format XSD {#xml-format-xsd}
```xml
<<<<pagif-xml.xsd>>>>
```

###PAGI Schema XSD {#pagi-schema-xsd}
```xml
<<<<pagis.xsd>>>>
```
