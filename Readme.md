Schema Police
=============

The world is littered with inhumane and criminally-poor web service APIs.
This is your crime-fighting toolkit! This is a project with a long-term roadmap:


1. Develop tools to document web service APIs (SOAP/REST/etc) in a human-friendly manner
2. Establish a quantified set of "good design" qualities for web service APIs
3. Build tools to measure these qualities for any given web service, with concrete recommendations where quality is poor
4. ???
5. Profit!


These are early days. This repository will first be used to gather existing work done in this space.

## Short-term TODOs

1. Some common APIs (like Sabre, travel booking) make use of large number of repeated anonymous inner types, causing great pain to API developers. Develop a tool to automatically detect anonymous types with the same structure, and refactor those schemas to re-use the extracted, named types.
