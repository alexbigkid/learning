"""Display Interface"""
from abc import ABCMeta, abstractmethod

class IDisplay(metaclass=ABCMeta):
    """Interface Display"""

    @classmethod
    def __subclasshook__(cls, subclass):
        """enforcing display function"""
        return (
            hasattr(subclass, 'display') and
            callable(subclass.display) or
            NotImplemented
        )

    @abstractmethod
    def display(self) -> None:
        """abstract display"""
        raise NotImplementedError


if __name__ == '__main__':
    raise RuntimeError('This module should not be executed directly. Only for imports')
