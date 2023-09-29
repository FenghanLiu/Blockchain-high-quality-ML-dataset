import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
# 加载数据集
data = pd.read_csv('Dry Bean Dataset.csv')
X = data.iloc[:, :-1]
y = data['Class']
# 拆分数据集
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
# 训练随机森林
rf = RandomForestClassifier()
rf.fit(X_train, y_train)
# 获取特征重要性
importances = rf.feature_importances_
features = data.columns[:-1]
# 打印特征重要性
for name, value in zip(features, importances):
    print(name, value)

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
# 加载数据集
data = pd.read_csv('Dry Bean Dataset.csv')
X = data.iloc[:, :-1]
y = data['Class']
# 拆分数据集
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
# 定义SVM
svm = SVC(kernel='linear')
# 训练SVM
svm.fit(X_train, y_train)
# 获取权重系数
coefs = svm.coef_.flatten()
# 特征名
features = data.columns[:-1]
# 打印重要性
for feature, coef in zip(features, coefs):
    print(feature, coef)