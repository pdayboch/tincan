import React, { useState, useEffect, useRef } from 'react';
import { Category, Transaction } from "../../lib/definitions";
import TransactionsTableHeader from "./TransactionsTableHeader";
import TransactionsTableMobileRow from "./TransactionsTableMobileRow";
import TransactionsTableRow from "./TransactionsTableRow";
import TransactionsTableRowExpanded from "./TransactionsTableRowExpanded";
import { updateTransaction } from '@/app/lib/data';

interface TransactionsTableProps {
  transactions: Transaction[];
  categories: Category[];
  setTransactions: React.Dispatch<React.SetStateAction<Transaction[]>>;
}

export default function TransactionsTable({
  transactions,
  categories,
  setTransactions
}: TransactionsTableProps) {
  const [
    expandedRowTransactionId,
    setExpandedRowTransactionId
  ] = useState<number | null>(null);

  const rowRef = useRef<HTMLTableElement>(null);

  // Handler to expand the row when clicked
  const handleRowClick = (transactionId: number) => {
    setExpandedRowTransactionId(prevId => {
      if (prevId === transactionId) {
        return null;
      } else {
        return transactionId;
      }
    });
  }

  // Handler to collapse row when clicked outside.
  const handleClickOutside = (event: MouseEvent) => {
    if (rowRef.current && !rowRef.current.contains(event.target as Node)) {
      setExpandedRowTransactionId(null);
    }
  };

  const updateTransactionInState = (updatedTransaction: Transaction) => {
    const updatedTransactions = transactions.map((transaction) => {
      if (transaction.id === updatedTransaction.id) {
        return updatedTransaction;
      }
      return transaction;
    });
    setTransactions(updatedTransactions);
  }

  const handleUpdateTransactionDate = async (
    transaction_id: number,
    newDate: string
  ): Promise<boolean> => {
    try {
      const updatedTransaction = await updateTransaction(
        transaction_id,
        { transaction_date: newDate }
      )
      updateTransactionInState(updatedTransaction);
      return true;
    } catch(error) {
      if (error instanceof Error) {
        console.error(`Error updating transaction date: ${error.message}`);
      } else {
        console.log('Error updating transaction: An unknown error occurred');
      }
      return false;
    }
  };

  const handleUpdateTransactionSubcategory = async (
    transactionId: number,
    newSubcategoryName: string
  ): Promise<boolean> => {
    try {
      const updatedTransaction = await updateTransaction(
        transactionId,
        { subcategory_name: newSubcategoryName }
      )
      updateTransactionInState(updatedTransaction);
      return true;
    } catch (error) {
      if (error instanceof Error) {
        console.log(`Error updating transaction ${error.message}`)
      } else {
        console.log('Error updating transaction: An unknown error occurred');
      }
      return false;
    }
  };

  useEffect(() => {
    document.addEventListener('mousedown', handleClickOutside);
    return() => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [])

  return (
    <div className="mt-6 flow-root">
      <div className="inline-block min-w-full align-middle">
        <div className="rounded-lg bg-gray-50 p-2 md:pt-0">
          <div className="md:hidden">
            {transactions.map((transaction) => (
              <TransactionsTableMobileRow
                key={transaction.id}
                transaction={transaction}
              />
            ))}
          </div>
          <table className="hidden min-w-full text-gray-900 md:table">
            <TransactionsTableHeader />
            <tbody className="bg-white">
              {transactions.map((transaction) => {
                if (transaction.id === expandedRowTransactionId) {
                  return (
                    <TransactionsTableRowExpanded
                      key={transaction.id}
                      transaction={transaction}
                      categories={categories}
                      setExpandedRowTransactionId={setExpandedRowTransactionId}
                      onUpdateTransactionSubcategory={handleUpdateTransactionSubcategory}
                      onUpdateTransactionDate={handleUpdateTransactionDate}
                    />
                  );
                } else {
                  return (
                    <TransactionsTableRow
                      key={transaction.id}
                      transaction={transaction}
                      onClick={() => handleRowClick(transaction.id)}
                    />
                  );
                }
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
