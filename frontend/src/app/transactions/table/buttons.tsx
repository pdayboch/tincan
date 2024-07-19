import { PencilIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/outline';
import Link from 'next/link';

export function CreateTransaction() {
  return (
    <div
      className="flex items-center justify-center \
        h-full w-12 \
        rounded-lg cursor-pointer \
        bg-theme-lgt-green hover:bg-theme-drk-green \
        active:bg-theme-pressed-green active:scale-95 active:shadow-inner"
      onClick={()=>console.log("should add a transaction.")}
    >
      <PlusIcon className="h-5 w-5" />
    </div>
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
