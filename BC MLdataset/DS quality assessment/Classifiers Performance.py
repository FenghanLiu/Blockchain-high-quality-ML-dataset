import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
from sklearn.tree import DecisionTreeClassifier
from sklearn.utils import shuffle
import numpy as np
# 读取数据
data = pd.read_csv('Dry Bean Dataset.csv')
# 按Class分组,交换部分标签
groups = {c: data[data['Class'] == c] for c in data['Class'].unique()}
for c, df in groups.items():
    indices = df.sample(frac=0.10).index
    df.loc[indices, 'Class'] = np.random.choice(list(set(data['Class']) - set([c])))
# 合并数据,打乱顺序
new_data = pd.concat(groups.values()).reset_index(drop=True)
new_data = shuffle(new_data)
# 分离特征和标签
X = new_data.iloc[:,:-1]
y = new_data.iloc[:,-1]
# 划分训练和测试集
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)
# 标准化
scaler = StandardScaler()
scaler.fit(X_train)
X_train = scaler.transform(X_train)
X_test = scaler.transform(X_test)
# KNN建模
# knn = KNeighborsClassifier(n_neighbors=5)
# knn.fit(X_train, y_train)
#SVC建模
# svm = SVC()
# svm.fit(X_train, y_train)
# 决策树代替SVM
# dt = DecisionTreeClassifier()
# dt.fit(X_train, y_train)
# 使用随机森林分类器
rf = RandomForestClassifier()
rf.fit(X_train, y_train)
# 评估
# y_pred = knn.predict(X_test)
# y_pred = svm.predict(X_test)
# y_pred = dt.predict(X_test)
y_pred = rf.predict(X_test)
print(classification_report(y_test, y_pred))