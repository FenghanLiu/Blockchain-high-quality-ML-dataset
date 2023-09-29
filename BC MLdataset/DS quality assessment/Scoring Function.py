import pandas as pd
import numpy as np
from sklearn.feature_selection import SelectKBest, f_classif
# 读取鸢尾花数据集
iris = pd.read_csv("Dry_Bean_Dataset.csv")
# 将类别标签转换为数值
iris["Class"] = iris["Class"].map({"SEKER": 0, "BARBUNYA": 1, "BOMBAY": 2,"CALI": 3, "HOROZ": 4, "SIRA": 5,"DERMASON":6})
# 定义特征和目标变量
X = iris.drop("Class", axis=1)
y = iris["Class"]
# 使用SelectKBest方法选择最佳的k个特征，基于f_classif评分函数
kbest = SelectKBest(score_func=f_classif, k=2)
kbest.fit(X, y)
# 打印每个特征的评分和p值
scores = kbest.scores_
pvalues = kbest.pvalues_
for i in range(len(X.columns)):
    print(f"{X.columns[i]}: score={scores[i]:.3f}, pvalue={pvalues[i]:.3f}")
# 打印被选择的特征
mask = kbest.get_support()
selected_features = X.columns[mask]
print(f"Selected features: {selected_features}")