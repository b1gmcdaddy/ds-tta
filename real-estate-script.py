import pandas as pd
from sklearn.preprocessing import MinMaxScaler


# Load the dataset
df = pd.read_csv(r'C:\Users\Jolo\Desktop\Realestate.csv')

# Normalize houseAge to 0-1 range using Min-Max scaling
scaler = MinMaxScaler()
df['houseAgeStandardized'] = scaler.fit_transform(df[['houseAge']])

print("=== After normalizing houseAge -> houseAgeStandardized ===")
print(df[['houseAge', 'houseAgeStandardized']].head(10))
print()

# Drop numberOfConvenienceStores column
df.drop(columns=['numberOfConvenienceStores'], inplace=True)

print("=== After dropping numberOfConvenienceStores ===")
print(df.columns.tolist())
print()

# Rename 'transaction' to 'transactionDate'
df.rename(columns={'transaction': 'transactionDate'}, inplace=True)

print("=== After renaming 'transaction' -> 'transactionDate' ===")
print(df.columns.tolist())
print()

# Display rows 0-10 using label-based .loc[] (inclusive)
print("=== .loc[] — rows with index labels 0 to 10 (inclusive) ===")
print(df.loc[0:10])
print()

# Display first 10 rows using position-based .iloc[] (exclusive stop)
print("=== .iloc[] — first 10 rows by integer position (0–9) ===")
print(df.iloc[0:10])
print()

# Find and remove duplicate rows
num_duplicates = df.duplicated().sum()
print(f"=== Duplicate rows found: {num_duplicates} ===")
df.drop_duplicates(inplace=True)
print(f"Rows remaining after removing duplicates: {len(df)}")
print()

# Fill missing values with column mean
print("=== Missing values before filling ===")
print(df.isnull().sum())

# Fill missing values with the mean of each numeric column
numeric_cols = df.select_dtypes(include='number').columns
df[numeric_cols] = df[numeric_cols].fillna(df[numeric_cols].mean())

print("\n=== Missing values after filling with column mean ===")
print(df.isnull().sum())
print()

# Final dataset overview
print("=== Final dataset shape:", df.shape, "===")
print(df.head())

# Save cleaned dataset to CSV
df.to_csv(r'C:\Users\Jolo\Desktop\Realestate_cleaned.csv', index=False)
print("\nCleaned dataset saved to Realestate_cleaned.csv")