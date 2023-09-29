import pandas as pd
import numpy as np

df = pd.read_csv('Iris.csv')
target = df['Species'].values

random_data = np.zeros((10000, 4))
random_data[:,0] = np.round(np.random.rand(10000) * (7-4) + 4, 1) # SepalLengthCm 4-7
random_data[:,1] = np.round(np.random.rand(10000) * (4-2) + 2, 1) # SepalWidthCm 2-4
random_data[:,2] = np.round(np.random.rand(10000) * (7-1) + 1, 1) # PetalLengthCm 1-7
random_data[:,3] = np.round(np.random.rand(10000) * (3-0) + 0, 1) # PetalWidthCm 0-3

cols = ['SepalLengthCm', 'SepalWidthCm', 'PetalLengthCm', 'PetalWidthCm']

new_df = pd.DataFrame(random_data, columns=cols)

target_expanded = pd.Series(target).sample(10000, replace=True)

new_df['Species'] = target_expanded

new_df.to_csv('larger_iris_random.csv', index=False)

print('数据集已生成!')