from abc import ABCMeta, abstractmethod


class FlyBehavior(metaclass=ABCMeta):
    @classmethod
    def __subclasshook__(cls, subclass):
        return (
            hasattr(subclass, 'fly') and
            callable(subclass.fly) or
            NotImplemented
        )

    @abstractmethod
    def fly(self) -> None:
        """fly abstract method"""
        raise NotImplementedError


class FlyWithWings(FlyBehavior):
    """Fly with wings behavior class"""
    def fly(self) -> None:
        print('fly, fly away')


class FlyNoWay(FlyBehavior):
    """Fly no way behavior class"""
    def fly(self) -> None:
        print('cannot fly, 🥲')


class FlyRocketPowered(FlyBehavior):
    """Fly rocket powered behavior class"""
    def fly(self) -> None:
        print('I am flying with a rocket!')


if __name__ == '__main__':
    raise ImportError('This module should not be executed directly. Only for imports')
