def raindrops(number):
    rain_str = ''

    if number % 3 == 0:
        rain_str = 'Pling'

    if number % 5 == 0:
        rain_str += 'Plang'

    if number % 7 == 0:
        rain_str += 'Plong'

    return rain_str if rain_str != '' else str(number);