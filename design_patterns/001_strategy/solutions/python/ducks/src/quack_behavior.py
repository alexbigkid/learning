from abc import ABCMeta, abstractmethod


class QuackBehavior(metaclass=ABCMeta):
    @classmethod
    def __subclasshook__(cls, subclass):
        return (
            hasattr(subclass, 'quack') and
            callable(subclass.quack) or
            NotImplemented
        )

    @abstractmethod
    def quack(self) -> None:
        raise NotImplementedError


class Quack(QuackBehavior):
    def quack(self) -> None:
        print('quack, quack, quack')


class Squeak(QuackBehavior):
    def quack(self) -> None:
        print('squeak, squeak')


class MuteQuack(QuackBehavior):
    def quack(self) -> None:
        print('<< Silence >>')


if __name__ == '__main__':
    raise ImportError('This module should not be executed directly. Only for imports')
