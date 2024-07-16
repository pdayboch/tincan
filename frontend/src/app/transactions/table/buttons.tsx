import { PencilIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import Link from 'next/link';

export function CreateTransaction() {
  return (
    <Link
      href="/dashboard/invoices/create"
      className="flex h-full items-center rounded-lg px-4 text-medium font-medium text-black transition-colors bg-theme-lgt-green hover:bg-theme-drk-green focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
    >
      <span className="hidden md:block">Add Transaction</span>
      <PlusIcon className="h-5 md:ml-4" />
    </Link>
  );
}

export function UpdateTransaction({ id }: { id: string }) {
  return (
    <Link
      href="/dashboard/invoices"
      className="rounded-md border p-2 hover:bg-gray-100"
    >
      <PencilIcon className="w-5" />
    </Link>
  );
}

export function DeleteTransaction({ id }: { id: string }) {
  return (
    <>
      <button className="rounded-md border p-2 hover:bg-gray-100">
        <span className="sr-only">Delete</span>
        <TrashIcon className="w-5" />
      </button>
    </>
  );
}
