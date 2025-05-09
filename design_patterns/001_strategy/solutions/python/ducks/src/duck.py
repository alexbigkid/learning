from abc import ABCMeta, abstractmethod
from fly_behavior import FlyBehavior, FlyNoWay, FlyWithWings
from quack_behavior import MuteQuack, Quack, QuackBehavior

class Duck(metaclass=ABCMeta):
    duck_fly_behavior: FlyBehavior = None
    duck_quack_behavior: QuackBehavior = None

    @classmethod
    def __subclasshook__(cls, subclass):
        return (
            hasattr(subclass, 'duck_fly_behavior') and
            hasattr(subclass, 'duck_quack_behavior') and
            hasattr(subclass, 'display') and
            callable(subclass.display) or
            hasattr(subclass, 'swim') and
            callable(subclass.swim) or
            NotImplemented
        )


    def __init__(self):
        super().__init__()


    @abstractmethod
    def display(self) -> None:
        raise NotImplementedError


    def swim(self) -> None:
        print('All ducks float, even decoys!')


    def perform_fly(self) -> None:
        self.duck_fly_behavior.fly()


    def perform_quack(self) -> None:
        self.duck_quack_behavior.quack()


    def set_fly_behavior(self, fly_behavior:FlyBehavior) -> None:
        self.duck_fly_behavior = fly_behavior


    def set_quack_behavior(self, quack_behavior:QuackBehavior) -> None:
        self.duck_quack_behavior = quack_behavior






if __name__ == '__main__':
    raise ImportError('This module should not be executed directly. Only for imports')
