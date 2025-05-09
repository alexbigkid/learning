# [Strategy Pattern](https://refactoring.guru/design-patterns/strategy) <!-- omit in toc -->
Lets you define a family of algorithms, put each of them into a separate class, and make their objects interchangeable.

# Table of Contents <!-- omit in toc -->
[TOC]


## References
1. [Strategy Pattern - Refactoring Guru](https://refactoring.guru/design-patterns/strategy)

### Observer Pattern class diagram

```mermaid
classDiagram
    class Duck {
        <<abstract>>
        - quack_behavior: QuackBahavior
        - fly_behavior: FlyBahavior
        + swim()
        + performFly()
        + performQuack()
        + setFlyBehavior(behavior: FlyBehavior)
        + setQuackBehavior(behavior: QuackBehavior)
        + display()
    }

    class PetDuck {
        + display()
    }

    class RubberDuck {
        + display()
    }

    class WildDuck {
        + display()
    }

    class FlyBehavior {
        <<interface>>
        + fly()
    }

    class FlyWithWings {
        + fly()
    }

    class FlyNoWay {
        + fly()
    }

    class QuackBehavior {
        <<interface>>
        + quack()
    }

    class Quack {
        + quack()
    }

    class Squeak {
        + quack()
    }

    class MuteQuack {
        + quack()
    }

    Duck <|-- PetDuck
    Duck <|-- RubberDuck
    Duck <|-- WildDuck
    FlyBehavior "1" --o "1" Duck
    QuackBehavior "1" <--o "1" Duck
    FlyBehavior <|-- FlyWithWings
    FlyBehavior <|-- FlyNoWay
    QuackBehavior <|-- Quack
    QuackBehavior <|-- Squeak
    QuackBehavior <|-- MuteQuack
```

### [Excercises](./ducks.md)
