# Design Patterns Description <!-- omit in toc -->
<b>[Design patters](https://refactoring.guru/design-patterns)</b> are recurring solutions to common problems encountered in software design. They represent best practices and provide a structured approach for designing software systems. Design patterns capture expertise and collective knowledge accumulated over time by experienced software engineers, architects, and designers.

These patterns offer reusable solutions to common problems and promote modularity, flexibility, and maintainability in software development. They are not specific implementations or pieces of code but rather templates for solving problems in a particular context.

# Table of Contents <!-- omit in toc -->
- [OO Overview](#oo-overview)
  - [OO Basics](#oo-basics)
  - [OO Principles](#oo-principles)
  - [SOLID Principles](#solid-principles)
  - [1. Chapter 1 - Strategy Pattern](#1-chapter-1---strategy-pattern)
  - [2. Chapter 2 - Observer Pattern](#2-chapter-2---observer-pattern)

# Design Pattern Exercises <!-- omit in toc -->
This repo is used for design Pattern exercises of the book Head First Design Patterns.
See: https://www.amazon.com/Head-First-Design-Patterns-Brain-Friendly/dp/0596007124
However instead of Java, Python and TypeScript is used for the exercises.

# OO Overview

## OO Basics
- Abstraction
- Encapsulation
- Polymorthism
- Inheritance

## OO Principles
- Encapsulate what varies
- Favor composition over inheritance
- Program to interfaces, not implementations

## SOLID Principles
|          | name                          | description                                                                                                                                               |
| :------- | :---------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <b>S</b> | <b>Single Responsibility:</b> | A class should have one, and only one, reason to change                                                                                                   |
| <b>O</b> | <b>Open/Close:</b>            | Open for extention, Close for modifications                                                                                                               |
| <b>L</b> | <b>Liskov Substitution:</b>   | objects of a superclass shall be replaceable with objects of its subclasses without breaking the application                                              |
| <b>I</b> | <b>Interface Segregation:</b> | Clients should not be forced to depend upon interfaces that they do not use                                                                               |
| <b>D</b> | <b>Dependency Inversion:</b>  | High-level modules, which provide complex logic, should be easily reusable and unaffected by changes in low-level modules, which provide utility features |


## 1. Chapter 1 - [Strategy Pattern](https://refactoring.guru/design-patterns/strategy)
<b>The Strategy Pattern</b> defines a family of algorithms, encapsulates each one, and makes them interchangeable. Strategy lets the algorithm vary independently from clients that use it.
- [strategy pattern description and diagrams](001_strategy/docs/strategy_pattern.md)
- [strategy pattern exercise](001_strategy/docs/ducks.md)

## 2. Chapter 2 - [Observer Pattern](https://refactoring.guru/design-patterns/observer)
<b>The Observer Pattern</b> defines a one to many relationship between a set of objects. When the state of one object changes, all of its dependents are notified.
- [observer pattern description and diagrams](002_observer/docs/observer_pattern.md)
- [observer pattern exercise](002_observer/docs/weather_monitor.md)

:checkered_flag:
