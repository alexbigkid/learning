from i_fly_behavior import FlyBehavior

class FlyWithWings(FlyBehavior):
    def fly(self):
        print("I'm flying!")

if __name__ == "__main__":
    raise ImportError('Cannot import FlyWithWings')
