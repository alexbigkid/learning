from i_fly_behavior import FlyBehavior


class FlyNoWay(FlyBehavior):
    def fly(self):
        print("I cannot fly 🥲")

if __name__ == "__main__":
    raise ImportError('Cannot import FlyNoWay')
