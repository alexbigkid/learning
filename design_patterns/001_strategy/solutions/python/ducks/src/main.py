import sys

from rubber_duck import RubberDuck
from wild_duck import WildDuck
from rocket_duck import RocketDuck
from fly_behavior import FlyRocketPowered
# from fly_behavior import FlyBehavior, FlyRocketPowered


def main():
    exit_code = 0
    try:
        wild_duck: WildDuck = WildDuck()
        wild_duck.display()
        wild_duck.swim()
        wild_duck.perform_quack()
        wild_duck.perform_fly()

        print('\n')
        rocket_duck: RocketDuck = RocketDuck()
        rocket_duck.display()
        rocket_duck.swim()
        rocket_duck.perform_quack()
        rocket_duck.perform_fly()

        print('\n')
        rubber_duck: RubberDuck = RubberDuck()
        rubber_duck.display()
        rubber_duck.swim()
        rubber_duck.perform_quack()
        rubber_duck.perform_fly()
        rubber_duck.set_fly_behavior(FlyRocketPowered())
        print('Upgrading flight behavior')
        rubber_duck.perform_fly()

    except Exception as exception:
        print("ERROR: executing chapter 1 exercise")
        print(f"EXCEPTION: {exception}")
        exit_code = 1
    finally:
        sys.exit(exit_code)


if __name__ == '__main__':
    main()
