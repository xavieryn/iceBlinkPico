import pandas as pd
import numpy as np

filepath = "p3/spiral/"
filename = input("csv pls: ")
df = pd.read_csv(filepath+filename+'.csv')
print(df)

textfile = filename + ".txt"

dfarray = df.to_numpy()

print(dfarray)

with open(filepath+textfile, 'w') as file:
    for rows in range (len(dfarray)):
        for col in range(len(dfarray[0])):
            string = dfarray[rows][col]
            f = string.replace("'", "").strip()
            print(f)
            file.write(f+'\n')

