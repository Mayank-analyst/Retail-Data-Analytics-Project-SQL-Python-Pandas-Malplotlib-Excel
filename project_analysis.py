import pandas as pd

# Load CSV files directly
response_df = pd.read_csv(r'C:\Users\Mayank Bisht\Desktop\Retail Project\Retail_Data_Response.csv')
transaction_df = pd.read_csv(r'C:\Users\Mayank Bisht\Desktop\Retail Project\Retail_Data_Transactions.csv')

# Print sample data
print("Response Data:")
print(response_df.head())

print("\nTransaction Data:")
print(transaction_df.head())


# ---------- DATA CLEANING ----------

# Remove missing values
transaction_df.dropna(subset=['customer_id', 'trans_date', 'tran_amount'], inplace=True)

# Convert date column to datetime
transaction_df['trans_date'] = pd.to_datetime(transaction_df['trans_date'], errors='coerce')

# Remove invalid dates
transaction_df.dropna(subset=['trans_date'], inplace=True)

print("\nData cleaned successfully!")


# ---------- DATA PREPARATION ----------

# Total sales per customer
customer_sales = transaction_df.groupby('customer_id')['tran_amount'].sum().reset_index()
customer_sales.rename(columns={'tran_amount': 'total_amount'}, inplace=True)

# Number of transactions per customer
transaction_count = transaction_df.groupby('customer_id')['tran_amount'].count().reset_index()
transaction_count.rename(columns={'tran_amount': 'num_transactions'}, inplace=True)

# Merge both
customer_summary = pd.merge(customer_sales, transaction_count, on='customer_id')

# Extract year and month
transaction_df['year'] = transaction_df['trans_date'].dt.year
transaction_df['month'] = transaction_df['trans_date'].dt.month

print("\nCustomer Summary:")
print(customer_summary.head())


# ---------- MERGE DATA ----------

final_df = pd.merge(response_df, customer_summary, on='customer_id', how='left')

print("\nFinal Merged Data:")
print(final_df.head())



# ---------- ANALYSIS ----------

# Top 5 customers by total spending
print("\nTop 5 Customers:")
top_customers = final_df.sort_values(by='total_amount', ascending=False).head()
print(top_customers)

# Response distribution
print("\nResponse Distribution:")
print(final_df['response'].value_counts())

# Average spending by response
print("\nAverage Spending by Response:")
avg_spending = final_df.groupby('response')['total_amount'].mean()
print(avg_spending)


# ---------- TABULAR REPORTS ----------

# Total sales per month
monthly_sales = transaction_df.groupby(['year', 'month'])['tran_amount'].sum().reset_index()

print("\nMonthly Sales:")
print(monthly_sales.head())

# Save to CSV
monthly_sales.to_csv('monthly_sales.csv', index=False)
final_df.to_csv('final_dataset.csv', index=False)

print("\nReports saved successfully!")

# ---------- VISUALIZATION ----------

import matplotlib.pyplot as plt

# Monthly sales trend
monthly_sales_grouped = transaction_df.groupby(['year', 'month'])['tran_amount'].sum()

monthly_sales_grouped.plot()
plt.title("Monthly Sales Trend")
plt.xlabel("Year-Month")
plt.ylabel("Total Sales")
plt.show()


# ---------- EXPORT TO EXCEL ----------
with pd.ExcelWriter(r'C:\Users\Mayank Bisht\Desktop\Retail Project\Retail_Report.xlsx') as writer:
    final_df.to_excel(writer, sheet_name='Customer Summary', index=False)
    monthly_sales.to_excel(writer, sheet_name='Monthly Sales', index=False)

print("Excel report created!")