import { PlusIcon } from "@heroicons/react/16/solid";

export default function NoRulesComponent() {
  return (
    <div className="flex flex-col items-center justify-center \
                      border rounded-2xl px-14 py-8 w-3/4 \
                      mx-auto max-w-xl space-y-4 \
                      bg-white shadow-lg"
    >
      <p className="text-lg text-center mb-12">
        You don't have any auto-categorization rules configured yet!</p>
      <button className="flex flex-col item-center justify-center \
                          px-6 py-3 bg-blue-500 text-white rounded-lg \
                          hover:bg-blue-600 transition"
      >
        <div className="flex flex-col items-center">
          <PlusIcon className="h-6 w-6" />
          <p>Add one now</p>
        </div>
      </button>
    </div>
  );
}