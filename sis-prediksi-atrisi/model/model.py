import pandas as pd
from math import sqrt

class KnnClassifier():
    """Kelas penerapan metode k-Nearest Neighbor untuk
    kelasifikasi data numerik.

    fungsi:
    - get_euclidean_dist(a, b)
    - get_minkowski_dist(a, b, p=1)
    - get_prediction(X_train, X_test, y_train, y_test, k)

    """
    def get_euclidean_dist(self, a, b):
        """Fungsi untuk memperoleh jarak Euclidean
        dari dua buah data."""
        sum_of_square = 0
        for pa, pb in zip(a, b):
            dist_square = (pa-pb)**2
            sum_of_square += dist_square

        return sqrt(sum_of_square)
    
    def get_minkowski_dist(self, a, b, p=1):
        """Fungsi untuk memperoleh jarak Minskowski dari dua 
        buah data."""
        dim = len(a)
        distance = 0

        for d in range(dim):
            distance += abs(a[d] - b[d])**p

        return distance**(1/p)

    def get_knn(self, X_train, X_test, y_train, k):
        """Fungsi pemrolehan estimasi k jarak data terdekat."""
        # Counter to untuk label voting
        from collections import Counter
         
        y_predict = [] # Penampung hasil prediksi

        for test_point in X_test:
            # Prediksi label target dari data X_test ke-i
            distances = []

            for train_point in X_train:
                dist = self.get_euclidean_dist\
                    (test_point, train_point)
                distances.append(dist)
            
            # Simpan jarak X_test ke-i terhadap setiap data pada 
            # X_train ke dalam objek dataframe
            distances_df = pd.DataFrame(data=distances,
                                        columns=['dist'],
                                        index=y_train.index)

            # Pengurutan jarak untuk k buah data terdekat
            nn_df = distances_df.sort_values(by=['dist'], axis=0)[:k]

            # Intansiasi counter untuk mendeteksi label k buah 
            # data terdekat
            counter = Counter(y_train[nn_df.index])

            # Ambil label paling dominan
            prediction = counter.most_common()[0][0]

            # Masukan hasil prediksi
            y_predict.append(prediction)

        return y_predict

class Classifier():
    def get_classification(self, train_df, test_df, test_id, k):
        # Atribut bertipe nominal
        train_object_df = train_df.select_dtypes(include=['object']).copy()
        train_object_df.drop('attrition', axis=1, inplace=True)
        test_object_df = test_df.select_dtypes(include=['object']).copy()
        test_object_df.drop('attrition', axis=1, inplace=True)

        # Encoding data kategorik
        categorical_names = train_object_df.columns
        for i in range(len(categorical_names)):
            name = categorical_names[i]
            train_object_df[name] = train_object_df[name].astype('category')
            train_object_df[name] = train_object_df[name].cat.codes
            test_object_df[name] = test_object_df[name].astype('category')
            test_object_df[name] = test_object_df[name].cat.codes
        
        # Ganti data nominal di dataframe dengan hasil encoding
        for i in range(len(categorical_names)):
            name = categorical_names[i]
            train_df[name] = train_object_df[name]
            test_df[name] = test_object_df[name]

        train_df["attrition"] = train_df["attrition"].astype('category')
        #test_df["Attrition"] = test_df["Attrition"].astype('category')

        # Pemisahan data
        # Data latih
        X_train = train_df.drop('attrition', axis=1)    # matriks data latih
        y_train = train_df.attrition                    # label
        # Data uji (tidak memiliki label)
        X_test = test_df.drop('attrition', axis=1)      # matriks data uji

        # Scaling
        from sklearn.preprocessing import StandardScaler
        scaler = StandardScaler()
        X_train = scaler.fit_transform(X_train)
        X_test = scaler.transform(X_test)

        # Testing
        knn = KnnClassifier()
        predict_labels = knn.get_knn(X_train, X_test, y_train, k)
        
        predictions = {}
        for i in range(len(test_df)):
            predictions[test_id[i]] = predict_labels[i]

        return predictions


if __name__ == '__main__':
    """
    # Make sure where CWD
    import os
    cwd = os.getcwd()
    print(cwd)
    """
    from sklearn.model_selection import train_test_split
    from sklearn.preprocessing import StandardScaler
    from sklearn.metrics import accuracy_score
    from sklearn.metrics import classification_report
    from sklearn.metrics import confusion_matrix

    # Iris dataset
    dataset_path = "data/iris.csv"
    # IBM HR analytics dataset
    #dataset_path = "sppk/data/ibm-attrition-dataset.csv"
    sample_df = pd.read_csv(dataset_path)
    print(sample_df.info())

    X = sample_df.drop('Class', axis=1)
    y = sample_df.Class
    #X = X.iloc[:200,:]
    #y = y.iloc[:200]

    print(f"\nX:\n{X}")
    print(f"\ny:\n{y}")
    
    # ----------- Sperasi data -------------------------------
    X_train, X_test, y_train, y_test = train_test_split(X, y,
                                            test_size=0.25,
                                            random_state=1)
    #print(f"\n> X_train:\n{X_train.head()}")
    #print(f"\n> X_test:\n{X_test.head()}")
    print(f"\n> Number of X_train: {len(X_train)}")
    print(f"> Number of X_test: {len(X_test)}")

    # ----------- Penskalaan --------------------------------
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)
    #print(f"\n> X_train scaled:\n{X_train}")
    #print(f"\n> X_test scaled:\n{X_test}")

    # ----------- Pengujian ---------------------------------
    knn = KnnClassifier()
    y_predict = knn.get_prediction(X_train, X_test,
                                    y_train, y_test, 5)
    print(f"\n> Prediction result:\n {y_predict}")
    print(f"\n> Accuracy: {accuracy_score(y_test, y_predict)}")
    print("\n> Confusion matrix:\n", confusion_matrix(y_test, y_predict))
    print("\n> Report:\n", classification_report(y_test, y_predict))
    
    """
    # Test the funtion
    dist = knn.get_euclidean_dist(a=X.iloc[0], b=X.iloc[1])
    dist2 = knn.get_minkowski_dist(a=X.iloc[0], b=X.iloc[1])
    print("\n> Test distances funtion:")
    print(f"- Euclidean: {dist}")
    print(f"- Minkowski: {dist2}")

    a = (1,3,5,7,9)
    b = (2,4,4,1,8)

    dist1 = get_distance(a, b)
    dist2 = get_distance2(a, b)

    print("dist1: ", dist1)
    print("dist2: ", dist2)
    """