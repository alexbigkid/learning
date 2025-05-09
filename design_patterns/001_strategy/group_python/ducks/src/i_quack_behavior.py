"""Interface for Quack behavior"""
from abc import ABCMeta, abstractmethod

class QuackBehavior(metaclass=ABCMeta):
    """Quack behavior interface class"""
    @abstractmethod
    def quack(self) -> None:
        """quack abstract method"""
        raise NotImplementedError

if __name__ == '__main__':
    raise ImportError('This module should not be executed directly. Only for imports')
