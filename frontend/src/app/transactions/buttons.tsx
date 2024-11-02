import { PlusIcon, TrashIcon } from '@heroicons/react/24/outline';

export function AddTransactionButton() {
  return (
    <div
      className="flex items-center justify-center gap-2 px-4 py-2 h-full
        rounded-lg cursor-pointer bg-theme-lgt-green hover:bg-theme-drk-green
        active:bg-theme-pressed-green active:scale-95 active:shadow-inner
        transition-color duration-150"
      onClick={() => console.log("should add a transaction.")}
    >
      <PlusIcon className="h-5 w-5" />
      <span className="hidden md:inline">Add Transaction</span>
    </div>
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
