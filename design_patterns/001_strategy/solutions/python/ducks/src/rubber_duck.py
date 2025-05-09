"""Rubber duck concrete class"""
from duck import Duck
from fly_behavior import FlyNoWay
from quack_behavior import MuteQuack

class RubberDuck(Duck):
    """Rubber duck class"""

    def __init__(self):
        self.duck_fly_behavior = FlyNoWay()
        self.duck_quack_behavior = MuteQuack()
        super().__init__()

    def display(self) -> None:
        print('I am a rubber duck!')
