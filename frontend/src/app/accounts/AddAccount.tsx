import { PlusIcon } from "@heroicons/react/16/solid";

export default function AddAccount() {
  return (
    <div
      className="flex flex-none items-center justify-center \
        h-10 w-64 \
        rounded-lg cursor-pointer \
        bg-theme-lgt-green hover:bg-theme-drk-green \
        active:bg-theme-pressed-green active:scale-95 active:shadow-inner
        border"
      onClick={()=>console.log("should add a transaction.")}
    >
      <PlusIcon className="h-5 w-5" />
      <span>Add Account</span>
    </div>
  );
}