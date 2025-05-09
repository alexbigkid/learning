# [Observer Pattern](https://refactoring.guru/design-patterns/observer) <!-- omit in toc -->
Lets you define a subscription mechanism to notify multiple objects about any events that happen to the object they’re observing.

# Table of Contents <!-- omit in toc -->
[TOC]

## References
1. [Observer Pattern - Refactoring Guru](https://refactoring.guru/design-patterns/observer)
2. [ReactiveX - libs for Reactive Programming](https://reactivex.io/)
3. [RxPy - Observable lib for Python](https://rxpy.readthedocs.io/en/latest/)
4. [RxJs - Observable lib for Js/Ts](https://www.learnrxjs.io/)


## Magazine or newspaper subscription
1. A magazine publisher goes into business and begins publishing magazine.
2. You subscribe to a particular publisher, and every time there’s a new edition it gets delivered to you. As long as you remain a subscriber, you get new magazines.
3. You unsubscribe when you don’t want magazines anymore, and they stop being delivered.
4. While the publisher remains in business, people, hotels, airlines, and other businesses constantly subscribe and unsubscribe.

## Observer Pattern definition
Publishers + Subscribers = Observer Pattern
In Observer Pattern Design, publishers are called subjects(or Observables) and subscribers -> Observers

Observer Pattern defines a one to many dependency between objects so that when one object changes state all of its dependents are notified and updated automatically.

## Observer Pattern diagram

```mermaid
graph LR


    observable((observable)) -.->|auto-update| observer_1(observable 1)
    observable -.->|auto-update| observer_2(observable 2)
    observable -.->|auto-update| observer_3(observable 3)
    observable -.->|auto-update| observer_4(observable 4)


    classDef blu fill:#3498db,stroke:#333,stroke-width:2px
    classDef grn fill:#9f6,stroke:#333,stroke-width:2px;
    classDef llprl fill:#D8BFD8,stroke:#333,stroke-width:2px,text-align:left
    classDef lprl fill:#D8BFD8,stroke:#333,stroke-width:2px
    classDef org fill:#f96,stroke:#333,stroke-width:2px;
    classDef prl fill:#9b59b6,stroke:#333,stroke-width:2px
    classDef red fill:#e74c3c,stroke:#333,stroke-width:2px
    classDef ylw fill:#f6d743,stroke:#333,stroke-width:2px
    class weather_station lprl
    class observer_1 blu
    class observer_2 blu
    class observer_3 blu
    class observer_4 blu
    class observable org
```

## Observer Pattern class diagram

```mermaid
classDiagram
    class Observable {
        <<interface>>
        observer_list: Observer[]
        + add_observer(observer: Observer)
        + remove_observer(observer: Observer)
        + notifyObservers()
    }

    class ConcreteObservable {
        - state: any
        + getState()
        + setState(state: any)
    }

    class Observer {
        <<interface>>
        + update()
    }

    class ConcreteObserver {
        - subject: Observable
        + update()
    }

    Observable <|-- ConcreteObservable
    Observer <|-- ConcreteObserver
    Observer "*" <-- "1" Observable
    ConcreteObserver --> ConcreteObservable
```

## Loose coupling of Observer Pattern
- The only thing the Observable knows about observer that it implements an observer interface
- observers can be added any time
- observers can be removed any time
- no need to modify Observable to add new type of observers
- Observables and Observers can be reused independently of each other
- changes to the Observable or an Observer will not effect each other as long as we comply to the interfaces defined

## [Excercises](./weather_monitor.md)
