## Helper to generate array integers for 

## Structure of array integerrs holding the level generation data
## [0:obstacle(1), 1:displacement(8), 2: segment(19), 3: segment(19), 4: segment(19), 5: segment(19)]
## We mix and match randomly to achieve a good level spread.
import random

numberOfLevels = 100
numberOfParametersPerLevel = 6
parameterBounds = [1, 7, 18, 18, 18, 18]

levelParameters = []
for i in range(numberOfLevels):
    levelParameters.append([0]*numberOfParametersPerLevel)

for i in range(numberOfLevels):
    for j in range(numberOfParametersPerLevel):
        levelParameters[i][j] = random.randint(0, parameterBounds[j])

for level in levelParameters:
    print(str(level) + ',')
