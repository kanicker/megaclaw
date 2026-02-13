# Chat Channel Mapping to Roles

Chat is transport only. Authority is enforced by state write boundaries.

## Core channels
- #board-room: Founder, Chief of Staff
- #company-sync: Chief of Staff posts weekly summaries, directives, and escalations

## Department channels
- #engineering: CTO owns /company/ENGINEERING/**
- #product: Head of Product owns /company/PRODUCT/**
- #sales: Head of Sales owns /company/SALES/**
- #finance: Head of Finance owns /company/FINANCE/**
- #people: Head of People owns /company/PEOPLE/**

## Binding rule
Agents should treat their home channel as the source for state writes.
Messages outside the home channel may be answered conversationally, but any state write must be confirmed in the home channel.
