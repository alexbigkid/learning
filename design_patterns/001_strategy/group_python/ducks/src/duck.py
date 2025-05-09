"""Duck implementation"""
from abc import abstractmethod
from i_quack_behavior import QuackBehavior
from i_fly_behavior import FlyBehavior

class Duck():
    _quack_behavior: QuackBehavior
    _fly_behavior: FlyBehavior

    """Duck class"""

    def quack(self) -> None:
        "quack function"
        if self._quack_behavior is None:
            raise RuntimeError('Quack behavior is not set!')
        self._quack_behavior.quack()

    def fly(self) -> None:
        "fly function"
        if self._fly_behavior is None:
            raise RuntimeError('Fly behavior is not set!')
        self._fly_behavior.fly()

    def swim(self) -> None:
        "swim function"
        print('I can swim')

    @abstractmethod
    def display(self) -> None:
        """display function"""
        raise NotImplementedError

    def setQuackBehavior(self, behavior: QuackBehavior) -> None:
        """set quack behavior"""
        self._quack_behavior = behavior

    def setFlyBehavior(self, behavior: FlyBehavior) -> None:
        """set fly behavior"""
        self._fly_behavior = behavior

if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
