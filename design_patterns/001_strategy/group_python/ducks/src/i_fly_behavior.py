"""Interface for fly behavior"""
from abc import ABCMeta, abstractmethod

class FlyBehavior(metaclass=ABCMeta):
    """Fly behavior interface"""
    @abstractmethod
    def fly(self) -> None:
        """fly abstract method"""
        raise NotImplementedError

if __name__ == '__main__':
    raise ImportError('This module should not be executed directly. Only for imports')
