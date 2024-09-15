import React, { useState, useEffect } from 'react';
import { Category, Transaction, TransactionMetaData } from "../../lib/definitions";
import { updateTransaction } from '@/app/lib/data';
import TransactionsTableHeader from "./TransactionsTableHeader";
import TransactionsTableRow from "./TransactionsTableRow";
import TransactionsTableRowExpanded from "./TransactionsTableRowExpanded";
import PaginationBar from '../../ui/shared/pagination-bar/PaginationBar';

interface TransactionsTableProps {
  transactions: Transaction[];
  transactionMetaData: TransactionMetaData;
  categories: Category[];
  setTransactions: React.Dispatch<React.SetStateAction<Transaction[]>>;
}

export default function TransactionsTable({
  transactions,
  transactionMetaData,
  categories,
  setTransactions
}: TransactionsTableProps) {
  const [
    expandedRowTransactionId,
    setExpandedRowTransactionId
  ] = useState<number | null>(null);

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
    if (event.target instanceof Element) {
      // Check if the click target is inside the transactions table
      const isInsideTransactionsTable = event.target.closest('.transactions-table');

      // Check if the click target is not part of the expanded row
      const isOutsideExpandedRow = !event.target.closest('.expanded-row');

      // Collapse the expanded row only if the click is outside
      // the expanded row and not inside the transactions table
      if (isOutsideExpandedRow && !isInsideTransactionsTable) {
        setExpandedRowTransactionId(null);
      }
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
        { transactionDate: newDate }
      )
      updateTransactionInState(updatedTransaction);
      return true;
    } catch (error) {
      if (error instanceof Error) {
        console.error(`Error updating transaction date: ${error.message}`);
      } else {
        console.log('Error updating transaction: An unknown error occurred');
      }
      return false;
    }
  };

  const handleUpdateTransactionDescription = async (
    transaction_id: number,
    description: string
  ): Promise<boolean> => {
    try {
      const updatedTransaction = await updateTransaction(
        transaction_id,
        { description: description }
      )
      updateTransactionInState(updatedTransaction);
      return true;
    } catch (error) {
      if (error instanceof Error) {
        console.error(`Error updating transaction description: ${error.message}`);
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
        { subcategoryName: newSubcategoryName }
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
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [])

  return (
    <div className="mt-6">
      <div className="inline-block min-w-full align-middle">
        <div className="rounded-lg bg-gray-50 p-2 md:pt-0">
          <table className="min-w-full text-gray-900 table-fixed">
            <TransactionsTableHeader />
            <tbody className="transactions-table bg-white">
              {transactions.map((transaction) => {
                if (transaction.id === expandedRowTransactionId) {
                  return (
                    <TransactionsTableRowExpanded
                      key={transaction.id}
                      transaction={transaction}
                      categories={categories}
                      setExpandedRowTransactionId={setExpandedRowTransactionId}
                      onUpdateTransactionDate={handleUpdateTransactionDate}
                      onUpdateTransactionDescription={handleUpdateTransactionDescription}
                      onUpdateTransactionSubcategory={handleUpdateTransactionSubcategory}
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
          <PaginationBar
            prevPage={transactionMetaData.prevPage}
            nextPage={transactionMetaData.nextPage}
          />
        </div>
      </div>
    </div>
  );
}
