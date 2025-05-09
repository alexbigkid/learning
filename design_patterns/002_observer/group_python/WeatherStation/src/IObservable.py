from abc import ABCMeta, abstractmethod

from IObserver import IObserver

class IObservable(metaclass=ABCMeta):

    @classmethod
    def __subclasshook__(cls, subclass):
        return (
            hasattr(subclass, 'registerObserver') and
            callable(subclass.registerObserver) and
            hasattr(subclass, 'removeObserver') and
            callable(subclass.removeObserver) and
            hasattr(subclass, 'notifyObservers') and
            callable(subclass.notifyObservers) or
            NotImplemented
        )

    @abstractmethod
    def substribe(self, observer:IObserver) -> None:
        raise NotImplementedError
    
    @abstractmethod
    def unsubscribe(self, observer:IObserver) -> None:
        raise NotImplementedError

    @abstractmethod
    def notify(self, data:dict) -> None:
        raise NotImplementedError


if __name__ == '__main__':
    raise Exception(f'This module should not be executed directly. Only for imports')
