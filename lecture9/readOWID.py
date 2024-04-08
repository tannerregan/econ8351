import pandas as pd

# Specify the file path
dir=r"C:\Users\tanner_regan\Documents\GitHub\econ8351\lecture9/"
file_path = dir+'urban-and-rural-population-2050.csv'

# Read the CSV file into a pandas DataFrame
df = pd.read_csv(file_path)

# Display the first few rows of the DataFrame
print(df.head())


filtered_df = df[(df['Entity'].str.contains('income', case=False)) & 
                 (df['Year'].isin([2000, 2025, 2050]))]
filtered_df = filtered_df.rename(columns={'Urban population (HYDE estimates and UN projections)': 'Urban'})
filtered_df = filtered_df[['Entity', 'Year', 'Urban']]
filtered_df['Urban'] = (filtered_df['Urban'] / 1_000_000).round().astype(int)
filtered_df['Entity'] = filtered_df['Entity'].str.replace(' countries \(UN\)', '', regex=True)

reshaped_df = filtered_df.pivot_table(index='Entity', columns='Year', values='Urban')

# Display the filtered DataFrame
print(reshaped_df)

# Write the reshaped DataFrame to a CSV file
reshaped_df.to_csv(dir+'output_table.csv')