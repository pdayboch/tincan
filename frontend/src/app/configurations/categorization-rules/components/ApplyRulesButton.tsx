import { PlayIcon } from "@heroicons/react/16/solid";

interface ApplyRulesButtonProps {
  onClick: () => void;
}

export default function ApplyRulesButton({ onClick }: ApplyRulesButtonProps) {
  return (
    <button
      className="inline-flex flex-none items-center justify-center \
                    h-10 max-w-s px-4 py-2 border rounded-lg \
                    bg-theme-lgt-green hover:bg-theme-drk-green \
                    active:bg-theme-pressed-green active:scale-95 \
                    active:shadow-inner cursor-pointer"
      onClick={onClick}
    >
      <PlayIcon className="h-5 w-5" />
      <span className="hidden md:inline text-m">
        Apply rules to uncategorized
      </span>
    </button>
  );
}