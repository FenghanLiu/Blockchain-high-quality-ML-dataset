import pandas as pd
from scipy.stats import spearmanr
from sklearn.utils import shuffle
# 读取自建数据集
iris = pd.read_csv('Iris.csv')
iris = iris.drop('Id',axis= 1)
# 读取Dry Bean Dataset
# iris = pd.read_csv("Dry Bean Dataset.csv")
# iris["Class"] = iris["Class"].map(
#     {"SEKER": 0, "BARBUNYA": 1, "BOMBAY": 2, "CALI": 3, "HOROZ": 4, "SIRA": 5, "DERMASON": 6})
# 根据target列 Divide 数据为3组
setosa = iris[iris['Species']=='Iris-setosa']
versicolor = iris[iris['Species']=='Iris-versicolor']
virginica = iris[iris['Species']=='Iris-virginica']
# 每组提取（1%,5%,10%,25%,50%） 的 index
setosa_index = setosa.sample(frac=0.5).index
versicolor_index = versicolor.sample(frac=0.5).index
virginica_index = virginica.sample(frac=0.5).index
# 交换标签
setosa.loc[setosa_index, 'Species'] = 'Iris-versicolor'
versicolor.loc[versicolor_index, 'Species'] = 'Iris-virginica'
virginica.loc[virginica_index, 'Species'] = 'Iris-setosa'
# 重新合并
new_iris = pd.concat([setosa, versicolor, virginica]).reset_index(drop=True)
# 打乱顺序
new_iris = shuffle(new_iris)
# 特征列
X = new_iris.iloc[:,0:-1]
# 目标值
y = new_iris['Species']
spearman_dict = {}
for col in X.columns:
    spearman,_ = spearmanr(X[col], y)
    spearman_dict[col] = spearman
# 输出结果
print(spearman_dict)
# 选择Dry Bean Dataset前6个特征
# selected_indices = [corrs_sorted[i][0] for i in range(6)]
# selected_features = X.columns[selected_indices]
# print(f"\nSelected top 6 features: {selected_features}")