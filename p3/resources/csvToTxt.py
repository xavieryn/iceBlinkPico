import pandas as pd
import numpy as np

filepath = "/Applications/oss-cad-suite/iceBlinkPico/p3/resources/"
filename = input("csv pls: ")
df = pd.read_csv(filepath+filename+'.csv', header=None)

textfile = filename + ".txt"

dfarray = df.to_numpy()

print(dfarray)
print(len(dfarray), ' + ', len(dfarray[0]))
with open(filepath+textfile, 'w') as file:
    for rows in range (len(dfarray)):
        for col in range(len(dfarray[0])):
            string = dfarray[rows][col]
            f = string.replace("'", "").strip() # gets rid of space and gets rid of the ' because it was running into issues of whether it was a string or an int
            file.write(f+'\n')

