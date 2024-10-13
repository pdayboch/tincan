import { PlusIcon } from "@heroicons/react/16/solid";
import clsx from "clsx";

interface AddRuleButtonProps {
  label: string;
  onClick: () => void;
  disabled: boolean;
}

export default function AddRuleButton({
  label,
  onClick,
  disabled
}: AddRuleButtonProps) {
  return (
    <button
      className={clsx(
        "inline-flex flex-none items-center justify-center",
        "h-10 max-w-s px-4 py-2 border rounded-lg",
        disabled ?
          "bg-gray-300 cursor-not-allowed opacity-50" :
          "bg-theme-lgt-green hover:bg-theme-drk-green \
          active:bg-theme-pressed-green active:scale-97 \
                    active:shadow-inner cursor-pointer"
      )}
      onClick={onClick}
      disabled={disabled}
    >
      <PlusIcon className="h-5 w-5" />
      <span className="hidden md:inline text-m">
        {label}
      </span>
    </button >
  );
}