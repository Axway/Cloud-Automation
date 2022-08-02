# Contributing Guidelines

This repository is maintained by the community. It means that anybody interested in this project can contribute via a Pull request.
This document describes how to get a valid contribution.
Any contribution must be accepted by the maintainers team.

## Prerequisites

First of all, a Feature request or a Bug report must be created.
You will need the reference for your reference request.

## How to contribute 

- Fork this repository, develop, and test your changes.
- create some simple commits that describe clearly the purpose of the modification.
- Submit a pull request by adding the following information
    - The reference of the bug report/Feature request
    - A description of the platform where has been tested the modification
    - A description of the test and expected result

A minimal set of files must be updated :
- The value.yaml file must have a description of the modification if a value is impacted.
- The CHANGELOG.md file in the appropriate project (ie. APIM/Helmchart/CHANGELOG.md) must contain the modification in the "Not released" section. (Please create a new one if it doesn't exist)
- The Chart.yaml file must be changed except if changes impact documentation only.

Some testing is done during a pull request. Be sure that no issue is reported.

***Note***: For better visibility, a pull request can be done for on project only.


Thanks for your next contribution.