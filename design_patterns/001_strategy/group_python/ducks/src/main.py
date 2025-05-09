import sys

from pet_duck import PetDuck
from rubber_duck import RubberDuck
from wild_duck import WildDuck
from quack import Quack

def main():
    exit_code = 0
    try:
        print('\n')
        pet_duck: PetDuck = PetDuck()
        pet_duck.setQuackBehavior(Quack())
        pet_duck.quack()
        pet_duck.swim()
        pet_duck.display()
        print('\n')

        rubber_duck: RubberDuck = RubberDuck()
        rubber_duck.quack()
        rubber_duck.swim()
        rubber_duck.display()
        print('\n')

        wild_duck: WildDuck = WildDuck()
        wild_duck.quack()
        wild_duck.swim()
        wild_duck.display()
        print('\n')

    except Exception as exception:
        print(f"ERROR: executing chapter 1 exercise")
        print(f"EXCEPTION: {exception}")
        exit_code = 1
    finally:
        sys.exit(exit_code)


if __name__ == '__main__':
    main()
