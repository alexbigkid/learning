"""Wild duck concrete implementation"""
from duck import Duck
from fly_behavior import FlyWithWings
from quack_behavior import Quack

class WildDuck(Duck):
    """Wild duck class"""
    def __init__(self):
        self.duck_fly_behavior = FlyWithWings()
        self.duck_quack_behavior = Quack()
        super().__init__()

    def display(self) -> None:
        print('I am a wild duck!')

if __name__ == '__main__':
    raise ImportError('This module should not be executed directly. Only for imports')
