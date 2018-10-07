## Helper to generate array integers for 

## Structure of array integerrs holding the level generation data
## [0:obstacle(1), 1:displacement(8), 2: segment(20), 3: segment(20), 4: segment(20), 5: segment(20)]
## We mix and match randomly to achieve a good level spread.
import random

numberOfLevels = 100
numberOfParametersPerLevel = 6
parameterBounds = [1, 7, 19, 19, 19, 19]

levelParameters = []
for i in range(numberOfLevels):
    levelParameters.append([0]*numberOfParametersPerLevel)

for i in range(numberOfLevels):
    for j in range(numberOfParametersPerLevel):
        levelParameters[i][j] = random.randint(0, parameterBounds[j])

for level in levelParameters:
    print(str(level) + ',')